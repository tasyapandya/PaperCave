//
//  ContentView.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 03/09/26.
//

import SwiftUI
import FoundationModels

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
            Text("Input")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.headline)

            TextEditor(text: $inputText)
                .frame(height: 220)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.gray.opacity(0.4))
                )

            HStack {
                Button("Explain") {
                    Task {
                        await generateResponse(action: .explain)
                    }
                }

                Button("Simplify") {
                    Task {
                        await generateResponse(action: .simplify)
                    }
                }
            }
            .disabled(inputText.isEmpty || isLoading)

            Divider()

            Text("Response")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.headline)

            if isLoading {
                Spacer()

                ProgressView()

                Spacer()
            } else {
                ScrollView {
                    Text(responseText.isEmpty ? "Response will appear here." : responseText)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .topLeading
                        )
                        .textSelection(.enabled)
                        .padding()
                }
                .frame(maxHeight: .infinity)
                .background(.gray.opacity(0.08))
                .clipShape(
                    RoundedRectangle(cornerRadius: 8)
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
        
        switch action {
            case .explain: 
                prompt = "Explain the following academic passage clearly: \(inputText)"
            case .simplify:
                prompt = "Rewrite the following academic passage in simpler language while preserving its meaning: \(inputText)"
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 2. create session
            let session = LanguageModelSession(
                model: model,
                instructions: """
                    You are an academic professor that help students understand academic paper concepts easier
                    """)
            // 3. create response
            
            let response = try await session.respond(to: prompt)
            // 3.1 resumes here after response is ready
            responseText = response.content
            // 4. catch error
        } catch {
            responseText = "Failed to generate response: \(error.localizedDescription)"
        }
        
        
    }
}

#Preview {
    ContentView()
}
