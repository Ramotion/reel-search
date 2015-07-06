//
//  Theme.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/11/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

/**
Protocol that allows you change visual appearance a bit
*/
public protocol Theme {
    
    /**
    Text font of both list labels and input textfield
    */
    var font: UIFont { get }
    /**
    Color of textfield's text
    
    Suggestion list's text color is calculated using this color by changing alpha channel value to 0.3
    */
    var textColor: UIColor { get }
    
    /**
    Color of list's background
    */
    var listBackgroundColor: UIColor { get }
    
}

public struct RAMTheme: Theme {
    
    public static let sharedTheme = RAMTheme()
    
    public let font: UIFont
    public let textColor: UIColor
    public let listBackgroundColor: UIColor
    
    let isRobotoLoaded = RAMTheme.loadRoboto()
    
    private init(
        textColor: UIColor = UIColor.blackColor(),
        listBackgroundColor: UIColor = UIColor.clearColor(),
        font: UIFont = UIFont(name: "Roboto-Light", size: 36) ?? UIFont.systemFontOfSize(36, weight: UIFontWeightThin)
        )
    {
        self.textColor = textColor
        self.listBackgroundColor = listBackgroundColor
        self.font = font
    }
    
    static private var loadToken = dispatch_once_t()
    static private func loadRoboto() -> Bool {
        
        var result: Bool?
        dispatch_once(&loadToken) {
            
            let bundle = NSBundle(identifier: "RAMReel")
            
            if
                let fontPath = bundle?.pathForResource("Roboto-Light", ofType: "ttf"),
                let inData = NSData(contentsOfFile: fontPath)
            {
                let provider = CGDataProviderCreateWithCFData(inData)
                let font = CGFontCreateWithDataProvider(provider)
                
                var error: Unmanaged<CFErrorRef>? = nil
                if CTFontManagerRegisterGraphicsFont(font, &error) {
                    result = true
                    return
                }
                else {
                    println("Failed to load Roboto font")
                }
            }
            
            result = false
        }
        
        return result ?? true
    }
    
    public func textColor(textColor: UIColor) -> RAMTheme {
        return RAMTheme(textColor: textColor, listBackgroundColor: self.listBackgroundColor, font: self.font)
    }
    
    public func listBackgroundColor(listBackgroundColor: UIColor) -> RAMTheme {
        return RAMTheme(textColor: self.textColor, listBackgroundColor: listBackgroundColor, font: self.font)
    }
    
    public func font(font: UIFont) -> RAMTheme {
        return RAMTheme(textColor: self.textColor, listBackgroundColor: self.listBackgroundColor, font: font)
    }
    
}
