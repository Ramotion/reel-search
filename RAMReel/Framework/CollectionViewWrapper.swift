//
//  TableViewWrapper.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/9/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

public protocol ConfigurableCell {
    
    typealias DataType
    
    func configureCell(data: DataType)
    
}

protocol WrapperProtocol {
    
    var numberOfCells: Int {get}
    
    func createCell(UICollectionView, NSIndexPath) -> UICollectionViewCell
    
}

public final class CollectionViewWrapper
    <
    DataType,
    CellClass: UICollectionViewCell
    where
        CellClass: ConfigurableCell,
        DataType == CellClass.DataType
    >: FlowDataDestination, WrapperProtocol {
    
    var data: [DataType] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    public func processData(data: [DataType]) {
        self.data = data
    }
    
    let collectionView: UICollectionView
    let cellId: String
    
    let dataSource = CollectionViewDataSource()
    let delegate   = CollectionViewDelegate()
    
    public init(collectionView: UICollectionView, cellId: String) {
        self.collectionView = collectionView
        self.cellId         = cellId
        
        collectionView.registerClass(CellClass.self, forCellWithReuseIdentifier: cellId)
        
        dataSource.wrapper   = self
        collectionView.dataSource = dataSource
    }
    
    public func createCell(cv: UICollectionView, _ ip: NSIndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: ip) as! CellClass
        
        let row  = ip.row
        let dat  = self.data[row]
        
        cell.configureCell(dat)
        
        return cell as UICollectionViewCell
    }
    
    public var numberOfCells:Int {
        return data.count
    }
    
}

class CollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    var wrapper: WrapperProtocol!
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.wrapper.numberOfCells
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.wrapper.createCell(collectionView, indexPath)
        
        return cell
    }
    
}

class CollectionViewDelegate: NSObject, UICollectionViewDelegate {
    
    
}