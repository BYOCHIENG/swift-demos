//
//  FrameView.swift
//  ml-recognize-doc-request
//
//  Created by Mich Ochieng on 2026-01-17.
//

import SwiftUI

struct FrameView: View {
    var image: CGImage?
    private let label = Text("Frame")
    var body: some View {
        if let image = image {
            Image(image, scale: 1.0, orientation: .up, label: label)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        } else {
            Color.blue
        }
    }
}

#Preview {
    FrameView()
}
