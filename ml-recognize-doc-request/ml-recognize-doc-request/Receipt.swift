//
//  Receipt.swift
//  ml-recognize-doc-request
//
//  Created by Mich Ochieng on 2025-12-28.
//

import CoreGraphics
import Vision

struct Receipt: Equatable {
    let image: CGImage
    let title: String?
    let fullText: String
    
    init(image: CGImage, observations: [DocumentObservation]) {
        self.image = image
        
        let container = observations.first?.document
        self.title = container?.title?.transcript
        self.fullText = container?.text.transcript ?? ""
    }
    
    static func == (lhs: Receipt, rhs: Receipt) -> Bool {
        lhs.image === rhs.image
    }
}
