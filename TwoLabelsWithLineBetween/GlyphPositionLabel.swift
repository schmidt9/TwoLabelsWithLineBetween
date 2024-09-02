//
//  GlyphPositionLabel.swift
//  TwoLabelsWithLineBetween
//

import UIKit

struct TextLineGeometry {
    var fullRect: CGRect // used for debug here
    var baselineRect: CGRect
}

class GlyphPositionLabel: UILabel {
    
    var debug = false
    
    /// See https://stackoverflow.com/a/77427472/3004003
    var linesGeometry: [TextLineGeometry] {
        guard let text, let attributedText, let font, !text.isEmpty else {
            return []
        }
        
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding  = 0;
        textContainer.maximumNumberOfLines = self.numberOfLines;
        textContainer.lineBreakMode = self.lineBreakMode;

        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        let baseline = font.ascender
        
        var geometries = [TextLineGeometry]()
        var index = text.startIndex
        var currentRect: CGRect?
        
        while index != text.endIndex {
            let range = index..<text.index(after: index)
            // ignore white spaces
            if text[range].trimmingCharacters(in: .whitespaces).isEmpty {
                index = text.index(after: index)
                continue
            }

            let rect = layoutManager.boundingRect(forGlyphRange: NSRange(range, in: text), in: textContainer)
            index = text.index(after: index)
            
            if currentRect == nil {
                currentRect = rect
            } else if abs(currentRect!.minY - rect.minY) < 1 {
                // glyph on the same line, resize line rect
                currentRect!.size = CGSize(width: rect.maxX, height: currentRect!.height)
            } else {
                let geometry = TextLineGeometry(
                    fullRect: currentRect!,
                    baselineRect: CGRect(origin: currentRect!.origin, size: CGSize(width: currentRect!.width, height: baseline))
                )
                geometries.append(geometry)
                currentRect = rect
            }
        }
        
        let geometry = TextLineGeometry(
            fullRect: currentRect!,
            baselineRect: CGRect(origin: currentRect!.origin, size: CGSize(width: currentRect!.width, height: baseline))
        )
        
        geometries.append(geometry)
        
        return geometries
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if !debug {
            return
        }
        
        linesGeometry.forEach {
            UIColor.black.setStroke()
            let fullPath = UIBezierPath(rect: $0.fullRect)
            fullPath.stroke()
            
            UIColor.red.setStroke()
            let baseLinePath = UIBezierPath(rect: $0.baselineRect)
            baseLinePath.stroke()
        }
    }

}
