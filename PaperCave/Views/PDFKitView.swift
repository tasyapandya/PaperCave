//
//  PDFKitView.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 06/09/26.
//
import SwiftUI
import PDFKit

struct PDFSelectionInfo {
    let text: String
    let pageIndex: Int
    let bounds: CGRect
}

struct PDFHighlightItem: Identifiable, Equatable {
    let id: UUID
    let pageIndex: Int
    let bounds: CGRect
}

enum PDFCommand: Equatable {
    case zoomOut
    case fit
    case zoomIn
}

struct PDFKitView: NSViewRepresentable {

    let url: URL

    @Binding var selectionInfo: PDFSelectionInfo?

    let highlights: [PDFHighlightItem]
    let showHighlights: Bool

    @Binding var command: PDFCommand?

    let onHighlightTapped: (UUID) -> Void

    func makeNSView(context: Context) -> PDFView {

        let pdfView = PDFView()

        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true

        context.coordinator.pdfView = pdfView

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(
                Coordinator.selectionChanged(_:)
            ),
            name: .PDFViewSelectionChanged,
            object: pdfView
        )

        let clickGesture =
            NSClickGestureRecognizer(
                target: context.coordinator,
                action: #selector(
                    Coordinator.handleClick(_:)
                )
            )

        pdfView.addGestureRecognizer(
            clickGesture
        )

        context.coordinator.renderHighlights(
            highlights,
            showHighlights: showHighlights
        )

        return pdfView
    }

    func updateNSView(
        _ pdfView: PDFView,
        context: Context
    ) {

        context.coordinator.highlights =
            highlights

        context.coordinator.showHighlights =
            showHighlights

        context.coordinator.onHighlightTapped =
            onHighlightTapped

        if let command {
            context.coordinator.run(command)
            DispatchQueue.main.async {
                self.command = nil
            }
        }

        context.coordinator.renderHighlights(
            highlights,
            showHighlights: showHighlights
        )
    }

    func makeCoordinator() -> Coordinator {

        Coordinator(
            selectionInfo: $selectionInfo,
            highlights: highlights,
            showHighlights: showHighlights,
            command: $command,
            onHighlightTapped:
                onHighlightTapped
        )
    }


    class Coordinator: NSObject {

        @Binding
        var selectionInfo: PDFSelectionInfo?

        weak var pdfView: PDFView?

        var highlights: [PDFHighlightItem]

        var showHighlights: Bool

        @Binding
        var command: PDFCommand?

        var onHighlightTapped:
            (UUID) -> Void

        private var annotationMap:
            [PDFAnnotation: UUID] = [:]


        init(
            selectionInfo:
                Binding<PDFSelectionInfo?>,
            highlights: [PDFHighlightItem],
            showHighlights: Bool,
            command: Binding<PDFCommand?>,
            onHighlightTapped:
                @escaping (UUID) -> Void
        ) {

            self._selectionInfo =
                selectionInfo

            self.highlights =
                highlights

            self.showHighlights =
                showHighlights

            self._command =
                command

            self.onHighlightTapped =
                onHighlightTapped
        }

        func run(_ command: PDFCommand) {
            guard let pdfView else {
                return
            }

            switch command {
            case .zoomOut:
                pdfView.zoomOut(nil)

            case .fit:
                pdfView.autoScales = true

            case .zoomIn:
                pdfView.zoomIn(nil)
            }
        }


        @objc
        func selectionChanged(
            _ notification: Notification
        ) {

            guard
                let pdfView =
                    notification.object
                        as? PDFView
            else {
                return
            }

            guard
                let selection =
                    pdfView.currentSelection,
                let text =
                    selection.string?
                        .trimmingCharacters(
                            in:
                                .whitespacesAndNewlines
                        ),
                !text.isEmpty
            else {

                selectionInfo = nil
                return
            }

            guard
                let page =
                    selection.pages.first,
                let document =
                    pdfView.document
            else {
                return
            }

            let pageIndex =
                document.index(
                    for: page
                )

            let bounds =
                selection.bounds(
                    for: page
                )

            selectionInfo =
                PDFSelectionInfo(
                    text: text,
                    pageIndex: pageIndex,
                    bounds: bounds
                )
        }


        func renderHighlights(
            _ highlights: [PDFHighlightItem],
            showHighlights: Bool
        ) {

            guard
                let pdfView,
                let document =
                    pdfView.document
            else {
                return
            }

            removeRenderedHighlights()

            guard showHighlights else {
                return
            }

            for item in highlights {

                guard
                    let page =
                        document.page(
                            at: item.pageIndex
                        )
                else {
                    continue
                }

                let annotation =
                    PDFAnnotation(
                        bounds:
                            item.bounds,
                        forType:
                            .highlight,
                        withProperties:
                            nil
                    )

                page.addAnnotation(
                    annotation
                )

                annotationMap[
                    annotation
                ] = item.id
            }
        }


        private func removeRenderedHighlights() {

            guard
                let pdfView,
                let document =
                    pdfView.document
            else {
                return
            }

            for pageIndex
                in 0..<document.pageCount {

                guard
                    let page =
                        document.page(
                            at: pageIndex
                        )
                else {
                    continue
                }

                for annotation
                    in page.annotations {

                    if annotationMap[
                        annotation
                    ] != nil {

                        page.removeAnnotation(
                            annotation
                        )
                    }
                }
            }

            annotationMap.removeAll()
        }


        @objc
        func handleClick(
            _ gesture:
                NSClickGestureRecognizer
        ) {

            guard
                let pdfView,
                gesture.state == .ended
            else {
                return
            }

            let viewPoint =
                gesture.location(
                    in: pdfView
                )

            guard
                let page =
                    pdfView.page(
                        for: viewPoint,
                        nearest: true
                    )
            else {
                return
            }

            let pagePoint =
                pdfView.convert(
                    viewPoint,
                    to: page
                )

            for annotation
                in page.annotations {

                guard
                    annotation.bounds
                        .contains(
                            pagePoint
                        )
                else {
                    continue
                }

                guard
                    let interactionID =
                        annotationMap[
                            annotation
                        ]
                else {
                    continue
                }

                onHighlightTapped(
                    interactionID
                )

                return
            }
        }
    }
}
