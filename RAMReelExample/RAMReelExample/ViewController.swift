//
//  ViewController.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/2/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit
import RAMReel

class ViewController: UIViewController, FlowDataDestination, UICollectionViewDelegate {

    @IBOutlet weak var textField: UITextField!
    var reactorA: TextFieldReactor<SimplePrefixQueryDataSource, CollectionViewWrapper<NSAttributedString, ExampleCell>>!
    var reactorB: TextFieldReactor<SimplePrefixQueryDataSource, ViewController>!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var wrapper: CollectionViewWrapper<NSAttributedString, ExampleCell>!
    
    var simpleDataSource: SimplePrefixQueryDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        wrapper = CollectionViewWrapper(collectionView: collectionView, cellId: "ExampleCell")
        
        collectionView.delegate = self
        let scrollView = collectionView as UIScrollView
        scrollView.delegate = self
        
        simpleDataSource = SimplePrefixQueryDataSource(data)
        
        reactorA = textField <&> simpleDataSource *> wrapper
        reactorB = textField <&> simpleDataSource *> self
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
    
    func processData(data: [NSAttributedString]) {
//        println(data)
    }

}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let rect = scrollView.convertRect(textField.frame, fromView: textField.superview)
        
        let attrs = wrapper.cellAttributes(rect)
        
        let cells = attrs.map {
            self.collectionView?.cellForItemAtIndexPath($0.indexPath)! as! ExampleCell
        }
        
        if let firstCell = cells.first {
            self.textField.text = firstCell.description
        }
        
//        if let firstAttr = attrs.first {
//            println(attrs)
//        }
        
    }
    
}
