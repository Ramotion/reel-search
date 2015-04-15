//
//  ExampleCell.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/10/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

public protocol ConfigurableCell {
    
    typealias DataType
    
    func configureCell(data: DataType)
    
}

public class ExampleCell: UICollectionViewCell, ConfigurableCell {
    
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
    
    public var theme: Theme = ExampleTheme.sharedTheme {
        didSet {
            updateFont()
        }
    }
    
    func updateFont() {
        textLabel.font = theme.font
    }
    
    private func setup() {
        let labelFrame = CGRectInset(self.contentView.bounds, 20, 8)
        textLabel = UILabel(frame: labelFrame)
        
        updateFont()
        
        self.contentView.addSubview(textLabel)
    }
    
    public func configureCell(s: NSAttributedString) {
        
        self.textLabel.attributedText = s
    
    }
    
}