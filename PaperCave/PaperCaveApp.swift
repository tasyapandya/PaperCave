//
//  PaperCaveApp.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 03/09/26.
//

import SwiftUI
import SwiftData

@main
struct PaperCaveApp: App {

    var body: some Scene {

        WindowGroup {
            RootView()
        }
        .modelContainer(
            for: [
                Paper.self,
                Interaction.self,
                Message.self
            ]
        )
    }
}
