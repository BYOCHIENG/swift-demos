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
            let displayRect = calculateDisplayRect(imageSize: imageSize, in: geometry.size)
            
            ForEach(Array(observations.enumerated()), id: \.offset) { index, observation in
                // Draw bounding boxes for each type of content
                let document = observation.document
                
                // Text bounding boxes (green)
                BoundsRegion(normalizedRegion: document.text.boundingRegion)
                    .stroke(Color.green, lineWidth: 3)
                    .frame(width: displayRect.width, height: displayRect.height)
                    .offset(x: displayRect.minX, y: displayRect.minY)
                
                // Table bounding boxes (blue)
                ForEach(Array(document.tables.enumerated()), id: \.offset) { _, table in
                    BoundsRegion(normalizedRegion: table.boundingRegion)
                        .stroke(Color.blue, lineWidth: 3)
                        .frame(width: displayRect.width, height: displayRect.height)
                        .offset(x: displayRect.minX, y: displayRect.minY)
                }
                
                // List bounding boxes (orange)
                ForEach(Array(document.lists.enumerated()), id: \.offset) { _, list in
                    BoundsRegion(normalizedRegion: list.boundingRegion)
                        .stroke(Color.orange, lineWidth: 3)
                        .frame(width: displayRect.width, height: displayRect.height)
                        .offset(x: displayRect.minX, y: displayRect.minY)
                }
                
                // Barcode bounding boxes (purple)
                ForEach(Array(document.barcodes.enumerated()), id: \.offset) { _, barcode in
                    BoundsRegion(normalizedRegion: barcode.boundingRegion)
                        .stroke(Color.purple, lineWidth: 3)
                        .frame(width: displayRect.width, height: displayRect.height)
                        .offset(x: displayRect.minX, y: displayRect.minY)
                }
            }
        }
    }
    
    // Calculate the actual display rect of the scaled image within the container
    private func calculateDisplayRect(imageSize: CGSize, in containerSize: CGSize) -> CGRect {
        let imageAspect = imageSize.width / imageSize.height
        let containerAspect = containerSize.width / containerSize.height
        
        let displaySize: CGSize
        if imageAspect > containerAspect {
            // Image is wider - fit to width
            displaySize = CGSize(
                width: containerSize.width,
                height: containerSize.width / imageAspect
            )
        } else {
            // Image is taller - fit to height
            displaySize = CGSize(
                width: containerSize.height * imageAspect,
                height: containerSize.height
            )
        }
        
        let origin = CGPoint(
            x: (containerSize.width - displaySize.width) / 2,
            y: (containerSize.height - displaySize.height) / 2
        )
        
        return CGRect(origin: origin, size: displaySize)
    }
}
