//
//  CropOverlayView.swift
//  Mantis
//
//  Created by Echo on 10/19/18.
//  Copyright © 2018 Echo. All rights reserved.
//

import UIKit

class CropOverlayView: UIView {
    var gridHidden = true
    var gridColor = UIColor(white: 0.8, alpha: 1)
    
    private let cropOverLayerCornerWidth = CGFloat(12.0)
    private let showGridLines = false

    var gridLineNumberType: GridLineNumberType = .crop {
        didSet {
            setupGridLines()
            layoutGridLines()
        }
    }
    private var horizontalGridLines: [UIView] = []
    private var verticalGridLines: [UIView] = []
    private var borderLine: UIView = UIView()
    private var corner: [UIImageView] = []
    private let borderThickness = CGFloat(1.0)
    
    override var frame: CGRect {
        didSet {
            if corner.count > 0 {
                layoutLines()
            }            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func createNewLine(named name: String = "") -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: name)
        view.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: cropOverLayerCornerWidth, height: cropOverLayerCornerWidth))
        view.backgroundColor = .clear
        addSubview(view)
        return view
    }
    
    private func setup() {
        borderLine = createNewLine()
        borderLine.layer.backgroundColor = UIColor.clear.cgColor
        borderLine.layer.borderWidth = borderThickness
        borderLine.layer.borderColor = UIColor.white.cgColor
        
        for i in 0..<4 {
            let view = createNewLine(named: "corner_top_left_icon")
            corner.append(view)
            switch i {
            case 0: break
            case 1:
                view.rotate(in: 90)
            case 2:
                view.rotate(in: 180)
            case 3:
                view.rotate(in: -90)
            default: break
            }
        }
        
        setupGridLines()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if corner.count > 0 {
            layoutLines()
        }
    }
    
    private func layoutLines() {
        guard bounds.isEmpty == false else {
            return
        }
        
        layoutOuterLines()
        layoutCornerLines()
        layoutGridLines()
        setGridShowStatus()
    }
    
    private func setGridShowStatus() {
        horizontalGridLines.forEach{ $0.alpha = gridHidden ? 0 : 1}
        verticalGridLines.forEach{ $0.alpha = gridHidden ? 0 : 1}
    }
    
    private func layoutGridLines() {
        if showGridLines {
            for i in 0..<gridLineNumberType.rawValue {
                horizontalGridLines[i].frame = CGRect(x: 0, y: CGFloat(i + 1) * frame.height / CGFloat(gridLineNumberType.rawValue + 1), width: frame.width, height: 1)
                verticalGridLines[i].frame = CGRect(x: CGFloat(i + 1) * frame.width / CGFloat(gridLineNumberType.rawValue + 1), y: 0, width: 1, height: frame.height)
            }
        }
    }
    
    private func setupGridLines() {
        setupVerticalGridLines()
        setupHorizontalGridLines()
    }
    
    private func setupHorizontalGridLines() {
        horizontalGridLines.forEach { $0.removeFromSuperview() }
        horizontalGridLines.removeAll()
        if showGridLines {
            for _ in 0..<gridLineNumberType.rawValue {
                let view = createNewLine()
                view.backgroundColor = gridColor
                horizontalGridLines.append(view)
            }
        }
    }
    
    private func setupVerticalGridLines() {
        verticalGridLines.forEach { $0.removeFromSuperview() }
        verticalGridLines.removeAll()
        if showGridLines {
            for _ in 0..<gridLineNumberType.rawValue {
                let view = createNewLine()
                view.backgroundColor = gridColor
                verticalGridLines.append(view)
            }
        }
    }
    
    private func layoutOuterLines() {
        borderLine.frame = CGRect(x: -borderThickness, y: -borderThickness, width: bounds.width + 2 * borderThickness, height: bounds.height + 2 * borderThickness)
        borderLine.layer.backgroundColor = UIColor.clear.cgColor
        borderLine.layer.borderWidth = borderThickness
        borderLine.layer.borderColor = UIColor.white.cgColor
    }
    
    private func layoutCornerLines() {
        let borderThickness = cropOverLayerCornerWidth * 2/3
        
        let topLeftHorizonalLayerFrame = CGRect(x: -borderThickness, y: -borderThickness, width: cropOverLayerCornerWidth, height: borderThickness)
        let topLeftVerticalLayerFrame = CGRect(x: -borderThickness, y: -borderThickness, width: borderThickness, height: cropOverLayerCornerWidth)
                
        let horizontalDistanceForHCorner = bounds.width + 2 * borderThickness - cropOverLayerCornerWidth
        let verticalDistanceForHCorner = bounds.height + borderThickness
        let horizontalDistanceForVCorner = bounds.width + borderThickness
        let veticalDistanceForVCorner = bounds.height + 2 * borderThickness - cropOverLayerCornerWidth
        
        for (i, line) in corner.enumerated() {
            switch i {
            case 0:
                line.frame.origin = topLeftHorizonalLayerFrame.origin
            case 1:
                line.frame.origin = topLeftHorizonalLayerFrame.offsetBy(dx: horizontalDistanceForHCorner, dy: 0).origin
            case 2:
                let h = topLeftHorizonalLayerFrame.offsetBy(dx: horizontalDistanceForHCorner, dy: verticalDistanceForHCorner).origin
                let v = topLeftVerticalLayerFrame.offsetBy(dx: horizontalDistanceForVCorner, dy: veticalDistanceForVCorner).origin
                line.frame.origin = CGPoint.init(x: h.x, y: v.y)
            case 3:
                let h = topLeftHorizonalLayerFrame.offsetBy(dx: 0, dy: verticalDistanceForHCorner).origin
                let v = topLeftVerticalLayerFrame.offsetBy(dx: 0, dy: veticalDistanceForVCorner).origin
                line.frame.origin = CGPoint.init(x: h.x, y: v.y)
            default:
                break
            }
        }
    }
    
    func setGrid(hidden: Bool, animated: Bool = false) {
        self.gridHidden = hidden
        
        func setGridLinesShowStatus () {
            horizontalGridLines.forEach { $0.alpha = hidden ? 0 : 1 }
            verticalGridLines.forEach { $0.alpha = hidden ? 0 : 1}
        }
        
        if animated {
            let duration = hidden ? 0.35 : 0.2
            UIView.animate(withDuration: duration) {
                setGridLinesShowStatus()
            }
        } else {
            setGridLinesShowStatus()
        }
    }
    
    func hideGrid() {
        gridLineNumberType = .none
    }
}

extension CropOverlayView {
    private enum CornerLineType: Int {
        case topLeftVertical = 0
        case topLeftHorizontal
        case topRightVertical
        case topRightHorizontal
        case bottomRightVertical
        case bottomRightHorizontal
        case bottomLeftVertical
        case bottomLeftHorizontal
    }
    
    enum GridLineNumberType: Int {
        case none = 0
        case crop = 2
        case rotate = 8
    }
}

public
extension UIView {

    /**
     Rotate a view by specified degrees

     - parameter angle: angle in degrees
     */
    func rotate(in angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat.pi
        let rotation = self.transform.rotated(by: radians);
        self.transform = rotation
    }

}
