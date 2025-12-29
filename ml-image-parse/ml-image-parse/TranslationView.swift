//
//  TranslationView.swift
//  ml-image-parse
//
//  Created by Mich Ochieng on 2025-12-28.
//

import SwiftUI
import Translation


struct TranslationView: View {
    var text: String
    var isProcessing: Bool
    @State private var showingTranslation = false


    var body: some View {
        VStack {
            Text("Identified Text")
                .font(.subheadline.bold())
                .textCase(.uppercase)
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)


            Text(text)
                .frame(maxWidth: .infinity,
                       alignment: .topLeading)
                .padding()
                .background(Color(white: 0.9))
                .overlay {
                    if isProcessing {
                        ProgressView()
                    }
                }
                .translationPresentation(isPresented: $showingTranslation, text: text)

        }
    }
}


#Preview {
    TranslationView(text: "Caution, falling rocks", isProcessing: false)
}


#Preview {
    TranslationView(text: "", isProcessing: true)
}
