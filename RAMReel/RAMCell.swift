//
//  RAMCell.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/10/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

public class RAMCell: UICollectionViewCell, ConfigurableCell {
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    var textLabel: UILabel!
    private func setup() {
        textLabel = UILabel(frame: self.contentView.bounds)
        textLabel.font = ExampleTheme.font
        self.contentView.addSubview(textLabel)
    }
    
    public func configureCell(s: (String, UIColor)) {
        let (str, color) = s
        
        self.textLabel.text = str
    }
    
}

protocol Theme {
    
    static var font: UIFont { get }
    
}

struct ExampleTheme: Theme {
    
    static let font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    
}