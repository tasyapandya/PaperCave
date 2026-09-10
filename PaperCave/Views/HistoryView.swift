//
//  HistoryView.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 08/09/26.
//


import SwiftUI
import SwiftData

struct HistoryView: View {

    @Environment(\.modelContext)
    private var modelContext

    @Query(
        sort: \Interaction.createdAt,
        order: .reverse
    )
    private var interactions: [Interaction]

    var body: some View {

        NavigationStack {

            Group {

                if interactions.isEmpty {

                    ContentUnavailableView(
                        "No History Yet",
                        systemImage: "clock",
                        description: Text(
                            "Your explanations and simplifications will appear here."
                        )
                    )

                } else {

                    List {

                        ForEach(
                            interactions
                        ) { interaction in

                            NavigationLink {

                                InteractionDetailView(
                                    interaction: interaction
                                )

                            } label: {

                                InteractionRowView(
                                    interaction: interaction
                                )
                            }
                        }
                        .onDelete(
                            perform: deleteInteractions
                        )
                    }
                }
            }
            .navigationTitle("History")
        }
    }

    private func deleteInteractions(
        at offsets: IndexSet
    ) {

        for index in offsets {

            let interaction =
                interactions[index]

            modelContext.delete(
                interaction
            )
        }
    }
}
