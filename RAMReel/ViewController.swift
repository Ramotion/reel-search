//
//  ViewController.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/2/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

class MyCell: UICollectionViewCell, ConfigurableCell {
    
    

    @IBOutlet weak var textLabel: UILabel!
    
    func configureCell(s: (String, UIColor)) {
        let (str, color) = s
        
        println(self.subviews)
        
        self.textLabel?.text = str
        println(self.textLabel)
        
        self.backgroundColor = color
    }

}

class ViewController: UIViewController, FlowDataSource, FlowDataDestination, UITableViewDelegate {

    @IBOutlet weak var textField: UITextField!
    var reactorA: TextFieldReactor<ViewController, TableViewDataWrapper<(String, UIColor), MyCell>>!
    var reactorB: TextFieldReactor<ViewController, ViewController>!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var wrapper: TableViewDataWrapper<(String, UIColor), MyCell>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wrapper = TableViewDataWrapper(collectionView: collectionView, cellId: "The Cell")
        
        reactorA = textField &> self *> wrapper
        reactorB = textField &> self *> self
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
