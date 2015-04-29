//
//  DataFlow.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/3/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

infix operator *> { precedence 180 }

/**
    Creates data flow from compatatible data source to data destination

    :param: left object of type, that comply to FlowDataSource protocol

    :param: right object of type, that comply to FlowDataDestination protocol
*/
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

/**
    Represent queried data flow
*/
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

/**
    Type that implement comply to protocol responds to data queries and passes data to data flow
*/
public protocol FlowDataSource {

    typealias QueryType = String
    typealias ResultType
    
    /**
        Handles data query
        
        :param: query Data query of generic data type
        
        :returns: Array of results
    */
    func resultsForQuery(query: QueryType) -> [ResultType]
    
}

/**
    Type that implements this protocol uses data from data flow
*/
public protocol FlowDataDestination {
    
    typealias DataType
    
    /**
        Processed data, recieved from data source via data flow
    
        :param: data Array to process
    */
    func processData(data: [DataType])
    
}

// MARK: - Example types

/**
    Example data source, that performs string queries over string array data
*/
public struct SimplePrefixQueryDataSource: FlowDataSource {
    
    var data: [String]
    public init(_ data: [String]) {
        self.data = data
    }
    
    public func resultsForQuery(query: String) -> [String] {
        return data.filter{ $0.hasPrefix(query) }
    }
    
}
