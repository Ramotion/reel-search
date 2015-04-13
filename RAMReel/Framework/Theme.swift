//
//  Theme.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/11/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

public protocol Theme {

    var font: UIFont { get }
    
}

struct ExampleTheme: Theme {
    
    static let sharedTheme = ExampleTheme()
    
    let isRobotoLoaded = ExampleTheme.loadRoboto()
    
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
