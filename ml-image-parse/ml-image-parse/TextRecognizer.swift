//
//  TextRecognizer.swift
//  ml-image-parse
//
//  Created by Mich Ochieng on 2025-12-28.
//

import Foundation
import SwiftUI // Needed to convert sign data into image data required by Vision
import Vision

struct TextRecognizer {
    var recognizedText = ""
    var observations: [RecognizedTextObservation] = []


    init(imageResource: ImageResource) async {
        var request = RecognizeTextRequest()


        let image = UIImage(resource: imageResource)


        if let imageData = image.pngData(),
           let results = try? await request.perform(on: imageData) {
            observations = results
        }


        for observation in observations {
            let candidate = observation.topCandidates(1)


            if let observedText = candidate.first?.string {
                recognizedText += "\(observedText) "
            }
        }
    }
}
