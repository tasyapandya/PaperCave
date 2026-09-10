//
//  InteractionDetailView.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 08/09/26.
//

import SwiftUI
import SwiftData

struct InteractionDetailView: View {

    @Environment(\.modelContext)
    private var modelContext

    let interaction: Interaction

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 20
            ) {

                HStack {

                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {

                        Text(
                            interaction.action
                                .capitalized
                        )
                        .font(.title2)
                        .fontWeight(.semibold)

                        if let paperTitle =
                            interaction.paper?.title {

                            Text(paperTitle)
                                .foregroundStyle(
                                    .secondary
                                )
                        }
                    }

                    Spacer()

                    Button {

                        interaction
                            .isSaved
                            .toggle()

                    } label: {

                        Image(
                            systemName:
                                interaction.isSaved
                                ? "bookmark.fill"
                                : "bookmark"
                        )
                        .font(.title3)
                    }
                }

                Divider()

                section(
                    title: "Selected Text",
                    content:
                        interaction.selectedText
                )

                Divider()

                section(
                    title: "Explanation",
                    content:
                        interaction.explanation
                )

                section(
                    title: "Key Takeaway",
                    content:
                        interaction.keyTakeaway
                )
                
                Divider()

                Text(
                    interaction.createdAt,
                    format: .dateTime
                        .day()
                        .month()
                        .year()
                        .hour()
                        .minute()
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Interaction")
    }

    @ViewBuilder
    private func section(
        title: String,
        content: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Text(content)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
    }
}
