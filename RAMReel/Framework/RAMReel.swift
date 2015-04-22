//
//  RAMReel.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/21/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

public final class RAMReel
    <
    CellClass: UICollectionViewCell,
    TextFieldClass: UITextField,
    DataSource: FlowDataSource
    where
    CellClass: ConfigurableCell,
    CellClass.DataType   == DataSource.ResultType,
    DataSource.QueryType == String
    > {
    
    /// Container view
    public let view: UIView
    
    // MARK: TextField
    let reactor  : TextFieldReactor<DataSource, CollectionWrapperClass>
    let textField: TextFieldClass
    
    // MARK: CollectionView
    typealias CollectionWrapperClass = CollectionViewWrapper<DataSource.ResultType, CellClass>
    let wrapper       : CollectionWrapperClass
    let collectionView: UICollectionView
    
    // MARK: Data Source
    let dataSource: DataSource
    
    // MARK: Layout
    let layout: UICollectionViewLayout = RAMCollectionViewLayout()

    public var theme:Theme = ExampleTheme() {
        didSet {
            cascadeTheme()
        }
    }
    
    func cascadeTheme() {
        self.reactor.theme = theme
        
        let visibleCells = self.collectionView.visibleCells() as! [CellClass]
        visibleCells.map { cell in
            cell.theme = self.theme
        }
    }
    
    var bottomConstraint: NSLayoutConstraint?
    let keyboardCallbackWrapper: NotificationCallbackWrapper
    
    public init(frame: CGRect, dataSource: DataSource) {
        self.view = UIView(frame: frame)
        self.view.backgroundColor = UIColor.whiteColor()
        self.dataSource = dataSource
        
        // MARK: CollectionView
        self.collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        self.collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.collectionView)
        
        self.wrapper = CollectionViewWrapper(collectionView: collectionView, cellId: "RAMCell")
        
        // MARK: TextField
        self.textField = TextFieldClass()
        self.textField.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.textField.autocapitalizationType = UITextAutocapitalizationType.None
        self.textField.autocorrectionType     = UITextAutocorrectionType.No
        
        self.view.addSubview(self.textField)
        
        reactor = textField <&> dataSource *> wrapper
        
        views = [
            "collectionView": collectionView,
            "textField": textField
        ]
        
        self.keyboardCallbackWrapper = NotificationCallbackWrapper(name: UIKeyboardWillChangeFrameNotification)
        self.keyboardCallbackWrapper.callback = keyboard
        
        cascadeTheme()
        addHConstraints()
        addVConstraints()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Constraints
    private let views: [String: UIView]
    
    func addHConstraints() {
        // Horisontal constraints
        let collectionHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views) as! [NSLayoutConstraint]
        view.addConstraints(collectionHConstraints)
        
        let textFieldHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(20)-[textField]-(20)-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views) as! [NSLayoutConstraint]
        view.addConstraints(textFieldHConstraints)
    }
    
    func addVConstraints() {
        // Vertical constraints
        let collectionVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views) as! [NSLayoutConstraint]
        view.addConstraints(collectionVConstraints)
        
        bottomConstraint = collectionVConstraints.filter({ $0.firstAttribute == NSLayoutAttribute.Bottom }).first
        
        let textFieldVConstraints = [NSLayoutConstraint(item: textField, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: collectionView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)] + NSLayoutConstraint.constraintsWithVisualFormat("V:[textField(>=44)]", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views) as! [NSLayoutConstraint]
        view.addConstraints(textFieldVConstraints)
    }
    
    func keyboard(notification: NSNotification) {
        if
            let userInfo = notification.userInfo as! [String: AnyObject]?,
            
            let startFrame = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue(),
            let endFrame   = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue(),
            
            let animDuration: NSTimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue,
            let animCurveRaw = userInfo[UIKeyboardAnimationCurveUserInfoKey]?.unsignedIntegerValue
        {
            let animCurve = UIViewAnimationOptions(rawValue: UInt(animCurveRaw))
            
            self.bottomConstraint?.constant = self.view.frame.height - endFrame.origin.y
            UIView.animateWithDuration(animDuration,
                delay: 0.0,
                options: animCurve,
                animations: {
                    self.textField.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
}

class NotificationCallbackWrapper: NSObject {
    
    func callItBack(notification: NSNotification) {
        callback?(notification)
    }
    
    typealias NotificationToVoid = (NSNotification) -> ()
    var callback: NotificationToVoid?
    
    init(name: String, object: AnyObject? = nil) {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("callItBack:"),
            name: name,
            object: object
        )
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
