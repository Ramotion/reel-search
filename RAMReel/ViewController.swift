//
//  ViewController.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/2/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FlowDataDestination {

    @IBOutlet weak var textField: UITextField!
    var reactor: TextFieldReactor<SimplePrefixQueryDataSource, ViewController>!
    
    @IBOutlet weak var tableView: UITableView!
    var wrapper: TableViewDataWrapper<UITableViewCell>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reactor = TextFieldReactor(textField: textField, dataFlow: SimplePrefixQueryDataSource(data) *> self)
        wrapper = TableViewDataWrapper(tableView: tableView, cellId: "The Cell")
    }

    private let data: [String] = [
        "hello",
        "world",
        "bar",
        "baz",
        "boron"
    ]
    
    func processData(data: [String]) {
        println(data)
    }
}
