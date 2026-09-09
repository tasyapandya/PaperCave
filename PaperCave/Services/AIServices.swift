//
//  AIServices.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 07/09/26.
//

import FoundationModels

@Generable
struct Explanation {
    @Guide(description: "A concise explanation of the main concept in the selected passage")
    var explanation: String

    @Guide(description: "The single most important point to remember from the selected passage")
    var keyTakeaway: String
}

enum AIAction {
    case explain
    case simplify
}

struct AIServices {

    func generateResponse(
        text: String,
        action: AIAction
    ) async throws -> String {

        // 1. Check model availability
        let model = SystemLanguageModel.default

        guard model.isAvailable else {
            return "Model is not available"
        }

        // 2. Create session
        let session = LanguageModelSession(
            model: model,
            instructions: """
            You are an academic professor who helps students understand academic paper concepts more easily.
            """
        )

        // 3. Generate response based on action
        switch action {

        case .explain:
            let prompt = """
            Explain the following academic passage in 2–4 concise sentences.
            Focus only on the main concept and why it matters in this context.
            Do not explain basic concepts unless they are necessary to understand the passage.

            \(text)
            """

            let response = try await session.respond(
                to: prompt,
                generating: Explanation.self
            )

            return """
            \(response.content.explanation)

            Key Takeaway: \(response.content.keyTakeaway)
            """

        case .simplify:
            let prompt = """
            Rewrite the following academic passage in simpler language while preserving its original meaning.
            Do not add new information.

            \(text)
            """

            let response = try await session.respond(to: prompt)

            return response.content
        }
    }
}
