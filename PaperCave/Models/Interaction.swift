//
//  Interaction.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 08/09/26.
//
import Foundation
import SwiftData
import CoreGraphics

@Model
final class Interaction {

    var id: UUID

    var selectedText: String

    var explanation: String
    var keyTakeaway: String

    var action: String

    var pageIndex: Int?

    var highlightX: Double?
    var highlightY: Double?
    var highlightWidth: Double?
    var highlightHeight: Double?

    var createdAt: Date

    var isSaved: Bool

    var paper: Paper?

    init(
        id: UUID = UUID(),

        selectedText: String,

        explanation: String,
        keyTakeaway: String,

        action: String,

        pageIndex: Int? = nil,

        highlightX: Double? = nil,
        highlightY: Double? = nil,
        highlightWidth: Double? = nil,
        highlightHeight: Double? = nil,

        createdAt: Date = .now,

        isSaved: Bool = false,

        paper: Paper? = nil
    ) {

        self.id = id

        self.selectedText = selectedText

        self.explanation = explanation
        self.keyTakeaway = keyTakeaway

        self.action = action

        self.pageIndex = pageIndex

        self.highlightX = highlightX
        self.highlightY = highlightY
        self.highlightWidth = highlightWidth
        self.highlightHeight = highlightHeight

        self.createdAt = createdAt

        self.isSaved = isSaved

        self.paper = paper
    }
    
    var highlightBounds: CGRect? {
        guard
            let x = highlightX,
            let y = highlightY,
            let width = highlightWidth,
            let height = highlightHeight
        else {
            return nil
        }

        return CGRect(
            x: x,
            y: y,
            width: width,
            height: height
        )
    }
}
