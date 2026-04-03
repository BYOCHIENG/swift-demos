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
                    
                    // Structured Data Section
                    VStack(alignment: .leading, spacing: 12) {
                        if let businessName = receipt.businessName {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Business")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(businessName)
                                    .font(.title2)
                                    .bold()
                            }
                        }
                        
                        if let date = receipt.date {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Date")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(date)
                                    .font(.body)
                            }
                        }
                        
                        if !receipt.lineItems.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Items")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                ForEach(Array(receipt.lineItems.enumerated()), id: \.offset) { index, item in
                                    HStack {
                                        Text(item.description)
                                            .font(.body)
                                        Spacer()
                                        if let price = item.price {
                                            Text(price)
                                                .font(.body)
                                                .bold()
                                        }
                                    }
                                    .padding(.vertical, 4)
                                    
                                    if index < receipt.lineItems.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        if let total = receipt.total {
                            HStack {
                                Text("Total")
                                    .font(.title3)
                                    .bold()
                                Spacer()
                                Text(total)
                                    .font(.title3)
                                    .bold()
                            }
                            .padding()
                            .background(Color.green.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        Divider()
                            .padding(.vertical)
                        
                        // Raw text fallback
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Full Text")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(receipt.fullText)
                                .font(.body)
                        }
                    }
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
