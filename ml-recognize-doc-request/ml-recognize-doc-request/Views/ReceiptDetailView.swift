//
//  ReceiptDetailView.swift
//  ml-recognize-doc-request
//
//  Created by Mich Ochieng on 2025-12-28.
//

import SwiftUI

struct ReceiptDetailView: View {
    let receipt: Receipt
    var onDismiss: () -> Void
    @State private var showBoundingBoxes = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Image with bounding boxes drawn directly on it
                    if showBoundingBoxes, let annotatedImage = receipt.annotatedImage() {
                        Image(annotatedImage, scale: 1.0, orientation: .right, label: Text("Captured"))
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image(receipt.image, scale: 1.0, orientation: .right, label: Text("Captured"))
                            .resizable()
                            .scaledToFit()
                    }
                    
                    if let title = receipt.title {
                        Text(title)
                            .font(.title2)
                            .bold()
                    }
                    
                    Text(receipt.fullText)
                        .font(.body)
                }
                .padding()
            }
            .navigationTitle("Scan Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done", action: onDismiss)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showBoundingBoxes.toggle()
                    } label: {
                        Image(systemName: showBoundingBoxes ? "eye.fill" : "eye.slash")
                    }
                }
            }
        }
    }
}
