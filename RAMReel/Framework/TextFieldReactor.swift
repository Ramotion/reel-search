//
//  RAMReel.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/2/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import Foundation
import UIKit

// MARK: -  Text field reactor operators
precedencegroup RPrecedence {
  higherThan: BitwiseShiftPrecedence
}

infix operator <&> : RPrecedence

/**
 Links text field to data flow
 
 - parameters:
    - left: Text field.
    - right: `DataFlow` object.
 
 - returns: `TextFieldReactor` object
 */
public func <&> <FlowDataSource, FlowDataDestination>
    (left: UITextField, right: DataFlow<FlowDataSource, FlowDataDestination>) -> TextFieldReactor<FlowDataSource, FlowDataDestination>
    where
    FlowDataSource.ResultType == FlowDataDestination.DataType
{
    return TextFieldReactor(textField: left, dataFlow: right)
}

// MARK: - Text field reactor

/**
 TextFieldReactor
 --
 
 Implements reactive handling text field editing and passes editing changes to data flow
 */
public struct TextFieldReactor
    <
    DS: FlowDataSource,
    DD: FlowDataDestination>
    where
    DS.ResultType == DD.DataType,
    DS.QueryType  == String
    
{
    let textField : UITextField
    let dataFlow  : DataFlow<DS, DD>
    
    fileprivate let editingTarget: TextFieldTarget
    
    fileprivate init(textField: UITextField, dataFlow: DataFlow<DS, DD>) {
        self.textField = textField
        self.dataFlow  = dataFlow
        
        self.editingTarget = TextFieldTarget(controlEvents: UIControlEvents.editingChanged, textField: textField) {
            if let text = $0.text {
                dataFlow.transport(text)
            }
        }
    }
    
}

final class TextFieldTarget: NSObject {
    
    static let actionSelector = #selector(TextFieldTarget.action(_:))
    
    typealias HookType = (UITextField) -> ()
    
    override init() {
        super.init()
    }
    
    init(controlEvents:UIControlEvents, textField: UITextField, hook: @escaping HookType) {
        super.init()
        
        self.beTargetFor(textField, controlEvents: controlEvents, hook: hook)
    }
    
    var hooks: [UITextField: HookType] = [:]
    func beTargetFor(_ textField: UITextField, controlEvents:UIControlEvents, hook: @escaping HookType) {
        textField.addTarget(self, action: TextFieldTarget.actionSelector, for: controlEvents)
        hooks[textField] = hook
    }
    
    deinit {
        for (textField, _) in hooks {
            textField.removeTarget(self, action: TextFieldTarget.actionSelector, for: UIControlEvents.allEvents)
        }
    }
    
    @objc func action(_ textField: UITextField) {
        let hook = hooks[textField]
        hook?(textField)
    }
    
}
