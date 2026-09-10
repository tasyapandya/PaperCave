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
    @State private var currentAction: AIAction?
    @State private var currentInteraction: Interaction?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var currentPaper: Paper?
    @State private var showHighlights = true
    @State private var pdfCommand: PDFCommand?

    private let aiService = AIServices()

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

extension MyPDFView {

    private var resultPanel: some View {
        VStack(alignment: .leading, spacing: 28) {
            if let currentInteraction {
                responsePanel(interaction: currentInteraction)
            } else {
                emptyResultPanel
            }

            Spacer(minLength: 18)

            if selectionInfo != nil || isLoading || errorMessage != nil {
                actionPanel
            }

            followUpPlaceholder
        }
        .padding(.horizontal, 34)
        .padding(.vertical, 74)
        .foregroundStyle(PaperCaveStyle.text)
    }

    private func responsePanel(interaction: Interaction) -> some View {
        VStack(alignment: .leading, spacing: 28) {
            section(
                title: interaction.action.capitalized,
                text: interaction.explanation
            )

            section(
                title: "Key Takeaway",
                text: interaction.keyTakeaway
            )

            Button {
                toggleSaved(interaction)
            } label: {
                Label(
                    interaction.isSaved ? "Saved" : "Bookmark",
                    systemImage: interaction.isSaved ? "bookmark.fill" : "bookmark"
                )
            }
            .buttonStyle(.bordered)
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
            if let selectionInfo {
                selectedTextCard(selectionInfo.text)
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
        VStack(alignment: .leading, spacing: 8) {
            Text("Selected Text")
                .font(.system(size: 16, weight: .bold))

            ScrollView {
                Text(text)
                    .font(.system(size: 16))
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 116)
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
    }

    private var followUpPlaceholder: some View {
        HStack {
            Text("Enter your message here")
                .foregroundStyle(Color(red: 0.63, green: 0.59, blue: 0.56))

            Spacer()

            Image(systemName: "paperplane")
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
}

extension MyPDFView {

    private var actionButtons: some View {
        HStack(spacing: 8) {
            Button {
                runAI(action: .explain)
            } label: {
                Text("Explain")
                    .frame(width: 100)
            }

            Button {
                runAI(action: .simplify)
            } label: {
                Text("Simplify")
                    .frame(width: 100)
            }
        }
        .font(.system(size: 16, weight: .bold))
        .buttonStyle(PaperCaveActionButtonStyle())
        .frame(maxWidth: .infinity, alignment: .center)
        .disabled(selectionInfo == nil || isLoading)
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
        guard let selectionInfo else {
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
                        action: action
                    )

                currentAction = action

                let interaction =
                    saveInteraction(
                        selection: selectionInfo,
                        generated: generated,
                        action: action
                    )

                currentInteraction = interaction
            } catch {
                errorMessage = error.localizedDescription
            }
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

        return interaction
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
