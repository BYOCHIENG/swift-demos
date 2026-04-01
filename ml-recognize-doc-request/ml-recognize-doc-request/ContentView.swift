//
//  ContentView.swift
//  ml-recognize-doc-request
//
//  Created by Mich Ochieng on 2025-12-28.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var model = FrameHandler()
    @State private var showDetail = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            FrameView(image: model.frame)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .zIndex(0)
            
            if model.isProcessing {
                ProgressView("Scanning...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.bottom, 40)
            } else {
                Button {
                    model.capturePhoto()
                } label: {
                    Circle()
                        .fill(.white)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle().stroke(.gray, lineWidth: 2)
                                .frame(width: 60, height: 60)
                        )
                }
                .padding(.bottom, 30)
            }
        }
        .onChange(of: model.receipt) {
            if model.receipt != nil {
                showDetail = true
            }
        }
        .fullScreenCover(isPresented: $showDetail) {
            if let receipt = model.receipt {
                ReceiptDetailView(receipt: receipt) {
                    model.receipt = nil
                    showDetail = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
