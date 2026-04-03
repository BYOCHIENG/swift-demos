//
//  Receipt.swift
//  ml-recognize-doc-request
//
//  Created by Mich Ochieng on 2025-12-28.
//

import CoreGraphics
import Vision
import UIKit

struct Receipt: Equatable {
    let image: CGImage
    let title: String?
    let fullText: String
    let observations: [DocumentObservation]
    
    // Parsed receipt data
    let businessName: String?
    let date: String?
    let lineItems: [LineItem]
    let total: String?
    
    struct LineItem {
        let description: String
        let price: String?
    }
    
    init(image: CGImage, observations: [DocumentObservation]) {
        self.image = image
        self.observations = observations
        let container = observations.first?.document
        self.title = container?.title?.transcript
        self.fullText = container?.text.transcript ?? ""
        
        // Parse structured data
        self.businessName = Self.extractBusinessName(from: observations)
        self.date = Self.extractDate(from: observations)
        self.lineItems = Self.extractLineItems(from: observations)
        self.total = Self.extractTotal(from: observations)
        
        // Debug: Print structure
        Self.printObservationStructure(observations)
    }
    
    // MARK: - Debug Helpers
    
    static func printObservationStructure(_ observations: [DocumentObservation]) {
        print("\n========== DOCUMENT OBSERVATION STRUCTURE ==========")
        
        for (index, observation) in observations.enumerated() {
            print("\n📄 Observation \(index):")
            let document = observation.document
            
            // Document metadata
            print("  📋 Title: \(document.title?.transcript ?? "none")")
            print("  📝 Full Text Preview: \(String(document.text.transcript.prefix(100)))...")
            
            // Tables
            print("\n  📊 Tables: \(document.tables.count)")
            for (tableIndex, table) in document.tables.enumerated() {
                print("    Table \(tableIndex): \(table.rows.count) rows")
                printTableStructure(table, indent: "      ")
            }
            
            // Lists
            print("\n  📋 Lists: \(document.lists.count)")
            for (listIndex, list) in document.lists.enumerated() {
                print("    List \(listIndex): \(list.items.count) items")
                for (itemIndex, item) in list.items.enumerated() {
                    print("      Item \(itemIndex): \(item.content.text.transcript)")
                }
            }
            
            // Barcodes
            print("\n  📱 Barcodes: \(document.barcodes.count)")
            for (barcodeIndex, barcode) in document.barcodes.enumerated() {
                print("    Barcode \(barcodeIndex): \(barcode.payloadData?.base64EncodedString() ?? "no payload")")
            }
            
            // Text content
            print("\n  📝 Full Text Length: \(document.text.transcript.count) characters")
        }
        
        print("\n====================================================\n")
    }
    
    static func printTableStructure(_ table: DocumentObservation.Container.Table, indent: String) {
        for (rowIndex, row) in table.rows.enumerated() {
            print("\(indent)Row \(rowIndex): \(row.count) cells")
            for (cellIndex, cell) in row.enumerated() {
                let cellText = cell.content.text.transcript
                print("\(indent)  Cell[\(rowIndex),\(cellIndex)]: \(cellText)")
                
                // Check for nested tables
                if !cell.content.tables.isEmpty {
                    print("\(indent)    ⚠️ Contains \(cell.content.tables.count) nested tables")
                }
            }
        }
    }
    
    // MARK: - Data Extraction
    
    static func extractBusinessName(from observations: [DocumentObservation]) -> String? {
        guard let document = observations.first?.document else { return nil }
        
        // Strategy 1: Use title if available
        if let title = document.title?.transcript, !title.isEmpty {
            return title
        }
        
        // Strategy 2: First line of text (often the business name)
        let fullText = document.text.transcript
        let lines = fullText.components(separatedBy: .newlines)
        if let firstLine = lines.first(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty }) {
            return firstLine.trimmingCharacters(in: .whitespaces)
        }
        
        return nil
    }
    
    static func extractDate(from observations: [DocumentObservation]) -> String? {
        guard let document = observations.first?.document else { return nil }
        
        let fullText = document.text.transcript
        
        // Look for date patterns
        let datePatterns = [
            #"\d{1,2}/\d{1,2}/\d{2,4}"#,  // MM/DD/YYYY or M/D/YY
            #"\d{4}-\d{2}-\d{2}"#,         // YYYY-MM-DD
            #"[A-Z][a-z]+ \d{1,2},? \d{4}"# // Month DD, YYYY
        ]
        
        for pattern in datePatterns {
            if let range = fullText.range(of: pattern, options: String.CompareOptions.regularExpression) {
                return String(fullText[range])
            }
        }
        
        return nil
    }
    
    static func extractLineItems(from observations: [DocumentObservation]) -> [LineItem] {
        guard let document = observations.first?.document else { return [] }
        
        var items: [LineItem] = []
        
        // Strategy: Look for tables (receipts often structure items as tables)
        for table in document.tables {
            for row in table.rows {
                guard row.count >= 2 else { continue } // Need at least description and price
                
                let description = row[0].content.text.transcript
                let price = row.count > 1 ? row[row.count - 1].content.text.transcript : nil
                
                // Filter out header rows
                if !description.lowercased().contains("item") &&
                   !description.lowercased().contains("description") {
                    items.append(LineItem(description: description, price: price))
                }
            }
        }
        
        // If no tables, try to parse from text blocks
        if items.isEmpty {
            items = extractLineItemsFromText(document.text)
        }
        
        return items
    }
    
    static func extractLineItemsFromText(_ text: DocumentObservation.Container.Text) -> [LineItem] {
        var items: [LineItem] = []
        
        let fullText = text.transcript
        let lines = fullText.components(separatedBy: .newlines)
        
        // Look for lines with prices (pattern: text followed by dollar amount)
        let pricePattern = #"\$?\d+\.\d{2}"#
        
        for lineText in lines {
            if let range = lineText.range(of: pricePattern, options: String.CompareOptions.regularExpression) {
                let price = String(lineText[range])
                let description = lineText.replacingOccurrences(of: price, with: "").trimmingCharacters(in: CharacterSet.whitespaces)
                
                if !description.isEmpty {
                    items.append(LineItem(description: description, price: price))
                }
            }
        }
        
        return items
    }
    
    static func extractTotal(from observations: [DocumentObservation]) -> String? {
        guard let document = observations.first?.document else { return nil }
        
        let fullText = document.text.transcript
        let lines = fullText.components(separatedBy: .newlines)
        let pricePattern = #"\$?\d+\.\d{2}"#
        var lastPrice: String?
        
        // Look for "Total" keyword followed by amount
        for lineText in lines {
            let lineLower = lineText.lowercased()
            
            if lineLower.contains("total") || lineLower.contains("amount due") {
                if let range = lineText.range(of: pricePattern, options: String.CompareOptions.regularExpression) {
                    return String(lineText[range])
                }
            }
            
            // Keep track of last price as fallback
            if let range = lineText.range(of: pricePattern, options: String.CompareOptions.regularExpression) {
                lastPrice = String(lineText[range])
            }
        }
        
        // Fallback: return the last price found (often the total)
        return lastPrice
    }
    
    // Create an annotated image with bounding boxes drawn on it
    func annotatedImage() -> CGImage? {
        let uiImage = UIImage(cgImage: image)
        let imageSize = CGSize(width: image.width, height: image.height)
         
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Draw the original image
        uiImage.draw(in: CGRect(origin: .zero, size: imageSize))
        
        // Set up drawing style
        context.setLineWidth(3.0)
        
        // Draw bounding boxes for each observation
        for observation in observations {
            let document = observation.document
            
            // Draw text bounding box (green)
            context.setStrokeColor(UIColor.green.cgColor)
            let textRect = convertNormalizedRect(document.text.boundingRegion.boundingBox, imageSize: imageSize)
            context.stroke(textRect)
            
            // Draw table bounding boxes (blue)
            context.setStrokeColor(UIColor.blue.cgColor)
            drawRecursiveTable(tables: document.tables, in: context, imageSize: imageSize)
            
            // Draw list bounding boxes (orange)
            context.setStrokeColor(UIColor.orange.cgColor)
            for list in document.lists {
                let listRect = convertNormalizedRect(list.boundingRegion.boundingBox, imageSize: imageSize)
                context.stroke(listRect)
            }
            
            // Draw barcode bounding boxes (purple)
            context.setStrokeColor(UIColor.purple.cgColor)
            for barcode in document.barcodes {
                let barcodeRect = convertNormalizedRect(barcode.boundingRegion.boundingBox, imageSize: imageSize)
                context.stroke(barcodeRect)
            }
        }
        
        let annotatedUIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return annotatedUIImage?.cgImage
    }
    
    private func drawRecursiveTable(tables: [DocumentObservation.Container.Table]?, in context: CGContext, imageSize: CGSize) {
        // Base case: Stop if table array doesn't exist
        guard let tables = tables else {
            return
        }
        
        // Draw all tables in the array
        for table in tables {
            let tableRect = convertNormalizedRect(table.boundingRegion.boundingBox, imageSize: imageSize)
            context.stroke(tableRect)
            
            // Recursive case: Process child tables from cell content
            for row in table.rows {
                for cell in row {
                    let tableContent = cell.content
                    // Recursively draw nested tables
                    drawRecursiveTable(tables: tableContent.tables, in: context, imageSize: imageSize)
                }
            }
        }
    }
    
    // Convert Vision's normalized rect (origin at bottom-left) to UIKit's coordinate system (origin at top-left)
    private func convertNormalizedRect(_ normalizedRect: NormalizedRect, imageSize: CGSize) -> CGRect {
        let rect = normalizedRect.toImageCoordinates(imageSize, origin: .lowerLeft)
        
        // Vision uses bottom-left origin, UIKit uses top-left, so flip Y coordinate
        return CGRect(
            x: rect.minX,
            y: imageSize.height - rect.maxY,
            width: rect.width,
            height: rect.height
        )
    }
    
    static func == (lhs: Receipt, rhs: Receipt) -> Bool {
        lhs.image === rhs.image
    }
}
