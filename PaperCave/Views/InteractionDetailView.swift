//
//  InteractionDetailView.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 08/09/26.
//


import SwiftUI

struct InteractionDetailView: View {

    let interaction: Interaction

    var body: some View {

        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 16
            ) {
                Text(interaction.action)
                    .font(.headline)
                Text("Selected Text")
                    .font(.caption)
                Text(interaction.selectedText)

                Divider()

                Text("Response")
                    .font(.caption)
                Text(interaction.response)
                Button {
                    // TODO:
                    // Toggle isSaved
                    
                } label: {
                    Label(
                        interaction.isSaved
                            ? "Saved"
                            : "Save as Source",
                        systemImage:
                            interaction.isSaved
                            ? "bookmark.fill"
                            : "bookmark"
                    )
                }
            }
            .padding()
        }
    }
}
