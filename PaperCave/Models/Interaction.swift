//
//  Interaction.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 08/09/26.
//


import Foundation
import SwiftData

@Model
final class Interaction {
    var selectedText: String
    var response: String
    var action: String
    var pageNumber: Int?
    var createdAt: Date
    var isSaved: Bool
    var paper: Paper?

    init(
        selectedText: String,
        response: String,
        action: String,
        pageNumber: Int? = nil,
        createdAt: Date = .now,
        isSaved: Bool = false,
        paper: Paper? = nil
    ) {
        self.selectedText = selectedText
        self.response = response
        self.action = action
        self.pageNumber = pageNumber
        self.createdAt = createdAt
        self.isSaved = isSaved
        self.paper = paper
    }
}
