//
//  ViewController.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/2/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit
import RAMReel

@available(iOS 8.2, *)
class ViewController: UIViewController, UICollectionViewDelegate {
    
    var dataSource: SimplePrefixQueryDataSource!
    var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
    fileprivate var data: [String] = ["Abc"] {
        didSet {
            dataSource = SimplePrefixQueryDataSource(data)
            ramReel.updateWithNew(dataSource)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataSource = SimplePrefixQueryDataSource(data)
        
        ramReel = RAMReel(frame: self.view.frame, dataSource: dataSource, placeholder: "Start by typing…", attemptToDodgeKeyboard: true) {
                print("Plain:", $0)
            }
        
        ramReel.hooks.append {
            let r = Array($0.characters.reversed())
            let j = String(r)
            print("Reversed:", j)
        }
        
        self.view.addSubview(ramReel.view)
        ramReel.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        ramReel.addToTextFieldTarget(self, action: #selector(textFieldDidChange), for: .editingDidEnd)
    }
}

// MARK: - Text Field Editing Event
extension ViewController {
    
    func textFieldDidChange(textField: UITextField) {
        if textField.text! != "" {
            self.data.append(textField.text!)
        }
    }
}
