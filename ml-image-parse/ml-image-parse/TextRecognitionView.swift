//
//  TextRecognitionView.swift
//  ml-image-parse
//
//  Created by Mich Ochieng on 2025-12-28.
//

import SwiftUI
import Vision


struct TextRecognitionView: View {
    let imageResource: ImageResource
    let boundingColor = Color(red: 1.00, green: 0.00, blue: 0.85)
    let lowConfColour = Color(red: 1.00, green: 0.00, blue: 0.00)
    let highConfColour = Color(red: 0.00, green: 1.00, blue: 0.00)
    @State private var textRecognizer: TextRecognizer?


    var body: some View {
        VStack {
            Image(imageResource)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .task {
                    textRecognizer = await TextRecognizer(imageResource: imageResource)
                }
                .overlay {
                    if let observations = textRecognizer?.observations {
                        ForEach(observations, id: \.uuid) { observation in
                            if observation.confidence >= 1 {
                                BoundsRect(normalizedRect: observation.boundingBox)
                                    .stroke(highConfColour, lineWidth: 3)
                            } else {
                                BoundsRect(normalizedRect: observation.boundingBox)
                                    .stroke(lowConfColour, lineWidth: 3)
                            }
                        }
                    }
                }
            Spacer()


            TranslationView(text: textRecognizer?.recognizedText ?? "", isProcessing: isProcessing)
        }
        .padding()
        .navigationTitle("Image Info")
    }


    private var isProcessing: Bool {
        textRecognizer == nil
    }
}


#Preview {
    NavigationStack {
        TextRecognitionView(imageResource: .receipt2)
            .navigationBarTitleDisplayMode(.inline)
    }
}
