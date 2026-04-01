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
    
    init(image: CGImage, observations: [DocumentObservation]) {
        self.image = image
        self.observations = observations
        let container = observations.first?.document
        self.title = container?.title?.transcript
        self.fullText = container?.text.transcript ?? ""
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
