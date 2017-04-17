//
//  RAMTextField.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/22/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

// MARK: - RAMTextField

/**
 RAMTextField
 --
 
 Textfield with a line in the bottom
 */
open class RAMTextField: UITextField {
    
    /**
     Overriding UIView's drawRect method to add line in the bottom of the Text Field
     
     - parameter rect: Rect that should be updated. This override ignores this parameter and redraws all text field
     */
    override open func draw(_ rect: CGRect) {
        let rect = self.bounds
        let ctx = UIGraphicsGetCurrentContext()
        
        let lineColor = self.tintColor.withAlphaComponent(0.3)
        lineColor.set()
        
        ctx?.setLineWidth(1)
        
        let path = CGMutablePath()
        
//        var m = CGAffineTransform.identity
//        CGPathMoveToPoint(path, &m, 0, rect.height)
      path.move(to: CGPoint(x: 0, y: rect.height))
      path.addLine(to: CGPoint(x: rect.width, y: rect.height))
//        CGPathAddLineToPoint(path, &m, rect.width, rect.height)
      
        ctx?.addPath(path)
        ctx?.strokePath()
    }
    
}

// MARK: - UITextField extensions

extension UITextField {
    
    /**
     Overriding `UITextField` `tintColor` property to make it affect close image tint color.
     */
    open override var tintColor: UIColor! {
        get {
            return super.tintColor
        }
        
        set {
            super.tintColor = newValue
            
            let subviews = self.subviews
            for view in subviews {
                guard let button = view as? UIButton else {
                    break
                }
                
                let states: [UIControlState] = [.highlighted]
                states.forEach { state -> Void in
                    let image = button.image(for: state)?.tintedImage(self.tintColor)
                    button.setImage(image, for: state)
                }
            }
        }
    }
    
}

// MARK: - UIImage extensions

private extension UIImage {
    
    /**
     Create new image by applying a tint.
     
     - parameter color: New image tint color.
     */
    func tintedImage(_ color: UIColor) -> UIImage {
        let size = self.size
        
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        self.draw(at: CGPoint.zero, blendMode: CGBlendMode.normal, alpha: 1.0)
        
        context?.setFillColor(color.cgColor)
        context?.setBlendMode(CGBlendMode.sourceIn)
        context?.setAlpha(1.0)
        
        let rect = CGRect(
            x: CGPoint.zero.x,
            y: CGPoint.zero.y,
            width: size.width,
            height: size.height)
        UIGraphicsGetCurrentContext()?.fill(rect)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintedImage ?? self
    }
    
}
