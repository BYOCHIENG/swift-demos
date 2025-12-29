//
//  ImageGalleryView.swift
//  ml-image-parse
//
//  Created by Mich Ochieng on 2025-12-28.
//

import SwiftUI

struct ImageGalleryView: View {
    let itemSize = 100.0


    let imageResources: [[ImageResource]] = [
         [.sign1, .sign2, .sign3],
         [.sign4, .sign5, .sign6],
         [.sign7, .sign8, .sign9],
         [.receipt1, .receipt2, .receipt3]
     ]


    var body: some View {
        Grid {
            ForEach(imageResources, id: \.self) { resourceRow in
                GridRow {
                    ForEach(resourceRow, id: \.self) { resource in
                        NavigationLink {
                            TextRecognitionView(imageResource: resource)
                        } label: {
                            Image(resource)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: itemSize, height: itemSize)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(10)
                        }
                    }
                }
            }
        }
    }
}


#Preview {
    NavigationStack {
        ImageGalleryView()
    }
}
