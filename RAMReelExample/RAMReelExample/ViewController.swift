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
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        wrapper = CollectionViewWrapper(collectionView: collectionView, cellId: "ExampleCell")
        
        simpleDataSource = SimplePrefixQueryDataSource(data)
        
        reactorA = textField <&> simpleDataSource *> wrapper
        reactorB = textField <&> simpleDataSource *> self
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("keyboard:"),
            name: UIKeyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboard(notification: NSNotification) {
        if
            let userInfo = notification.userInfo as! [String: AnyObject]?,
            
            let startFrame = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue(),
            let endFrame   = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue(),
        
            let animDuration: NSTimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue,
            let animCurveRaw = userInfo[UIKeyboardAnimationCurveUserInfoKey]?.unsignedIntegerValue
        {
            println(animDuration)
            println(animCurveRaw)
            
            let animCurve = UIViewAnimationOptions(rawValue: UInt(animCurveRaw))
            
            self.bottomConstraint.constant = self.view.frame.height - endFrame.origin.y
            UIView.animateWithDuration(animDuration, delay: 0.0, options: animCurve, animations: {
                self.textField.layoutIfNeeded()
            }, completion: nil)
        }
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
        
    }
    
}
