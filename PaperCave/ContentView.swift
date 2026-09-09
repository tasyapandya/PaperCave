//
//  ContentView.swift
//  PaperCave
//
//  Created by Tasya Pandya Latifa on 03/09/26.
//

import SwiftUI
import FoundationModels
import PDFKit


struct ContentView: View {

    @State private var responseText: String = ""
    @State private var isLoading: Bool = false
    @State private var pdf: PDFDocument?
    
    var body: some View {
        MyPDFView()
    }
}

#Preview {
    ContentView()
}
