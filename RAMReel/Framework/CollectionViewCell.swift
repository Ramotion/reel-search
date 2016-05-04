//
//  RAMCell.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/10/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

// MARK: - Collection view cells
/**
    Type that implements this protocol allows configuration.
    As type name hints this protocol primarily targeted to UITableView and UICollectionView cells
*/
public protocol ConfigurableCell {
    
    associatedtype DataType: Equatable
    
    /**
        Implementing type should use data to fill own data fields
    
        - parameter data: Data to present in the cell
    */
    func configureCell(data: DataType)
    
    /// Visual appearance theme
    var theme: Theme { get set }
    
}

/**
 RAMCell
 --
 
 Example configurable cell
*/
public class RAMCell: UICollectionViewCell, ConfigurableCell {
    
    /**
    Proxy call to superclass init.
     
    - parameter coder: `NSCoder` instance proxied to superview.
    */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    
        setup()
    }
    
    /**
    Proxy call to superclass init.
     
    - parameter frame: Rect of cell, proxied to superview.
    */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    var textLabel: UILabel!
    
    /// Visual appearance theme
    public var theme: Theme = RAMTheme.sharedTheme {
        didSet {
            if theme.font != oldValue.font || theme.textColor != oldValue.textColor {
                updateFont()
            }
        }
    }
    
    func updateFont() {
        let theme = self.theme
        textLabel.font = theme.font
        textLabel.textColor = theme.textColor.colorWithAlphaComponent(0.3)
    }
    
    private func setup() {
        let labelFrame = self.contentView.bounds
        textLabel = UILabel(frame: labelFrame)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(textLabel)
        
        let views = ["textLabel": textLabel]
        
        let textLabelHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(20)-[textLabel]-(20)-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views) 
        self.addConstraints(textLabelHConstraints)
        
        let textLabelVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[textLabel]|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views) 
        self.addConstraints(textLabelVConstraints)
        
        updateFont()
    }
    
    /** 
    Applies string data to the label text property
     
    - parameter string: String to show in the cell
    */
    public func configureCell(string: String) {
        
        self.textLabel.text = string
    
    }
    
}