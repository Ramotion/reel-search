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
        println(textLabel.font)
        println(UIFont(name: "Roboto", size: 36))
        
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
    
    static let font:UIFont = UIFont(name: "Roboto Light", size: 36) ?? UIFont.systemFontOfSize(36, weight: UIFontWeightThin)
    
    static func loadFonts() {
//        NSString *fontPath = [[NSBundle frameworkBundle] pathForResource:@"MyFont" ofType:@"ttf"];
//        NSData *inData = [NSData dataWithContentsOfFile:fontPath];
//        CFErrorRef error;
//        CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)inData);
//        CGFontRef font = CGFontCreateWithDataProvider(provider);
//        if (! CTFontManagerRegisterGraphicsFont(font, &error)) {
//            CFStringRef errorDescription = CFErrorCopyDescription(error);
//            NSLog(@"Failed to load font: %@", errorDescription);
//            CFRelease(errorDescription);
//        }
//        CFRelease(font);
//        CFRelease(provider);
        
        // TODO: Load
    }
    
}