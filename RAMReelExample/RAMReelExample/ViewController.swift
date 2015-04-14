//
//  ViewController.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/2/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit
import RAMReel

class ViewController: UIViewController, FlowDataDestination, UICollectionViewDelegate, UIScrollViewDelegate {

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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if
            let windows = UIApplication.sharedApplication().windows as? [UIWindow],
            let window  = windows.first
        {
            let rect = scrollView.convertRect(textField.frame, fromView: nil)
            println("winrect:\(rect)")
            let attrs = wrapper.cellAttributes(collectionView.convertRect(rect, fromView: self.collectionView))
            
            println(attrs)
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        println("cell: \(cell.frame)")
    }
    
}
