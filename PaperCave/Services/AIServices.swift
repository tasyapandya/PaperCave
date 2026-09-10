//
//  AIServices.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 07/09/26.
//
//
//  AIServices.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 07/09/26.
//

import Foundation
import FoundationModels

@Generable
struct Explanation {

    @Guide(
        description:
        "A concise explanation of the main concept in the selected passage"
    )
    var explanation: String

    @Guide(
        description:
        "The single most important point to remember from the selected passage"
    )
    var keyTakeaway: String
}

enum AIAction: String {
    case explain
    case simplify
}

@MainActor
final class AIServices {

    private let session: LanguageModelSession

    init() {

        session = LanguageModelSession(
            instructions: """
            You help students understand academic papers.

            Keep responses clear, concise, and accurate.

            For Explain:
            explain the selected text or concept in context.

            For Simplify:
            rewrite the selected academic text using simpler language
            while preserving its original meaning.
            """
        )
    }

    func generate(
        text: String,
        action: AIAction
    ) async throws -> Explanation {

        let prompt: String

        switch action {

        case .explain:

            prompt = """
            Explain the following academic text clearly.

            Focus on:
            - what the concept means
            - why it matters in this passage

            Selected text:
            \(text)
            """

        case .simplify:

            prompt = """
            Simplify the following academic text.

            Preserve:
            - technical meaning
            - important terminology
            - important claims

            Selected text:
            \(text)
            """
        }

        let response = try await session.respond(
            to: prompt,
            generating: Explanation.self
        )

        return response.content
    }
}
