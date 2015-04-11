//
//  DataFlow.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/3/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

infix operator *> { precedence 180 }

public func *>
    <
    DS: FlowDataSource,
    DD: FlowDataDestination
    where DS.ResultType == DD.DataType
    >
    (left: DS, right: DD) -> DataFlow<DS, DD>
{
    return DataFlow(from: left, to: right)
}

public final class DataFlow
    <
    DS: FlowDataSource,
    DD: FlowDataDestination
    where DS.ResultType == DD.DataType
    >
{
    let from: DS
    let   to: DD
    
    private init(from: DS, to: DD) {
        self.from = from
        self.to   = to
    }
    
    func transport(query: DS.QueryType) {
        let results = from.resultsForQuery(query)
        to.processData(results)
    }
}

public protocol FlowDataSource {

    typealias QueryType = String
    typealias ResultType
    
    func resultsForQuery(query: QueryType) -> [ResultType]
    
}

public protocol FlowDataDestination {
    
    typealias DataType
    func processData(data: [DataType])
    
}

// MARK: - Example types

public struct SimplePrefixQueryDataSource: FlowDataSource {
    
    let textColor     : UIColor
    let grayedOutColor: UIColor
    
    var data: [String]
    public init(_ data: [String], textColor: UIColor = UIColor.blackColor()) {
        self.data = data
        
        self.textColor      = textColor
        self.grayedOutColor = textColor.colorWithAlphaComponent(0.3)
    }
    
    public func resultsForQuery(query: String) -> [NSAttributedString] {
        return data.filter{ $0.hasPrefix(query) }.map {
            var attributedString = NSMutableAttributedString(string: $0, attributes: [NSForegroundColorAttributeName: self.grayedOutColor])
            
            let prefixRange = ($0 as NSString).rangeOfString(query)
            attributedString.addAttribute(NSForegroundColorAttributeName, value: self.textColor, range: prefixRange)
            
            return attributedString
        }
    }
    
}
