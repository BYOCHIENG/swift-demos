//
//  ContentView.swift
//  ml-image-parse
//
//  Created by Mich Ochieng on 2025-12-28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 50) {
                Text("Tap to select an image to parse")
                    .font(.headline)
                
                ImageGalleryView()
                Spacer()
            }
            .navigationTitle("Image Parsing")
        }
    }
}


#Preview {
    ContentView()
}
