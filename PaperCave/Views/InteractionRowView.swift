//
//  InteractionRowView.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 09/09/26.
//


import SwiftUI

struct InteractionRowView: View {

    let interaction: Interaction

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            HStack {

                Text(
                    interaction.action.capitalized
                )
                .font(.caption)
                .fontWeight(.semibold)

                Spacer()

                if interaction.isSaved {

                    Image(
                        systemName: "bookmark.fill"
                    )
                    .font(.caption)
                }
            }

            Text(interaction.selectedText)
                .font(.headline)
                .lineLimit(2)

            if let paperTitle =
                interaction.paper?.title {

                Text(paperTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(
                interaction.createdAt,
                format: .dateTime
                    .day()
                    .month()
                    .hour()
                    .minute()
            )
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}