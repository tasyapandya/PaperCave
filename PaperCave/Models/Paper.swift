//
//  Paper.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 08/09/26.
//


import Foundation
import SwiftData

@Model
final class Paper {

    var title: String
    var createdAt: Date

    @Relationship(
        deleteRule: .cascade,
        inverse: \Interaction.paper
    )
    var interactions: [Interaction] = []

    init(
        title: String,
        createdAt: Date = .now
    ) {
        self.title = title
        self.createdAt = createdAt
    }
}
