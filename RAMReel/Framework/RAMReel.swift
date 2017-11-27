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
    static func parse(_ string: String) -> Self?
}

extension String: Parsable {
    
    /** 
    String is trivially parsable: it parses to itself.
     
    - parameter string: String to parse.
    - returns: `string` parameter value.
    */
    public static func parse(_ string: String) -> String? {
        return string
    }
    
}

// MARK: - Library root class

/**
 RAMReel
 --
 
 Reel class
 */
open class RAMReel
    <
    CellClass: UICollectionViewCell,
    TextFieldClass: UITextField,
    DataSource: FlowDataSource>
    where
    CellClass: ConfigurableCell,
    CellClass.DataType   == DataSource.ResultType,
    DataSource.QueryType == String,
    DataSource.ResultType: Renderable,
    DataSource.ResultType: Parsable
 {
    /// Container view
    open let view: UIView
    
    /// Gradient View
    let gradientView: GradientView
    
    // MARK: TextField
    let reactor: TextFieldReactor<DataSource, CollectionWrapperClass>
    let textField: TextFieldClass
    let returnTarget: TextFieldTarget
    private var untouchedTarget : TextFieldTarget? = nil
    let gestureTarget: GestureTarget
    let dataFlow: DataFlow<DataSource, CollectionViewWrapper<CellClass.DataType, CellClass>>
    
    /// Delegate of text field, is used for extra control over text field.
    open var textFieldDelegate: UITextFieldDelegate? {
        set { textField.delegate = newValue }
        get { return textField.delegate }
    }
    
    /// Use this method when you want textField release input focus.
    open func resignFirstResponder() {
        self.textField.resignFirstResponder()
    }
    
    // MARK: CollectionView
    typealias CollectionWrapperClass = CollectionViewWrapper<DataSource.ResultType, CellClass>
    let wrapper: CollectionWrapperClass
    /// Collection view with data items.
    open let collectionView: UICollectionView
    
    // MARK: Data Source
    /// Data source of RAMReel
    open let dataSource: DataSource
    
    // MARK: Selected Item
    /**
    Use this property to get which item was selected.
    Value is nil, if data source output is empty.
    */
    open var selectedItem: DataSource.ResultType? {
        return textField.text.flatMap(DataSource.ResultType.parse)
    }
    
    // MARK: Hooks
    /**
    Type of selected item change callback hook
    */
    public typealias HookType = (DataSource.ResultType) -> ()
    /// This hooks that are called on selected item change
    open var hooks: [HookType] = []
    
    // MARK: Layout
    let layout: UICollectionViewLayout = RAMCollectionViewLayout()
    
    // MARK: Theme
    /// Visual appearance theme
    open var theme: Theme = RAMTheme.sharedTheme {
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
    
    fileprivate func updateVisuals() {
        self.view.tintColor = theme.textColor
        
        self.textField.font = theme.font
        self.textField.textColor = theme.textColor
        (self.textField as UITextField).tintColor = theme.textColor
        self.textField.keyboardAppearance = UIKeyboardAppearance.dark
        self.gradientView.listBackgroundColor = theme.listBackgroundColor
        
        self.view.layer.mask = self.gradientView.layer
        self.view.backgroundColor = UIColor.clear
        
        self.collectionView.backgroundColor = theme.listBackgroundColor
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator   = false
        
        self.textField.autocapitalizationType = UITextAutocapitalizationType.none
        self.textField.autocorrectionType     = UITextAutocorrectionType.no
        self.textField.clearButtonMode        = UITextFieldViewMode.whileEditing
        
        self.updatePlaceholder(self.placeholder)
        
        self.wrapper.theme = self.theme
        
        let visibleCells: [CellClass] = self.collectionView.visibleCells as! [CellClass]
        visibleCells.forEach { (cell: CellClass) -> Void in
            var cell = cell
            cell.theme = self.theme
        }
    }
    
    /// Placeholder in text field.
    open var placeholder: String = "" {
        willSet {
            updatePlaceholder(newValue)
        }
    }
    
    fileprivate func updatePlaceholder(_ placeholder:String) {
        let themeFont = self.theme.font
        let size = self.textField.textRect(forBounds: textField.bounds).height * themeFont.pointSize / themeFont.lineHeight * 0.8
        let font = (size > 0) ? (UIFont(name: themeFont.fontName, size: size) ?? themeFont) : themeFont
        self.textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.foregroundColor: self.theme.textColor.withAlphaComponent(0.5)
            ])
    }
    
    var bottomConstraints: [NSLayoutConstraint] = []
    let keyboardCallbackWrapper: NotificationCallbackWrapper
    let attemptToDodgeKeyboard : Bool
    
    // MARK: Initialization
    /**
    Creates new `RAMReel` instance.
    
    - parameters:
        - frame: Rect that Reel will occupy
        - dataSource: Object of type that implements FlowDataSource protocol
        - placeholder: Optional text field placeholder
        - hook: Optional initial value change hook
        - attemptToDodgeKeyboard: attempt to center the widget on the available screen area when the iOS
              keyboard appears (will cause issues if the widget isn't being used in full screen)
    */
    public init(frame: CGRect, dataSource: DataSource, placeholder: String = "", attemptToDodgeKeyboard: Bool, hook: HookType? = nil) {
        self.view = UIView(frame: frame)
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.translatesAutoresizingMaskIntoConstraints = true
        self.dataSource = dataSource
        
        self.attemptToDodgeKeyboard = attemptToDodgeKeyboard
        
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
        self.textField.returnKeyType = UIReturnKeyType.done
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.textField)
        
        self.placeholder = placeholder
        
        dataFlow = dataSource *> wrapper
        reactor = textField <&> dataFlow
        
        self.gradientView = GradientView(frame: view.bounds)
        self.gradientView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.gradientView.translatesAutoresizingMaskIntoConstraints = true
        self.view.insertSubview(self.gradientView, at: 0)
        
        views = [
            "collectionView": collectionView,
            "textField": textField
        ]
        
        self.keyboardCallbackWrapper = NotificationCallbackWrapper(name: NSNotification.Name.UIKeyboardWillChangeFrame.rawValue)
        
        returnTarget  = TextFieldTarget()
        gestureTarget = GestureTarget()
        
        let controlEvents = UIControlEvents.editingDidEndOnExit
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
        
        gestureTarget.recognizeFor(collectionView, type: GestureTarget.GestureType.tap) { [weak self] _, _ in
            if
                let `self` = self,
                let selectedItem = self.wrapper.selectedItem
            {
                self.textField.becomeFirstResponder()
                self.textField.text = nil
                self.textField.insertText(selectedItem.render())
            }
        }
        
        gestureTarget.recognizeFor(collectionView, type: GestureTarget.GestureType.swipe) { _,_ in }
        
        weak var s = self
        
        self.untouchedTarget = TextFieldTarget(controlEvents: UIControlEvents.editingChanged, textField: self.textField, hook: {_ in s?.placeholder = "";})
        
        self.keyboardCallbackWrapper.callback = keyboard
        
        updateVisuals()
        addHConstraints()
        addVConstraints()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Call this method to update `RAMReel` visuals before showing it.
    open func prepareForViewing() {
        updateVisuals()
        updatePlaceholder(self.placeholder)
    }
    
    /// If you use `RAMReel` to enter a set of values from the list call this method before each input.
    open func prepareForReuse() {
        self.textField.text = ""
        self.dataFlow.transport("")
    }
    
    // MARK: Constraints
    fileprivate let views: [String: UIView]
    
    func addHConstraints() {
        // Horisontal constraints
        let collectionHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: views)
        view.addConstraints(collectionHConstraints)
        
        let textFieldHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[textField]-(20)-|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: views)
        view.addConstraints(textFieldHConstraints)
    }
    
    func addVConstraints() {
        // Vertical constraints
        let collectionVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views)
        view.addConstraints(collectionVConstraints)
        
        if let bottomConstraint = collectionVConstraints.filter({ $0.firstAttribute == NSLayoutAttribute.bottom }).first {
            bottomConstraints.append(bottomConstraint)
        }
        
        let textFieldVConstraints = [NSLayoutConstraint(item: textField, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: collectionView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0)] + NSLayoutConstraint.constraints(withVisualFormat: "V:[textField(>=44)]", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views)
        view.addConstraints(textFieldVConstraints)
    }
    
    func keyboard(_ notification: Notification) {
        if
            let userInfo = (notification as NSNotification).userInfo as! [String: AnyObject]?,
            
            let endFrame   = userInfo[UIKeyboardFrameEndUserInfoKey]?.cgRectValue,
            
            let animDuration: TimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue,
            let animCurveRaw = userInfo[UIKeyboardAnimationCurveUserInfoKey]?.uintValue
        {
            if(attemptToDodgeKeyboard){
            let animCurve = UIViewAnimationOptions(rawValue: UInt(animCurveRaw))
                
            for bottomConstraint in self.bottomConstraints {
                bottomConstraint.constant = self.view.frame.height - endFrame.origin.y                    
            }
            
            UIView.animate(withDuration: animDuration,
                delay: 0.0,
                options: animCurve,
                animations: {
                    self.gradientView.layer.frame.size.height = endFrame.origin.y
                    self.textField.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
    
}

// MARK: - Helpers

class NotificationCallbackWrapper: NSObject {
    
    @objc func callItBack(_ notification: Notification) {
        callback?(notification)
    }
    
    typealias NotificationToVoid = (Notification) -> ()
    var callback: NotificationToVoid?
    
    init(name: String, object: AnyObject? = nil) {
        super.init()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(NotificationCallbackWrapper.callItBack(_:)),
            name: NSNotification.Name(rawValue: name),
            object: object
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

final class GestureTarget: NSObject, UIGestureRecognizerDelegate {
    
    static let gestureSelector = #selector(GestureTarget.gesture(_:))
    
    override init() {
        super.init()
    }
    
    init(type: GestureType, view: UIView, hook: @escaping HookType) {
        super.init()
        
        recognizeFor(view, type: type, hook: hook)
    }
    
    typealias HookType = (UIView, UIGestureRecognizer) -> ()
    
    enum GestureType {
        case tap
        case longPress
        case swipe
    }
    
    var hooks: [UIGestureRecognizer: (UIView, HookType)] = [:]
    func recognizeFor(_ view: UIView, type: GestureType, hook: @escaping HookType) {
        let gestureRecognizer: UIGestureRecognizer
        switch type {
        case .tap:
            gestureRecognizer = UITapGestureRecognizer(target: self, action: GestureTarget.gestureSelector)
        case .longPress:
            gestureRecognizer = UILongPressGestureRecognizer(target: self, action: GestureTarget.gestureSelector)
        case .swipe:
            gestureRecognizer = UISwipeGestureRecognizer(target: self, action: GestureTarget.gestureSelector)
        }
        
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
      let item: (UIView, HookType) = (view, hook)
        hooks[gestureRecognizer] = item
    }
    
    deinit {
        for (recognizer, (view, _)) in hooks {
            view.removeGestureRecognizer(recognizer)
        }
    }
    
    @objc func gesture(_ gestureRecognizer: UIGestureRecognizer) {
        if let (textField, hook) = hooks[gestureRecognizer] {
            hook(textField, gestureRecognizer)
        }
    }
    
    // Gesture recognizer delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
