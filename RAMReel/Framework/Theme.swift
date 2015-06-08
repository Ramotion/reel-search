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

struct RAMTheme: Theme {
    
    private init() { }
    
    static let sharedTheme = RAMTheme()
    
    let textColor = UIColor.blackColor()
    
    let listBackgroundColor = UIColor.whiteColor()
    
    let isRobotoLoaded = RAMTheme.loadRoboto()
    
    var font:UIFont {
        if self.isRobotoLoaded {
            return UIFont(name: "Roboto-Light", size: 36)!
        }
        else {
            return UIFont.systemFontOfSize(36, weight: UIFontWeightThin)
        }
    }
    
    static private var loadToken = dispatch_once_t()
    static private func loadRoboto() -> Bool {
        
        var result: Bool?
        dispatch_once(&loadToken) {
            
            let frameworks = NSBundle.allFrameworks() as! [NSBundle]
            let paths = frameworks.map { (bundle: NSBundle) -> String? in
                return bundle.pathForResource("Roboto-Light", ofType: "ttf")
            }
            
            let theFirstPath = paths.filter { path in
                return path != nil
                }.map { $0! }.first
            
            if
                let fontPath = theFirstPath,
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
}
