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
    
    /// Gradient View
    let gradientView: GradientView
    
    // MARK: TextField
    let reactor  : TextFieldReactor<DataSource, CollectionWrapperClass>
    let textField: TextFieldClass
    let returnTarget: TextFieldTarget
    
    // MARK: CollectionView
    typealias CollectionWrapperClass = CollectionViewWrapper<DataSource.ResultType, CellClass>
    let wrapper       : CollectionWrapperClass
    let collectionView: UICollectionView
    
    // MARK: Data Source
    let dataSource: DataSource
    
    // MARK: Selected Item
    public var selectedItem: DataSource.ResultType? {
        return wrapper.selectedItem
    }
    
    // MARK: Layout
    let layout: UICollectionViewLayout = RAMCollectionViewLayout()
    
    public var theme:Theme = RAMTheme.sharedTheme {
        didSet {
            updateVisuals()
        }
    }
    
    func updateVisuals() {
        self.reactor.theme      = theme
        self.gradientView.theme = theme
        
        self.view.backgroundColor = UIColor.clearColor()
        
        self.collectionView.backgroundColor = theme.listBackgroundColor
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator   = false
        
        self.textField.autocapitalizationType = UITextAutocapitalizationType.None
        self.textField.autocorrectionType     = UITextAutocorrectionType.No
        
        let visibleCells = self.collectionView.visibleCells() as! [CellClass]
        visibleCells.map { cell in
            cell.theme = self.theme
        }
    }
    
    var bottomConstraint: NSLayoutConstraint?
    let keyboardCallbackWrapper: NotificationCallbackWrapper
    
    public typealias HookType = (DataSource.ResultType) -> ()
    let hook: HookType?
    
    public init(frame: CGRect, dataSource: DataSource, placeholder: String = "", hook: HookType? = nil) {
        self.view = UIView(frame: frame)
        self.dataSource = dataSource
        self.hook = hook
        
        // MARK: CollectionView
        self.collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        self.collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.collectionView)
        
        self.wrapper = CollectionViewWrapper(collectionView: collectionView, cellId: "RAMCell")
        
        // MARK: TextField
        self.textField = TextFieldClass()
        self.textField.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.textField.placeholder = placeholder
        self.view.addSubview(self.textField)
        
        reactor = textField <&> dataSource *> wrapper
        
        self.gradientView = GradientView(frame: view.bounds)
        self.gradientView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        self.view.insertSubview(gradientView, belowSubview: textField)
        
        views = [
            "collectionView": collectionView,
            "textField": textField
        ]
        
        self.keyboardCallbackWrapper = NotificationCallbackWrapper(name: UIKeyboardWillChangeFrameNotification)
        
        let controlEvents = UIControlEvents.EditingDidEnd | UIControlEvents.EditingDidEndOnExit
        returnTarget = TextFieldTarget(controlEvents: controlEvents)
        
        self.keyboardCallbackWrapper.callback = keyboard
        
        returnTarget.beTargetFor(textField)
        returnTarget.hook = { _ -> () in
            if
                let hook = self.hook,
                let selectedItem = self.selectedItem
            {
                hook(selectedItem)
            }
        }
        
        updateVisuals()
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
