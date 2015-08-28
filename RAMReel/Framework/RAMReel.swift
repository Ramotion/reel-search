//
//  RAMReel.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/21/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

/**
Types that implement this protocol are expected to have string representation.
This protocol is separated from Printable and it's description property on purpose.
*/
public protocol Renderable {
    
    /**
    Implement this method in order to be able to put data to textField field
    Simplest implementation may return just object description
    */
    func render() -> String
    
}

/**
Types that implement this protocol are expected to be constructuble from string
*/
public protocol Parsable {
    
    /**
    Implement this method in order to be able to construct your data from string
    */
    static func parse(string: String) -> Self?
}

extension String: Renderable {
    
    public func render() -> String {
        return self
    }
    
}

extension String: Parsable {
    
    public static func parse(string: String) -> String? {
        return string
    }
    
}

/**
Reel class
*/
public final class RAMReel
    <
    CellClass: UICollectionViewCell,
    TextFieldClass: UITextField,
    DataSource: FlowDataSource
    where
    CellClass: ConfigurableCell,
    CellClass.DataType   == DataSource.ResultType,
    DataSource.QueryType == String,
    DataSource.ResultType: Renderable,
    DataSource.ResultType: Parsable
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
    /**
    Use this property to get which item was selected.
    Value is nil, if data source output is empty.
    */
    public var selectedItem: DataSource.ResultType? {
        return wrapper.selectedItem ?? flatMap(textField.text, DataSource.ResultType.parse)
    }
    
    // MARK: Hooks
    /**
    Type of selected item change callback hook
    */
    public typealias HookType = (DataSource.ResultType) -> ()
    /// This hooks that are called on selected item change
    public var hooks: [HookType] = []
    
    // MARK: Layout
    let layout: UICollectionViewLayout = RAMCollectionViewLayout()
    
    // MARK: Theme
    /// Visual appearance theme
    public var theme:Theme = RAMTheme.sharedTheme {
        didSet {
            updateVisuals()
        }
    }
    
    private func updateVisuals() {
        self.textField.textColor = theme.textColor
        self.textField.font = theme.font
        self.gradientView.listBackgroundColor = theme.listBackgroundColor
        
        self.view.layer.mask = self.gradientView.layer
        self.view.backgroundColor = UIColor.clearColor()
        
        self.collectionView.backgroundColor = theme.listBackgroundColor
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator   = false
        
        self.textField.autocapitalizationType = UITextAutocapitalizationType.None
        self.textField.autocorrectionType     = UITextAutocorrectionType.No
        self.textField.clearButtonMode        = UITextFieldViewMode.WhileEditing
        
        self.updatePlaceholder(self.placeholder)
        
        self.wrapper.theme = self.theme
        
        let visibleCells = self.collectionView.visibleCells() as! [CellClass]
        visibleCells.map { cell in
            cell.theme = self.theme
        }
    }
    
    var placeholder: String = "" {
        willSet {
            updatePlaceholder(newValue)
        }
    }
    
    private func updatePlaceholder(placeholder:String) {
        self.textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            NSForegroundColorAttributeName: self.theme.textColor.colorWithAlphaComponent(0.5)
            ])
    }
    
    var bottomConstraints: [NSLayoutConstraint] = []
    let keyboardCallbackWrapper: NotificationCallbackWrapper
    
    // MARK: Initialization
    /**
    :param: frame Rect that Reel will occupy
    
    :param: dataSource Object of type that implements FlowDataSource protocol
    
    :placeholder: Optional text field placeholder
    
    :hook: Optional initial value change hook
    */
    public init(frame: CGRect, dataSource: DataSource, placeholder: String = "", hook: HookType? = nil) {
        self.view = UIView(frame: frame)
        self.dataSource = dataSource
        
        if let h = hook {
            self.hooks.append(h)
        }
        
        // MARK: CollectionView
        self.collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        self.collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.collectionView)
        
        self.wrapper = CollectionViewWrapper(collectionView: collectionView, theme: self.theme)
        
        // MARK: TextField
        self.textField = TextFieldClass()
        self.textField.returnKeyType = UIReturnKeyType.Done
        self.textField.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.textField)
        
        self.placeholder = placeholder
        
        reactor = textField <&> dataSource *> wrapper
        
        self.gradientView = GradientView(frame: view.bounds)
        self.gradientView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        views = [
            "collectionView": collectionView,
            "textField": textField
        ]
        
        self.keyboardCallbackWrapper = NotificationCallbackWrapper(name: UIKeyboardWillChangeFrameNotification)
        
        let controlEvents = UIControlEvents.EditingDidEndOnExit
        returnTarget = TextFieldTarget(controlEvents: controlEvents)
        
        self.keyboardCallbackWrapper.callback = keyboard
        
        returnTarget.beTargetFor(textField)
        returnTarget.hook = { _ -> () in
            if let selectedItem = self.selectedItem
            {
                self.textField.text = selectedItem.render()
                self.hooks.map { hook -> () in
                    hook(selectedItem)
                }
                self.wrapper.data = []
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
        
        if let bottomConstraint = collectionVConstraints.filter({ $0.firstAttribute == NSLayoutAttribute.Bottom }).first {
            bottomConstraints.append(bottomConstraint)
        }
        
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
            
            self.bottomConstraints.map { (bottomConstraint: NSLayoutConstraint) -> () in
                bottomConstraint.constant = self.view.frame.height - endFrame.origin.y
            }
            
            UIView.animateWithDuration(animDuration,
                delay: 0.0,
                options: animCurve,
                animations: {
                    self.gradientView.layer.frame.size.height = endFrame.origin.y
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
