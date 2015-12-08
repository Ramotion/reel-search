//
//  RAMTextField.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/22/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

/**
 Textfield with a line in the bottom
 */
public class RAMTextField: UITextField {
    
    override public func drawRect(rect: CGRect) {
        let rect = self.bounds
        let ctx = UIGraphicsGetCurrentContext()
        
        let lineColor = self.tintColor.colorWithAlphaComponent(0.3)
        lineColor.set()
        
        CGContextSetLineWidth(ctx, 1)
        
        let path = CGPathCreateMutable()
        
        var m = CGAffineTransformIdentity
        CGPathMoveToPoint(path, &m, 0, rect.height)
        CGPathAddLineToPoint(path, &m, rect.width, rect.height)
        
        CGContextAddPath(ctx, path)
        CGContextStrokePath(ctx)
    }
    
}

extension UITextField {
    
    public override var tintColor: UIColor! {
        get {
            return super.tintColor
        }
        
        set {
            super.tintColor = newValue
            
            let subviews = self.subviews
            for view in subviews {
                if let button = view as? UIButton
                {
                    let states: [UIControlState] = [.Normal, .Highlighted]
                    let _ = states.map { state -> Void in
                        let image = button.imageForState(state)?.tintedImage(self.tintColor)
                        button.setImage(image, forState: state)
                    }
                }
            }
        }
    }
    
}

extension UIImage {
    
    func tintedImage(color: UIColor) -> UIImage {
        let size = self.size
        
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        self.drawAtPoint(CGPointZero, blendMode: CGBlendMode.Normal, alpha: 1.0)
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextSetBlendMode(context, CGBlendMode.SourceIn)
        CGContextSetAlpha(context, 1.0)
        
        let rect = CGRectMake(
            CGPointZero.x,
            CGPointZero.y,
            size.width,
            size.height)
        CGContextFillRect(UIGraphicsGetCurrentContext(), rect)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintedImage ?? self
    }
    
}