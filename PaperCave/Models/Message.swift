//
//  Message.swift
//  PaperCave
//
//  Created by Codex on 11/09/26.
//

import Foundation
import SwiftData

enum MessageRole: String {
    case user
    case assistant
}

@Model
final class Message {

    var id: UUID
    var role: String
    var content: String
    var createdAt: Date
    var selectedText: String?
    var action: String?
    var interactionID: UUID?
    var title: String?
    var explanation: String?
    var keyTakeaway: String?
    var paper: Paper?

    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        createdAt: Date = .now,
        selectedText: String? = nil,
        action: String? = nil,
        interactionID: UUID? = nil,
        title: String? = nil,
        explanation: String? = nil,
        keyTakeaway: String? = nil,
        paper: Paper? = nil
    ) {
        self.id = id
        self.role = role.rawValue
        self.content = content
        self.createdAt = createdAt
        self.selectedText = selectedText
        self.action = action
        self.interactionID = interactionID
        self.title = title
        self.explanation = explanation
        self.keyTakeaway = keyTakeaway
        self.paper = paper
    }
}
