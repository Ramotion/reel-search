//
//  RAMCell.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/10/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

public protocol ConfigurableCell {
    
    typealias DataType
    
    func configureCell(data: DataType)
    
    var theme: Theme { get set }
    
}

public class RAMCell: UICollectionViewCell, ConfigurableCell {
    
    public override var description: String {
        return self.textLabel.text ?? ""
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    var textLabel: UILabel!
    
    public var theme: Theme = RAMTheme.sharedTheme {
        didSet {
            updateFont()
        }
    }
    
    func updateFont() {
        textLabel.font = theme.font
        textLabel.textColor = theme.textColor.colorWithAlphaComponent(0.3)
    }
    
    private func setup() {
        let labelFrame = self.contentView.bounds
        textLabel = UILabel(frame: labelFrame)
        textLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.contentView.addSubview(textLabel)
        
        let views = ["textLabel": textLabel]
        
        let textLabelHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(20)-[textLabel]-(20)-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views) as! [NSLayoutConstraint]
        self.addConstraints(textLabelHConstraints)
        
        let textLabelVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[textLabel]-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views) as! [NSLayoutConstraint]
        self.addConstraints(textLabelVConstraints)
        
        updateFont()
    }
    
    public func configureCell(s: String) {
        
        self.textLabel.text = s
    
    }
    
}