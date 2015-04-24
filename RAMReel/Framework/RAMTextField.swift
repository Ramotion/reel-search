//
//  RAMTextField.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/22/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

public class RAMTextField: UITextField {
    
    var lineColor: UIColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
    
    override public func drawRect(rect: CGRect) {
        let rect = self.bounds
        let ctx = UIGraphicsGetCurrentContext()
        
        self.lineColor.set()
        
        CGContextSetLineWidth(ctx, 1)
        
        let path = CGPathCreateMutable()
        
        var m = CGAffineTransformIdentity
        CGPathMoveToPoint(path, &m, 0, rect.height)
        CGPathAddLineToPoint(path, &m, rect.width, rect.height)
        
        CGContextAddPath(ctx, path)
        CGContextStrokePath(ctx)
    }

}