//
//  RAMReel.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/21/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

// MARK: - String conversions

/**
 Renderable
 --
 
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

extension String: Renderable {
    
    /// String is trivially renderable: it renders to itself.
    public func render() -> String {
        return self
    }
    
}

/**
 Parsable
 --
 
 Types that implement this protocol are expected to be constructible from string
 */
public protocol Parsable {
    
    /**
     Implement this method in order to be able to construct your data from string
     
     - parameter string: String to parse.
     - returns: Value of type, implementing this protocol if successful, `nil` otherwise.
     */
    static func parse(string: String) -> Self?
}

extension String: Parsable {
    
    /** 
    String is trivially parsable: it parses to itself.
     
    - parameter string: String to parse.
    - returns: `string` parameter value.
    */
    public static func parse(string: String) -> String? {
        return string
    }
    
}

// MARK: - Library root class

/**
 RAMReel
 --
 
 Reel class
 */
public class RAMReel
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
    let reactor: TextFieldReactor<DataSource, CollectionWrapperClass>
    let textField: TextFieldClass
    let returnTarget: TextFieldTarget
    let gestureTarget: GestureTarget
    let dataFlow: DataFlow<DataSource, CollectionViewWrapper<CellClass.DataType, CellClass>>
    
    /// Delegate of text field, is used for extra control over text field.
    public var textFieldDelegate: UITextFieldDelegate? {
        set { textField.delegate = newValue }
        get { return textField.delegate }
    }
    
    /// Use this method when you want textField release input focus.
    public func resignFirstResponder() {
        self.textField.resignFirstResponder()
    }
    
    // MARK: CollectionView
    typealias CollectionWrapperClass = CollectionViewWrapper<DataSource.ResultType, CellClass>
    let wrapper: CollectionWrapperClass
    /// Collection view with data items.
    public let collectionView: UICollectionView
    
    // MARK: Data Source
    /// Data source of RAMReel
    public let dataSource: DataSource
    
    // MARK: Selected Item
    /**
    Use this property to get which item was selected.
    Value is nil, if data source output is empty.
    */
    public var selectedItem: DataSource.ResultType? {
        return textField.text.flatMap(DataSource.ResultType.parse)
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
    public var theme: Theme = RAMTheme.sharedTheme {
        didSet {
            guard theme.font != oldValue.font
                    ||
                    theme.listBackgroundColor != oldValue.listBackgroundColor
                    ||
                    theme.textColor != oldValue.textColor
                else {
                    return
            }
            
            updateVisuals()
            updatePlaceholder(self.placeholder)
        }
    }
    
    private func updateVisuals() {
        self.view.tintColor = theme.textColor
        
        self.textField.font = theme.font
        self.textField.textColor = theme.textColor
        (self.textField as UITextField).tintColor = theme.textColor
        self.textField.keyboardAppearance = UIKeyboardAppearance.Dark
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
        
        let visibleCells: [CellClass] = self.collectionView.visibleCells() as! [CellClass]
        visibleCells.forEach { (cell: CellClass) -> Void in
            var cell = cell
            cell.theme = self.theme
        }
    }
    
    /// Placeholder in text field.
    public var placeholder: String = "" {
        willSet {
            updatePlaceholder(newValue)
        }
    }
    
    private func updatePlaceholder(placeholder:String) {
        let themeFont = self.theme.font
        let size = self.textField.textRectForBounds(textField.bounds).height * themeFont.pointSize / themeFont.lineHeight * 0.8
        let font = (size > 0) ? (UIFont(name: themeFont.fontName, size: size) ?? themeFont) : themeFont
        self.textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: self.theme.textColor.colorWithAlphaComponent(0.5)
            ])
    }
    
    var bottomConstraints: [NSLayoutConstraint] = []
    let keyboardCallbackWrapper: NotificationCallbackWrapper
    
    // MARK: Initialization
    /**
    Creates new `RAMReel` instance.
    
    - parameters:
        - frame: Rect that Reel will occupy
        - dataSource: Object of type that implements FlowDataSource protocol
        - placeholder: Optional text field placeholder
        - hook: Optional initial value change hook
    */
    public init(frame: CGRect, dataSource: DataSource, placeholder: String = "", hook: HookType? = nil) {
        self.view = UIView(frame: frame)
        self.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view.translatesAutoresizingMaskIntoConstraints = true
        self.dataSource = dataSource
        
        if let h = hook {
            self.hooks.append(h)
        }
        
        // MARK: CollectionView
        self.collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.collectionView)
        
        self.wrapper = CollectionViewWrapper(collectionView: collectionView, theme: self.theme)
        
        // MARK: TextField
        self.textField = TextFieldClass()
        self.textField.returnKeyType = UIReturnKeyType.Done
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.textField)
        
        self.placeholder = placeholder
        
        dataFlow = dataSource *> wrapper
        reactor = textField <&> dataFlow
        
        self.gradientView = GradientView(frame: view.bounds)
        self.gradientView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        self.gradientView.translatesAutoresizingMaskIntoConstraints = true
        self.view.insertSubview(self.gradientView, atIndex: 0)
        
        views = [
            "collectionView": collectionView,
            "textField": textField
        ]
        
        self.keyboardCallbackWrapper = NotificationCallbackWrapper(name: UIKeyboardWillChangeFrameNotification)
        
        returnTarget  = TextFieldTarget()
        gestureTarget = GestureTarget()
        
        let controlEvents = UIControlEvents.EditingDidEndOnExit
        returnTarget.beTargetFor(textField, controlEvents: controlEvents) { textField -> () in
            if
                let text = textField.text,
                let item = DataSource.ResultType.parse(text)
            {
                for hook in self.hooks {
                    hook(item)
                }
                self.wrapper.data = []
            }
        }
        
        gestureTarget.recognizeFor(collectionView, type: GestureTarget.GestureType.Tap) { [weak self] _ in
            if
                let `self` = self,
                let selectedItem = self.wrapper.selectedItem
            {
                self.textField.becomeFirstResponder()
                self.textField.text = nil
                self.textField.insertText(selectedItem.render())
            }
        }
        
        gestureTarget.recognizeFor(collectionView, type: GestureTarget.GestureType.Swipe) { _,_ in }
        
        self.keyboardCallbackWrapper.callback = keyboard
        
        updateVisuals()
        addHConstraints()
        addVConstraints()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /// Call this method to update `RAMReel` visuals before showing it.
    public func prepareForViewing() {
        updateVisuals()
        updatePlaceholder(self.placeholder)
    }
    
    /// If you use `RAMReel` to enter set of values from the list call this method before each input.
    public func prepareForReuse() {
        self.textField.text = ""
        self.dataFlow.transport("")
    }
    
    // MARK: Constraints
    private let views: [String: UIView]
    
    func addHConstraints() {
        // Horisontal constraints
        let collectionHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views)
        view.addConstraints(collectionHConstraints)
        
        let textFieldHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(20)-[textField]-(20)-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views)
        view.addConstraints(textFieldHConstraints)
    }
    
    func addVConstraints() {
        // Vertical constraints
        let collectionVConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views)
        view.addConstraints(collectionVConstraints)
        
        if let bottomConstraint = collectionVConstraints.filter({ $0.firstAttribute == NSLayoutAttribute.Bottom }).first {
            bottomConstraints.append(bottomConstraint)
        }
        
        let textFieldVConstraints = [NSLayoutConstraint(item: textField, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: collectionView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)] + NSLayoutConstraint.constraintsWithVisualFormat("V:[textField(>=44)]", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views)
        view.addConstraints(textFieldVConstraints)
    }
    
    func keyboard(notification: NSNotification) {
        if
            let userInfo = notification.userInfo as! [String: AnyObject]?,
            
            let endFrame   = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue,
            
            let animDuration: NSTimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue,
            let animCurveRaw = userInfo[UIKeyboardAnimationCurveUserInfoKey]?.unsignedIntegerValue
        {
            let animCurve = UIViewAnimationOptions(rawValue: UInt(animCurveRaw))
                
            for bottomConstraint in self.bottomConstraints {
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

// MARK: - Helpers

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
            selector: #selector(NotificationCallbackWrapper.callItBack(_:)),
            name: name,
            object: object
        )
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}

final class GestureTarget: NSObject, UIGestureRecognizerDelegate {
    
    static let gestureSelector = #selector(GestureTarget.gesture(_:))
    
    override init() {
        super.init()
    }
    
    init(type: GestureType, view: UIView, hook: HookType) {
        super.init()
        
        recognizeFor(view, type: type, hook: hook)
    }
    
    typealias HookType = (UIView, UIGestureRecognizer) -> ()
    
    enum GestureType {
        case Tap
        case LongPress
        case Swipe
    }
    
    var hooks: [UIGestureRecognizer: (UIView, HookType)] = [:]
    func recognizeFor(view: UIView, type: GestureType, hook: HookType) {
        let gestureRecognizer: UIGestureRecognizer
        switch type {
        case .Tap:
            gestureRecognizer = UITapGestureRecognizer(target: self, action: GestureTarget.gestureSelector)
        case .LongPress:
            gestureRecognizer = UILongPressGestureRecognizer(target: self, action: GestureTarget.gestureSelector)
        case .Swipe:
            gestureRecognizer = UISwipeGestureRecognizer(target: self, action: GestureTarget.gestureSelector)
        }
        
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        hooks[gestureRecognizer] = (view, hook)
    }
    
    deinit {
        for (recognizer, (view, _)) in hooks {
            view.removeGestureRecognizer(recognizer)
        }
    }
    
    func gesture(gestureRecognizer: UIGestureRecognizer) {
        if let (textField, hook) = hooks[gestureRecognizer] {
            hook(textField, gestureRecognizer)
        }
    }
    
    // Gesture recognizer delegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}