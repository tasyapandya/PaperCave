//
//  ContentView.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 03/09/26.
//

import SwiftUI
import FoundationModels

@Generable
struct Explanation {
    @Guide(description: "A concise explanation of the main concept in the selected passage")
    var explanation: String
    
    @Guide(description: "The single most important point to remember from the selected passage")
    var keyTakeaway: String
}

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var responseText: String = ""
    @State private var isLoading: Bool = false
    
    enum AIAction {
        case explain
        case simplify
    }

    var body: some View {
        
        VStack(spacing: 16) {
            // Input Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Input")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                TextEditor(text: $inputText)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(height: 160)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.black))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.gray.opacity(0.3), lineWidth: 1)
                    )
            }

            // Action Buttons
            HStack(spacing: 12) {
                Button {
                    Task { await generateResponse(action: .explain) }
                } label: {
                    Label("Explain", systemImage: "text.magnifyingglass")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    Task { await generateResponse(action: .simplify) }
                } label: {
                    Label("Simplify", systemImage: "wand.and.stars")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .disabled(inputText.isEmpty || isLoading)

            Divider()

            // Response Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Response")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                    }
                }

                Group {
                    if isLoading {
                        VStack {
                            Spacer(minLength: 40)
                            ProgressView("Generating...")
                            Spacer(minLength: 40)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        ScrollView {
                            Text(responseText.isEmpty ? "Response will appear here." : responseText)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .textSelection(.enabled)
                                .fixedSize(horizontal: false, vertical: true) // <- prevents cropping
                                .padding(12)
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.08))
                )
            }
        }
        .padding()
    }
    
    private func generateResponse(action: AIAction) async {
        // 1. check availability model
        let model = SystemLanguageModel.default
        
        guard model.isAvailable else {
            responseText = "Model is not available"
            return
        }
        
        let prompt: String
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 2. create session
            let session = LanguageModelSession(
                model: model,
                instructions: """
                    You are an academic professor that help students understand academic paper concepts easier
                    """)
            switch action {
                case .explain:
                
                    prompt = "Explain the following academic passage in 2–4 concise sentences. Focus only on the main concept and why it matters in this context. Do not explain basic concepts unless they are necessary to understand the passage. \(inputText)"
                
                    // 3. create response
                    let response = try await session.respond(to: prompt, generating: Explanation.self)
                    // 3.1 resumes here after response is ready
                    responseText = """
                    \(response.content.explanation)
                    
                    Key Takeaway: \(response.content.keyTakeaway)
                    """
                case .simplify:
                
                    prompt = "Rewrite the following academic passage in simpler language while preserving its original meaning. Do not add new information. \(inputText)"
                
                    // 3. create response
                    let response = try await session.respond(to: prompt)
                    responseText = response.content
            }
        // 4. Catch error
        } catch {
            responseText = "Failed to generate response: \(error.localizedDescription)"
        }
    }
}

#Preview {
    ContentView()
}
