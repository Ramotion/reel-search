//
//  ViewController.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/2/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit
import RAMReel

class ViewController: UIViewController, UICollectionViewDelegate {

    var dataSource: SimplePrefixQueryDataSource!
    var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = SimplePrefixQueryDataSource(data)
        ramReel = RAMReel(frame: self.view.bounds, dataSource: dataSource, placeholder: "Need something?") {
            println($0)
        }
        ramReel.hooks.append {
            let r = reverse($0)
            let j = String(r)
            println(j)
        }
        
        self.view.addSubview(ramReel.view)
        ramReel.view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    private let data: [String] = [
        "hello",
        "hell",
        "world",
        "war",
        "bar",
        "baz",
        "boron",
        "bark",
        "hello",
        "hell",
        "world",
        "war",
        "bar",
        "baz",
        "boron",
        "bark",
        "hello",
        "hell",
        "world",
        "war",
        "bar",
        "baz",
        "boron",
        "bark",
        "hello",
        "hell",
        "world",
        "war",
        "bar",
        "baz",
        "boron",
        "bark",
    ]

}
