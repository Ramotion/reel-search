//
//  RAMReel.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/2/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import Foundation
import UIKit

infix operator &> { precedence 175 }

public func &>
    <
    DS: FlowDataSource,
    DD: FlowDataDestination
    where
    DS.ResultType == DD.DataType,
    DS.QueryType  == String
    >
    (left: UITextField, right: DataFlow<DS, DD>) -> TextFieldReactor<DS, DD>
{
    return TextFieldReactor(textField: left, dataFlow: right)
}

public final class TextFieldReactor
    <
    DS: FlowDataSource,
    DD: FlowDataDestination
    where
        DS.ResultType == DD.DataType,
        DS.QueryType  == String
    >
{
    
    let textField : UITextField
    let dataFlow  : DataFlow<DS, DD>
    
    private let target:Target
    
    init(textField: UITextField, dataFlow: DataFlow<DS, DD>) {
        self.textField  = textField
        self.dataFlow   = dataFlow
        
        self.target     = Target(hook: dataFlow.transport)
        
        textField.addTarget(target, action: Target.actionSelector, forControlEvents: Target.controlEvents)
    }
    
    deinit {
        textField.removeTarget(target, action: Target.actionSelector, forControlEvents: Target.controlEvents)
    }
}

final class Target: NSObject {
    
    static let actionSelector = Selector("editingChanged:")
    static let controlEvents  = UIControlEvents.EditingChanged
    
    typealias HookType = (String) -> ()
    
    let hook: HookType
    init(hook: HookType) {
        self.hook = hook
        
        super.init()
    }
    
    func editingChanged(textField: UITextField) {
        hook(textField.text)
    }
    
}
