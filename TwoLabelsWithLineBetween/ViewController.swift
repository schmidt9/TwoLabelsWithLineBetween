//
//  ViewController.swift
//  TwoLabelsWithLineBetween
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var leftLabel: GlyphPositionLabel!
    @IBOutlet var rightLabel: GlyphPositionLabel!
    
    let lineLayerName = "lineLayerName"
    let linePadding: CGFloat = 4
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        drawLine()
    }

    func drawLine() {
        leftLabel.debug = false
        rightLabel.debug = false
        
        guard
            let leftLastLineGeometry = leftLabel.linesGeometry.last,
            let rightLastLineGeometry = rightLabel.linesGeometry.last else {
            return
        }
        
        let leftBaselineRect = leftLabel.convert(leftLastLineGeometry.baselineRect, to: view)
        let leftBaselineBottomRightPoint = CGPoint(x: leftBaselineRect.maxX + linePadding, y: leftBaselineRect.maxY)
        
        let rightBaselineRect = rightLabel.convert(rightLastLineGeometry.baselineRect, to: view)
        let rightBaselineBottomLeftPoint = CGPoint(x: rightBaselineRect.minX - linePadding, y: rightBaselineRect.maxY)
        
        for layer in view.layer.sublayers ?? [] {
            if layer.name == lineLayerName {
                layer.removeFromSuperlayer()
                break
            }
        }
        
        let lineLayer = CAShapeLayer()
        lineLayer.lineDashPattern = [4, 2]
        lineLayer.strokeColor = UIColor.gray.cgColor
        lineLayer.lineWidth = 1
        lineLayer.name = lineLayerName
        view.layer.addSublayer(lineLayer)
        
        let linePath = UIBezierPath()
        linePath.move(to: leftBaselineBottomRightPoint)
        linePath.addLine(to: rightBaselineBottomLeftPoint)
        lineLayer.path = linePath.cgPath
    }

}

