//
//  HistoryView.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 08/09/26.
//


import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(
        sort: \Interaction.createdAt,
        order: .reverse
    )
    private var interactions: [Interaction]

    var body: some View {

        NavigationStack {
            List(interactions) { interaction in
                NavigationLink {
                    InteractionDetailView(
                        interaction: interaction
                    )
                } label: {
                    VStack(alignment: .leading) {
                        Text(interaction.selectedText)
                        Text(interaction.action)
                        Text(
                            interaction.createdAt,
                            style: .date
                        )
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}
