//
//  ViewController.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/2/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit
import RAMReel

class ViewController: UIViewController, FlowDataSource, FlowDataDestination, UITableViewDelegate {

    @IBOutlet weak var textField: UITextField!
    var reactorA: TextFieldReactor<ViewController, CollectionViewWrapper<(String, UIColor), RAMCell>>!
    var reactorB: TextFieldReactor<ViewController, ViewController>!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var wrapper: CollectionViewWrapper<(String, UIColor), RAMCell>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println(self.textField.font)
        wrapper = CollectionViewWrapper(collectionView: collectionView, cellId: "RAMCell")
        
        reactorA = textField <&> self *> wrapper
        reactorB = textField <&> self *> self
    }

    private let data: [(String, UIColor)] = [
        ("hello", UIColor.greenColor()),
        ("hell", UIColor.redColor()),
        ("world", UIColor.blueColor()),
        ("war", UIColor.blackColor()),
        ("bar", UIColor.purpleColor()),
        ("baz", UIColor.yellowColor()),
        ("boron", UIColor.orangeColor()),
        ("bark", UIColor.brownColor())
    ]
    
    func resultsForQuery(query: String) -> [(String, UIColor)] {
        return data.filter({ $0.0.hasPrefix(query) })
    }
    
    func processData(data: [(String, UIColor)]) {
        println(data)
    }
    
}
