//
//  BoundsRect.swift
//  ml-recognize-doc-request
//
//  Created by Mich Ochieng on 2026-03-31.
//

import Foundation
import SwiftUI
import Vision


struct BoundsRect: Shape {
    let normalizedRect: NormalizedRect

    func path(in rect: CGRect) -> Path {
        let imageCoordinatesRect = normalizedRect.toImageCoordinates(rect.size, origin: .upperLeft)
        return Path(imageCoordinatesRect)
    }
}

struct BoundsRegion: Shape {
    let normalizedRegion: NormalizedRegion
    
    func path(in rect: CGRect) -> Path {
        // Get the bounding box from the region
        let normalizedRect = normalizedRegion.boundingBox
        let imageCoordinatesRect = normalizedRect.toImageCoordinates(rect.size, origin: .upperLeft)
        return Path(imageCoordinatesRect)
    }
}
