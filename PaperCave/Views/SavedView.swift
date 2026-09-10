//
//  SavedView.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 09/09/26.
//


import SwiftUI
import SwiftData

struct SavedView: View {

    @Query(
        filter: #Predicate<Interaction> {
            $0.isSaved == true
        },
        sort: \Interaction.createdAt,
        order: .reverse
    )
    private var savedInteractions:
        [Interaction]

    var body: some View {

        NavigationStack {

            Group {

                if savedInteractions.isEmpty {

                    ContentUnavailableView(
                        "No Saved Sources",
                        systemImage: "bookmark",
                        description: Text(
                            "Save useful responses and they will appear here."
                        )
                    )

                } else {

                    List(
                        savedInteractions
                    ) { interaction in

                        NavigationLink {

                            InteractionDetailView(
                                interaction:
                                    interaction
                            )

                        } label: {

                            InteractionRowView(
                                interaction:
                                    interaction
                            )
                        }
                    }
                }
            }
            .navigationTitle("Saved")
        }
    }
}