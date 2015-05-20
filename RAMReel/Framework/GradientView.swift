//
//  ContainerView.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/23/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit
import QuartzCore

class GradientView: UIView {
    
    var gradientLayer: CAGradientLayer!
    
    var listBackgroundColor: UIColor? {
        didSet {
            updateGradient()
        }
    }
    
    func updateGradient() {
        let color = listBackgroundColor ?? UIColor.whiteColor()
        let white = color.CGColor
        let clear = color.colorWithAlphaComponent(0.0).CGColor
        gradientLayer.colors = [white, clear, white]
    }
    
    func setupGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame  = self.bounds
        updateGradient()
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupGradientLayer()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupGradientLayer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame  = self.bounds
        gradientLayer.setNeedsDisplay()
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return false
    }

}