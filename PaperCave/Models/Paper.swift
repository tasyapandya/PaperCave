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
    
    // TODO:
    // Simpan identifier/path PDF kalau memang nanti dibutuhkan.
    @Relationship(deleteRule: .cascade)
    var interactions: [Interaction] = []

    init(title: String) {
        self.title = title
    }
}
