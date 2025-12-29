//
//  Response.swift
//  ml-analyze-sentiment
//
//  Created by Mich Ochieng on 2025-12-28.
//
import Foundation


struct Response: Identifiable {
    var id = UUID()
    var text: String
    var score: Double
    var language: String

    var sentiment: Sentiment {
        Sentiment(score)
    }

    static let sampleResponses: [String] = [
        "The outdoors is my happy place, so give me a trail and some boots and I feel great!",
        "I don't mind going for a walk, but hiking requires too much gear and planning.",
        "Hiking seems like a pretty good way to stay in shape.",
        "I love everything about hiking: the fresh air, the exercise, the feeling of accomplishment. When can we go next?",
        "There’s a nice, paved trail near my house that I like, but I don't need to get out in the woods.",
        "I enjoy hard hikes. When my heart is pumping and I'm being challenged, I feel great.",
        "Last time I went hiking I got a thousand bug bites. You won't find me on a trail any time soon!"
    ]
}
