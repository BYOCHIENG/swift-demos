//
//  ContentView.swift
//  ml-analyze-sentiment
//
//  Created by Mich Ochieng on 2025-12-28.
//

import SwiftUI

struct ContentView: View {
    @FocusState private var textFieldIsFocused: Bool
    @State var responses: [Response] = []
    @State private var responseText: String = ""
    
    var scorer = Scorer()
    
    func saveResponse(text: String) {
            let score = scorer.score(text)
            let response = Response(text: text, score: score, language: "en")
            responses.insert(response, at: 0)
        }

    var body: some View {
        VStack {
            Text("Opinions on Hiking")
                .frame(maxWidth: .infinity)
                .font(.title)
                .padding(.top, 24)
            ScrollView {
                ChartView(responses: responses)
                ForEach(responses) { response in
                    ResponseView(response: response)
                }
            }
            HStack {
                TextField("What do you think about hiking?", text: $responseText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(5)
                Button("Done") {
                    guard !responseText.isEmpty else { return }
                    saveResponse(text: responseText)
                    responseText = ""
                    textFieldIsFocused = false
                    }
                .padding(.horizontal, 4)
            }
            .padding(.bottom, 8)
        }
        .onAppear {
            for response in Response.sampleResponses {
                saveResponse(text: response)
            }
        }
        .padding(.horizontal)
        .background(Color(white: 0.94))
    }
}

#Preview {
    ContentView()
}
