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
    var ramReel: RAMReel<RAMCell, SimplePrefixQueryDataSource>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = SimplePrefixQueryDataSource(data)
        ramReel = RAMReel(frame: self.view.frame, dataSource: dataSource)
        
        self.view = ramReel.view
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
    
    func processData(data: [String]) {
//        println(data)
    }

}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
//        let attrs = wrapper.cellAttributes(rect)
        
    }
    
}
