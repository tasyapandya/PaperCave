//
//  PDFKitView.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 06/09/26.
//
import SwiftUI
import PDFKit

struct PDFKitView: NSViewRepresentable {
    // let document: PDFDocument
    let url: URL
    @Binding var selectedText: String
    
    func makeNSView(context: Context) -> PDFView {
        // TODO:
        // 1. buat PDFView
        let pdfView = PDFView()
        // 2. assign document
        pdfView.document = PDFDocument(url: url)
        // 3. set autoScales
        pdfView.autoScales = true
        // 4. Add Observer to selected text
        NotificationCenter.default.addObserver(
            context.coordinator, selector: #selector(Coordinator.selectionChanged(_:)), name: .PDFViewSelectionChanged, object: pdfView)
        // 4. return PDFView
        return pdfView
    }

    func updateNSView(_ pdfView: PDFView, context: Context) {
        // TODO:
        // update document jika berubah
       // pdfView.document = PDFDocument(url: url)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedText: $selectedText)
    }
    
    
    class Coordinator: NSObject {
        @Binding var selectedText: String
        
        init(selectedText: Binding<String>) {
            self._selectedText = selectedText
        }
        
        // TODO:
        // function untuk menerima notification
        // lalu ambil currentSelection dari PDFView
        @objc func selectionChanged(_ notification: Notification) {
            guard let pdfView = notification.object as? PDFView
                else { return
            }
            selectedText = pdfView.currentSelection?.string ?? ""
        }
    }
}
