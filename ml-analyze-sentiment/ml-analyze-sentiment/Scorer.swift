//
//  Scorer.swift
//  ml-analyze-sentiment
//
//  Created by Mich Ochieng on 2025-12-28.
//

import Foundation
import NaturalLanguage


class Scorer {
    let tagger = NLTagger(tagSchemes: [.sentimentScore,.language])


    func score(_ text: String) -> Double {
        var sentimentScore = 9.99
        tagger.string = text
        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .paragraph,
            scheme: .sentimentScore,
            options: []) { sentimentTag, _ in
                if let sentimentString = sentimentTag?.rawValue,
                   let score = Double(sentimentString) {
                    sentimentScore = score
                    return true
                }
                return false
            }
        return sentimentScore
    }
    
    func getLanguage(_ text: String) -> String {
        var language = "Unknown"
        tagger.string = text
        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .paragraph,
            scheme: .language,
            options: []) { languageTag, _ in
                if let languageString = languageTag?.rawValue {
                    language = languageString
                    return true
                }
                return false
            }
        
        return language
    }
}
