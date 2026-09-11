//
//  MyPDFView.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 08/09/26.
//

import SwiftUI
import SwiftData

struct MyPDFView: View {

    @Environment(\.modelContext)
    private var modelContext

    @Query
    private var papers: [Paper]

    @State private var pdfUrl: URL?
    @State private var selectionInfo: PDFSelectionInfo?
    @State private var activeSelection: PDFSelectionInfo?
    @State private var activeSelectionID = UUID()
    @State private var lastHandledSelectionKey: String?
    @State private var currentAction: AIAction?
    @State private var currentInteraction: Interaction?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var currentPaper: Paper?
    @State private var showHighlights = true
    @State private var pdfCommand: PDFCommand?
    @State private var followUpText = ""
    @State private var focusedInteractionID: UUID?
    @State private var focusedScrollRequestID = UUID()

    private let aiService = AIServices()
    private let conversationBottomID = "conversationBottom"

    var body: some View {
        HStack(spacing: 0) {
            readerPane

            Rectangle()
                .fill(PaperCaveStyle.separator)
                .frame(width: 1)

            resultPanel
                .frame(minWidth: 360)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(PaperCaveStyle.background)
        .onAppear {
            setupPaper()
        }
        .onChange(of: selectionInfo?.selectionKey) { _, newKey in
            updateActiveSelection(for: newKey)
        }
    }
}

extension MyPDFView {

    private var readerPane: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(currentPaper?.title ?? "PaperCave")
                .font(.system(size: 20))
                .foregroundStyle(PaperCaveStyle.text)
                .lineLimit(1)

            ZStack(alignment: .topTrailing) {
                if let pdfUrl {
                    PDFKitView(
                        url: pdfUrl,
                        selectionInfo: $selectionInfo,
                        highlights: highlightItems,
                        showHighlights: showHighlights,
                        command: $pdfCommand,
                        onHighlightTapped: { interactionID in
                            openInteraction(id: interactionID)
                        }
                    )
                    .background(.white)
                    .shadow(
                        color: .black.opacity(0.12),
                        radius: 10,
                        x: 4,
                        y: 3
                    )
                } else {
                    ContentUnavailableView(
                        "PDF Not Found",
                        systemImage: "doc.questionmark",
                        description: Text("Unable to load the PDF.")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white)
                }

                pdfControls
                    .padding(14)
            }
            .frame(maxWidth: 560)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding(.leading, 28)
        .padding(.trailing, 32)
        .padding(.top, 30)
        .padding(.bottom, 74)
        .frame(minWidth: 520)
        .frame(idealWidth: 606, maxWidth: 640, maxHeight: .infinity)
    }

    private var pdfControls: some View {
        HStack(spacing: 8) {
            Button {
                pdfCommand = .zoomOut
            } label: {
                Image(systemName: "minus.magnifyingglass")
            }
            .help("Zoom Out")

            Button {
                pdfCommand = .fit
            } label: {
                Image(systemName: "1.magnifyingglass")
            }
            .help("Fit Page")

            Button {
                pdfCommand = .zoomIn
            } label: {
                Image(systemName: "plus.magnifyingglass")
            }
            .help("Zoom In")

            Divider()
                .frame(height: 18)

            Button {
                showHighlights.toggle()
            } label: {
                Image(systemName: "highlighter")
                    .symbolVariant(showHighlights ? .fill : .none)
            }
            .help(showHighlights ? "Hide Highlights" : "Show Highlights")
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: Capsule())
    }
}

private extension PDFSelectionInfo {

    var selectionKey: String {
        [
            text,
            String(pageIndex),
            String(format: "%.3f", bounds.origin.x),
            String(format: "%.3f", bounds.origin.y),
            String(format: "%.3f", bounds.width),
            String(format: "%.3f", bounds.height)
        ]
        .joined(separator: "|")
    }
}

extension MyPDFView {

    private var resultPanel: some View {
        VStack(alignment: .leading, spacing: 28) {
            if conversationMessages.isEmpty {
                emptyResultPanel
            } else {
                conversationPanel
            }

            Spacer(minLength: 18)

            if activeSelection != nil {
                actionPanel
            }

            followUpInput
        }
        .padding(.horizontal, 34)
        .padding(.vertical, 74)
        .foregroundStyle(PaperCaveStyle.text)
    }

    private var conversationPanel: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ForEach(conversationMessages) { message in
                        messageView(message)
                    }

                    if let currentInteraction {
                        Button {
                            toggleSaved(currentInteraction)
                        } label: {
                            Label(
                                currentInteraction.isSaved ? "Saved" : "Bookmark",
                                systemImage: currentInteraction.isSaved ? "bookmark.fill" : "bookmark"
                            )
                        }
                        .buttonStyle(.bordered)
                    }

                    Color.clear
                        .frame(height: 1)
                        .id(conversationBottomID)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .onChange(of: activeSelectionID) { _, _ in
                withAnimation(.easeOut(duration: 0.2)) {
                    proxy.scrollTo(conversationBottomID, anchor: .bottom)
                }
            }
            .onChange(of: focusedScrollRequestID) { _, _ in
                guard let focusedInteractionID else {
                    return
                }

                DispatchQueue.main.async {
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(focusedInteractionID, anchor: .top)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func messageView(_ message: Message) -> some View {
        if let selectedText = message.selectedText {
            if let interactionID = interactionID(for: message) {
                SelectedTextMessageView(text: selectedText) {
                    openInteraction(id: interactionID)
                }
                .id(interactionID)
            } else {
                SelectedTextMessageView(text: selectedText)
            }
        } else if message.role == MessageRole.user.rawValue {
            UserFollowUpBubble(text: message.content)
        } else {
            AssistantResponseView(
                title: responseTitle(for: message),
                explanation: message.explanation ?? message.content,
                keyTakeaway: message.keyTakeaway
            )
        }
    }

    private var emptyResultPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hi! What do you want to learn today?")
                .font(.system(size: 24, weight: .bold))

            Text("Select a passage in the PDF and PaperCave will help explain or simplify it.")
                .font(.system(size: 16))
                .lineSpacing(3)
                .foregroundStyle(PaperCaveStyle.mutedText)
        }
        .frame(maxWidth: 560, alignment: .leading)
    }

    private var actionPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let activeSelection {
                selectedTextCard(activeSelection.text)
            }

            actionButtons

            if isLoading {
                ProgressView("Generating response...")
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func selectedTextCard(_ text: String) -> some View {
        SelectedTextMessageView(text: text)
    }

    private var followUpInput: some View {
        HStack {
            TextField("Enter your message here", text: $followUpText)
                .textFieldStyle(.plain)
                .onSubmit {
                    sendFollowUp()
                }

            Button {
                sendFollowUp()
            } label: {
                Image(systemName: "paperplane")
            }
            .buttonStyle(.plain)
            .disabled(trimmedFollowUp.isEmpty || isLoading)
        }
        .font(.system(size: 16))
        .padding(.horizontal, 14)
        .frame(height: 66)
        .background(
            PaperCaveStyle.panel,
            in: RoundedRectangle(cornerRadius: 8)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(PaperCaveStyle.separator.opacity(0.8))
        }
    }

    private func section(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 24, weight: .bold))

            Text(text)
                .font(.system(size: 16))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func responseTitle(for message: Message) -> String {
        if let title = message.title, !title.isEmpty {
            return title
        }

        switch message.action {
        case AIAction.simplify.rawValue:
            return "Simplified Explanation"

        default:
            return "Explanation"
        }
    }
}

private struct SelectedTextMessageView: View {

    let text: String
    var onTap: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Selected Text")
                .font(.system(size: 16, weight: .bold))

            Text(text)
                .font(.system(size: 16))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            PaperCaveStyle.selected,
            in: RoundedRectangle(cornerRadius: 15)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(red: 0.933, green: 0.796, blue: 0.682))
        }
        .contentShape(RoundedRectangle(cornerRadius: 15))
        .onTapGesture {
            onTap?()
        }
    }
}

private struct UserFollowUpBubble: View {

    let text: String

    var body: some View {
        HStack {
            Spacer(minLength: 76)

            Text(text)
                .font(.system(size: 16))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: 615, alignment: .leading)
                .background(
                    PaperCaveStyle.selected,
                    in: RoundedRectangle(cornerRadius: 15)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(red: 0.933, green: 0.796, blue: 0.682))
                }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

private struct AssistantResponseView: View {

    let title: String
    let explanation: String
    let keyTakeaway: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            responseSection(title: title, text: explanation)

            if let keyTakeaway {
                responseSection(title: "Key Takeaway", text: keyTakeaway)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func responseSection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 24, weight: .bold))

            Text(text)
                .font(.system(size: 16))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

extension MyPDFView {

    private var actionButtons: some View {
        HStack(spacing: 8) {
            Button {
                runAI(action: .explain)
            } label: {
                Text("Explain")
                    .frame(width: 102)
            }

            Button {
                runAI(action: .simplify)
            } label: {
                Text("Simplify")
                    .frame(width: 102)
            }
        }
        .font(.system(size: 16, weight: .bold))
        .buttonStyle(PaperCaveActionButtonStyle())
        .frame(maxWidth: .infinity, alignment: .center)
        .disabled(activeSelection == nil || isLoading)
    }
}

private struct PaperCaveActionButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(PaperCaveStyle.selected)
            .padding(.vertical, 8)
            .background(
                PaperCaveStyle.text.opacity(configuration.isPressed ? 0.82 : 1),
                in: RoundedRectangle(cornerRadius: 15)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(red: 0.482, green: 0.239, blue: 0.039))
            }
    }
}

extension MyPDFView {

    private func runAI(action: AIAction) {
        guard let selectionInfo = activeSelection else {
            return
        }

        let cleanText =
            selectionInfo.text
                .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanText.isEmpty else {
            return
        }

        Task {
            isLoading = true
            errorMessage = nil

            defer {
                isLoading = false
            }

            do {
                let generated =
                    try await aiService.generate(
                        text: cleanText,
                        action: action,
                        history: conversationMessages
                    )

                currentAction = action

                let interaction =
                    saveInteraction(
                        selection: selectionInfo,
                        generated: generated,
                        action: action
                    )

                currentInteraction = interaction
                lastHandledSelectionKey = selectionInfo.selectionKey
                activeSelection = nil
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func sendFollowUp() {
        let question = trimmedFollowUp

        guard !question.isEmpty, !isLoading else {
            return
        }

        Task {
            let userMessage = saveMessage(
                role: .user,
                content: question
            )

            followUpText = ""
            isLoading = true
            errorMessage = nil

            do {
                let generated = try await aiService.followUp(
                    question: question,
                    history: conversationMessages
                )

                saveAssistantMessage(generated)
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
            _ = userMessage
        }
    }
}

extension MyPDFView {

    @discardableResult
    private func saveInteraction(
        selection: PDFSelectionInfo,
        generated: Explanation,
        action: AIAction
    ) -> Interaction {
        let interaction = Interaction(
            selectedText: selection.text,
            explanation: generated.explanation,
            keyTakeaway: generated.keyTakeaway,
            action: action.rawValue,
            pageIndex: selection.pageIndex,
            highlightX: selection.bounds.origin.x,
            highlightY: selection.bounds.origin.y,
            highlightWidth: selection.bounds.width,
            highlightHeight: selection.bounds.height,
            paper: currentPaper
        )

        modelContext.insert(interaction)
        currentPaper?.interactions.append(interaction)

        saveMessage(
            role: .user,
            content: action.rawValue.capitalized,
            selectedText: selection.text,
            action: action,
            interactionID: interaction.id
        )

        saveAssistantMessage(generated, action: action)

        return interaction
    }

    @discardableResult
    private func saveMessage(
        role: MessageRole,
        content: String,
        selectedText: String? = nil,
        action: AIAction? = nil,
        interactionID: UUID? = nil,
        title: String? = nil,
        explanation: String? = nil,
        keyTakeaway: String? = nil
    ) -> Message {
        let message = Message(
            role: role,
            content: content,
            selectedText: selectedText,
            action: action?.rawValue,
            interactionID: interactionID,
            title: title,
            explanation: explanation,
            keyTakeaway: keyTakeaway,
            paper: currentPaper
        )

        modelContext.insert(message)
        currentPaper?.messages.append(message)

        return message
    }

    private func saveAssistantMessage(
        _ generated: Explanation,
        action: AIAction? = nil
    ) {
        saveMessage(
            role: .assistant,
            content: generated.explanation,
            action: action,
            title: generated.title,
            explanation: generated.explanation,
            keyTakeaway: generated.keyTakeaway
        )
    }
}

extension MyPDFView {

    private var highlightItems: [PDFHighlightItem] {
        guard let currentPaper else {
            return []
        }

        return currentPaper
            .interactions
            .compactMap { interaction in
                guard
                    let pageIndex = interaction.pageIndex,
                    let bounds = interaction.highlightBounds
                else {
                    return nil
                }

                return PDFHighlightItem(
                    id: interaction.id,
                    pageIndex: pageIndex,
                    bounds: bounds
                )
            }
    }

    private var conversationMessages: [Message] {
        currentPaper?.messages.sorted { $0.createdAt < $1.createdAt } ?? []
    }

    private var trimmedFollowUp: String {
        followUpText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func interactionID(for message: Message) -> UUID? {
        if let interactionID = message.interactionID {
            return interactionID
        }

        guard let selectedText = message.selectedText else {
            return nil
        }

        return currentPaper?
            .interactions
            .first(where: {
                $0.selectedText == selectedText
                && $0.action == message.action
            })?
            .id
    }

    private func updateActiveSelection(for newKey: String?) {
        guard let selectionInfo, let newKey else {
            return
        }

        guard activeSelection == nil else {
            if !isLoading {
                activeSelection = selectionInfo
            }

            return
        }

        guard newKey != lastHandledSelectionKey else {
            return
        }

        activeSelection = selectionInfo
        activeSelectionID = UUID()
    }
}

extension MyPDFView {

    private func openInteraction(id: UUID) {
        guard let currentPaper else {
            return
        }

        guard
            let interaction =
                currentPaper
                    .interactions
                    .first(where: { $0.id == id })
        else {
            return
        }

        currentInteraction = interaction
        currentAction = AIAction(rawValue: interaction.action)
        focusedInteractionID = interaction.id
        focusedScrollRequestID = UUID()

        if let pageIndex = interaction.pageIndex,
           let bounds = interaction.highlightBounds {
            pdfCommand = .goTo(pageIndex: pageIndex, bounds: bounds)
        }
    }

    private func openInteraction(from message: Message) {
        if let interactionID = message.interactionID {
            openInteraction(id: interactionID)
            return
        }

        guard let currentPaper,
              let selectedText = message.selectedText,
              let interaction =
                currentPaper
                    .interactions
                    .first(where: {
                        $0.selectedText == selectedText
                        && $0.action == message.action
                    })
        else {
            return
        }

        openInteraction(id: interaction.id)
    }
}

extension MyPDFView {

    private func toggleSaved(_ interaction: Interaction) {
        interaction.isSaved.toggle()
    }
}

extension MyPDFView {

    private func setupPaper() {
        guard currentPaper == nil else {
            return
        }

        guard
            let url =
                Bundle.main.url(
                    forResource: "sample-2",
                    withExtension: "pdf"
                )
        else {
            return
        }

        pdfUrl = url

        let title =
            url
                .deletingPathExtension()
                .lastPathComponent

        if let existingPaper =
            papers.first(where: { $0.title == title }) {
            currentPaper = existingPaper
            return
        }

        let newPaper = Paper(title: title)

        modelContext.insert(newPaper)
        currentPaper = newPaper
    }
}
