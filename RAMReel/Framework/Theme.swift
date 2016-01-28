//
//  Theme.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/11/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

// MARK: Theme
/**
Theme
--

Protocol that allows you change visual appearance a bit.
*/
public protocol Theme {
    
    /**
     Text font of both list labels and input textfield.
     */
    var font: UIFont { get }
    /**
     Color of textfield's text.
     
     Suggestion list's text color is calculated using this color by changing alpha channel value to `0.3`.
     */
    var textColor: UIColor { get }
    
    /**
     Color of list's background.
     */
    var listBackgroundColor: UIColor { get }
    
}

/**
 RAMTheme
 --
 
 Theme prefab.
*/
public struct RAMTheme: Theme {
    
    /// Shared theme with default settings.
    public static let sharedTheme = RAMTheme()
    
    /// Theme font.
    public let font: UIFont
    /// Theme text color.
    public let textColor: UIColor
    /// Theme background color.
    public let listBackgroundColor: UIColor
    
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
    
    private static var defaultFont: UIFont = RAMTheme.initDefaultFont()
    
    private static func initDefaultFont() -> UIFont {
        do {
            try FontLoader.loadRobotoLight()
        } catch (let error) {
            print(error)
        }
            
        let font: UIFont
        if
            let robotoLoaded = FontLoader.robotoLight,
            let roboto = UIFont(name: robotoLoaded.name, size: 36)
        {
            font = roboto
        } else if #available(iOS 8.2, *) {
            font = UIFont.systemFontOfSize(36, weight: UIFontWeightThin)
        } else {
            font = UIFont.systemFontOfSize(36)
        }
        return font
    }
    
    /** 
    Creates new theme with new text color.
     
    - parameter textColor: New text color.
    - returns: New `RAMTheme` instance.
     */
    public func textColor(textColor: UIColor) -> RAMTheme {
        return RAMTheme(textColor: textColor, listBackgroundColor: self.listBackgroundColor, font: self.font)
    }
    
    /**
     Creates new theme with new background color.
     
     - parameter listBackgroundColor: New background color.
     - returns: New `RAMTheme` instance.
     */
    public func listBackgroundColor(listBackgroundColor: UIColor) -> RAMTheme {
        return RAMTheme(textColor: self.textColor, listBackgroundColor: listBackgroundColor, font: self.font)
    }
    
    /**
     Creates new theme with new font.
     
     - parameter font: New font.
     - returns: New `RAMTheme` instance.
     */
    public func font(font: UIFont) -> RAMTheme {
        return RAMTheme(textColor: self.textColor, listBackgroundColor: self.listBackgroundColor, font: font)
    }
    
}

// MARK: - Font loader

/**
FontLoader
--
*/
final class FontLoader {
    
    enum Error: ErrorType {
        case FailedToLoadFont(String)
    }
    
    static let robotoLight: FontLoader? = try? FontLoader.loadRobotoLight()
    
    static func loadRobotoLight() throws -> FontLoader {
        return try FontLoader(name: "Roboto-Light", type: "ttf")
    }
    
    let name: String
    let type: String
    
    private init(name: String, type: String) throws {
        self.name = name
        self.type = type
        
        guard FontLoader.loadedFonts[name] == nil else {
            return
        }
        
        let bundle = NSBundle(forClass: self.dynamicType as AnyClass)

        if
            let fontPath = bundle.pathForResource(name, ofType: type),
            let inData = NSData(contentsOfFile: fontPath),
            let provider = CGDataProviderCreateWithCFData(inData),
            let font = CGFontCreateWithDataProvider(provider)
            where CTFontManagerRegisterGraphicsFont(font, nil)
        {
            FontLoader.loadedFonts[self.name] = self
            return
        } else {
            throw Error.FailedToLoadFont(name)
        }
    }
    
    private static var loadedFonts: [String: FontLoader] = [:]
    
}
