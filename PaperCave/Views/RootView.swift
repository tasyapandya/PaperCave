//
//  RootView.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 09/09/26.
//


import SwiftUI

enum AppDestination {
    case reader
    case saved
    case history
}

struct RootView: View {

    @State private var destination: AppDestination = .reader

    var body: some View {

        HStack(spacing: 0) {

            AppSidebar(destination: $destination)

            Group {
                switch destination {
                case .reader:
                    MyPDFView()

                case .saved:
                    SavedView()

                case .history:
                    HistoryView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(PaperCaveStyle.background)
    }
}

private struct AppSidebar: View {

    @Binding var destination: AppDestination

    var body: some View {
        VStack(spacing: 28) {

            Image("IconPNG")
                .resizable()
                .scaledToFit()
                .frame(width: 34, height: 34)
                .padding(.top, 28)

            VStack(spacing: 18) {
                sidebarButton(
                    destination: .reader,
                    icon: "square.and.pencil",
                    help: "New Session"
                )

                sidebarButton(
                    destination: .saved,
                    icon: "bookmark",
                    help: "Saved"
                )

                sidebarButton(
                    destination: .history,
                    icon: "clock.arrow.circlepath",
                    help: "History"
                )
            }

            Spacer()
        }
        .frame(width: 82)
        .frame(maxHeight: .infinity)
        .background(PaperCaveStyle.background)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(PaperCaveStyle.separator)
                .frame(width: 1)
        }
    }

    private func sidebarButton(
        destination buttonDestination: AppDestination,
        icon: String,
        help: String
    ) -> some View {
        Button {
            destination = buttonDestination
        } label: {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(
                    destination == buttonDestination
                    ? PaperCaveStyle.text
                    : PaperCaveStyle.mutedText
                )
                .frame(width: 42, height: 42)
                .background {
                    if destination == buttonDestination {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(PaperCaveStyle.selected)
                    }
                }
        }
        .buttonStyle(.plain)
        .help(help)
    }
}

enum PaperCaveStyle {
    static let background = Color(red: 1.0, green: 0.976, blue: 0.957)
    static let panel = Color(red: 1.0, green: 0.993, blue: 0.988)
    static let selected = Color(red: 1.0, green: 0.91, blue: 0.84)
    static let separator = Color(red: 1.0, green: 0.86, blue: 0.74)
    static let text = Color(red: 0.325, green: 0.153, blue: 0.008)
    static let mutedText = Color(red: 0.55, green: 0.46, blue: 0.39)
}
