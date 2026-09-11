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
        "A short heading that names the main concept or user question. Avoid generic titles."
    )
    var title: String

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
        action: AIAction,
        history: [Message] = []
    ) async throws -> Explanation {

        let prompt: String

        switch action {

        case .explain:

            prompt = """
            Explain the following academic text clearly.

            Focus on:
            - what the concept means
            - why it matters in this passage
            - a short title that describes the main concept

            Selected text:
            \(text)

            Prior conversation:
            \(transcript(from: history))
            """

        case .simplify:

            prompt = """
            Simplify the following academic text.

            Preserve:
            - technical meaning
            - important terminology
            - important claims
            - a short title that describes the simplified concept

            Selected text:
            \(text)

            Prior conversation:
            \(transcript(from: history))
            """
        }

        let response = try await session.respond(
            to: prompt,
            generating: Explanation.self
        )

        return response.content
    }

    func followUp(
        question: String,
        history: [Message]
    ) async throws -> Explanation {
        let prompt = """
        Continue this paper conversation.

        Use prior context to answer the user's follow-up.
        Give a short title that describes the user's question.

        Prior conversation:
        \(transcript(from: history))

        User follow-up:
        \(question)
        """

        let response = try await session.respond(
            to: prompt,
            generating: Explanation.self
        )

        return response.content
    }

    private func transcript(from messages: [Message]) -> String {
        guard !messages.isEmpty else {
            return "None yet."
        }

        return messages
            .sorted { $0.createdAt < $1.createdAt }
            .suffix(20)
            .map { message in
                var line = "\(message.role.capitalized): \(message.content)"

                if let selectedText = message.selectedText,
                   let action = message.action {
                    line += "\nSelected text (\(action)): \(selectedText)"
                }

                if let title = message.title {
                    line += "\nTitle: \(title)"
                }

                return line
            }
            .joined(separator: "\n\n")
    }
}
