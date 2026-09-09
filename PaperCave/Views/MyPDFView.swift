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
    
    @State private var pdfUrl: URL?
    @State private var selectedText = ""
    @State private var responseText = ""
    @State private var isLoading = false

    private let aiService = AIServices()

    var body: some View {
        VStack {
            if let pdfUrl {
                PDFKitView(
                    url: pdfUrl,
                    selectedText: $selectedText
                )

                Text("Selected: \(selectedText)")

                HStack {
                    Button("Explain") {
                        Task {
                            await generate(action: .explain)
                        }
                    }

                    Button("Simplify") {
                        Task {
                            await generate(action: .simplify)
                        }
                    }
                }
                .disabled(selectedText.isEmpty || isLoading)

                if isLoading {
                    ProgressView()
                } else if !responseText.isEmpty {
                    ScrollView {
                        Text(responseText)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .textSelection(.enabled)
                    }
                }

            } else {
                Text("PDF URL not found!")
            }
        }
        .onAppear {
            pdfUrl = Bundle.main.url(
                forResource: "sample",
                withExtension: "pdf"
            )
        }
    }

    private func generate(action: AIAction) async {
        isLoading = true
        defer { isLoading = false }

        do {
            responseText = try await aiService.generateResponse(
                text: selectedText,
                action: action
            )
        } catch {
            responseText =
                "Failed to generate response: \(error.localizedDescription)"
        }
    }
}
