//
//  RAMCell.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/10/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

/**
    Type that implements this protocol allows configuration.
    As type name hints this protocol primarily targeted to UITableView and UICollectionView cells
*/
public protocol ConfigurableCell {
    
    typealias DataType
    
    /**
        Implementing type should use data to fill own data fields
    
        :param: data Data to present in the cell
    */
    func configureCell(data: DataType)
    
    /// Visual appearance theme
    var theme: Theme { get set }
    
}

/**
    Example configurable cell
*/
public class RAMCell: UICollectionViewCell, ConfigurableCell {
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    var textLabel: UILabel!
    
    /// Visual appearance theme
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
        
        let textLabelVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[textLabel]|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views) as! [NSLayoutConstraint]
        self.addConstraints(textLabelVConstraints)
        
        updateFont()
    }
    
    /// Applies string data to the label text property
    public func configureCell(s: String) {
        
        self.textLabel.text = s
    
    }
    
}