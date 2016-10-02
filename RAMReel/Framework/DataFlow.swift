//
//  DataFlow.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/3/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

// MARK: - Data flow operators

infix operator *> { precedence 180 }

/**
    Creates data flow from compatatible data source to data destination

    - parameter left: Object of type that comply to FlowDataSource protocol.
    - parameter right: Object of type that comply to FlowDataDestination protocol.

    - returns: `DataFlow` from source to destination.
*/
public func *>
    <
    DS: FlowDataSource,
    DD: FlowDataDestination>
    (left: DS, right: DD) -> DataFlow<DS, DD>
    where DS.ResultType == DD.DataType
    
{
    return DataFlow(from: left, to: right)
}

// MARK: - Data flow

/**
 DataFlow
 --
 
 Represent queried data flow
*/
public struct DataFlow
    <
    DS: FlowDataSource,
    DD: FlowDataDestination>
    where DS.ResultType == DD.DataType
    
{
    let from: DS
    let   to: DD
    
    fileprivate init(from: DS, to: DD) {
        self.from = from
        self.to   = to
    }
    
    func transport(_ query: DS.QueryType) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            let results = self.from.resultsForQuery(query)
            self.to.processData(results)
        }
    }
}

/**
    Type that implement comply to protocol responds to data queries and passes data to data flow
*/
public protocol FlowDataSource {

    associatedtype QueryType = String
    associatedtype ResultType
    
    /**
        Handles data query
        
        - parameter query: Data query of generic data type
        
        - returns: Array of results
    */
    func resultsForQuery(_ query: QueryType) -> [ResultType]
    
}

/**
    Type that implements this protocol uses data from data flow
*/
public protocol FlowDataDestination {
    
    associatedtype DataType
    
    /**
        Processed data, recieved from data source via data flow
    
        - parameter data: Array to process
    */
    func processData(_ data: [DataType])
    
}

// MARK: - Simple data source

/**
    Example data source, that performs string queries over string array data
*/
public struct SimplePrefixQueryDataSource: FlowDataSource {
    
    var data: [String]
    /// Creates data source with data array
    public init(_ data: [String]) {
        self.data = data
    }
    
    /// Returns all the strings that starts with query string
    public func resultsForQuery(_ query: String) -> [String] {
        return data.filter{ $0.hasPrefix(query) }
    }
    
}
