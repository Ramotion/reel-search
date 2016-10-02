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
        let color = listBackgroundColor ?? UIColor.white
        let white = color.withAlphaComponent(1.0).cgColor
        let clear = color.withAlphaComponent(0.0).cgColor
        gradientLayer.colors = [clear, white, clear]
    }
    
    func setupGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame  = self.bounds
        updateGradient()
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
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
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }

}
