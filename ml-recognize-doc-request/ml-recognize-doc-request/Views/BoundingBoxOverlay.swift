//
//  BoundingBoxOverlay.swift
//  ml-recognize-doc-request
//
//  Created by Mich Ochieng on 2026-03-31.
//

import SwiftUI
import Vision

struct BoundingBoxOverlay: View {
    let observations: [DocumentObservation]
    let imageSize: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(Array(observations.enumerated()), id: \.offset) { index, observation in
                // Draw document-level bounding box
                if let boundingBox = observation.boundingBox {
                    BoundsRect(normalizedRect: boundingBox)
                        .stroke(Color.green, lineWidth: 3)
                }
                
                // Optionally, draw bounding boxes for individual text blocks
                ForEach(Array(observation.document?.blocks.enumerated() ?? [].enumerated()), id: \.offset) { blockIndex, block in
                    if let blockBoundingBox = block.boundingBox {
                        BoundsRect(normalizedRect: blockBoundingBox)
                            .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                    }
                }
            }
        }
    }
}
