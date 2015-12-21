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
    
    private static var defaultFont: UIFont {
        loadRoboto()
        
        let font: UIFont
        if let roboto = UIFont(name: "Roboto-Light", size: 36) {
            font = roboto
        }
        else if #available(iOS 8.2, *) {
            font = UIFont.systemFontOfSize(36, weight: UIFontWeightThin)
        } else {
            font = UIFont.systemFontOfSize(36)
        }
        return font
    }
    
    private init(
        textColor: UIColor = UIColor.blackColor(),
        listBackgroundColor: UIColor = UIColor.clearColor(),
        font: UIFont = RAMTheme.defaultFont
        )
    {
        self.textColor = textColor
        self.listBackgroundColor = listBackgroundColor
        self.font = font
    }
    
    static private func loadRoboto() -> Bool {
        return FontLoader.robotoLight != nil
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

class FontLoader {
    
    enum Error: ErrorType {
        case FailedToLoadFont(String)
    }
    
    static let robotoLight: FontLoader? = try? FontLoader(name: "Roboto-Light", type: "ttf")
    
    private init(name: String, type: String) throws {
        let bundle = NSBundle(forClass: self.dynamicType as AnyClass)

        var error: Unmanaged<CFErrorRef>? = nil
        if
            let fontPath = bundle.pathForResource(name, ofType: type),
            let inData = NSData(contentsOfFile: fontPath),
            let provider = CGDataProviderCreateWithCFData(inData),
            let font = CGFontCreateWithDataProvider(provider)
            where CTFontManagerRegisterGraphicsFont(font, &error)
        {
            return
        }
        else {
            print(error)
            throw Error.FailedToLoadFont(name)
        }
    }
    
}
