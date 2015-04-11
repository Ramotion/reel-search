//
//  ViewController.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/2/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit
import RAMReel

class ViewController: UIViewController, FlowDataDestination, UITableViewDelegate {

    @IBOutlet weak var textField: UITextField!
    var reactorA: TextFieldReactor<SimplePrefixQueryDataSource, CollectionViewWrapper<NSAttributedString, ExampleCell>>!
    var reactorB: TextFieldReactor<SimplePrefixQueryDataSource, ViewController>!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var wrapper: CollectionViewWrapper<NSAttributedString, ExampleCell>!
    
    var simpleDataSource: SimplePrefixQueryDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println(self.textField.font)
        wrapper = CollectionViewWrapper(collectionView: collectionView, cellId: "ExampleCell")
        
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
        "bark"
    ]
    
    func processData(data: [NSAttributedString]) {
        println(data)
    }
    
}
