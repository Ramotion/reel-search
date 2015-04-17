//
//  TableViewWrapper.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/9/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

protocol WrapperProtocol : class {
    
    var numberOfCells: Int { get }
    
    func createCell(UICollectionView, NSIndexPath) -> UICollectionViewCell
    
    func cellAttributes(rect: CGRect) -> [UICollectionViewLayoutAttributes]
    
}

public class CollectionViewWrapper
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
            collectionView.layoutIfNeeded()
            
            let number = collectionView.numberOfItemsInSection(0)
            if number > 0 {
                let middle = number/2

                let indexPath: NSIndexPath = NSIndexPath(forItem: middle, inSection: 0)
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
                    let topInset = collectionView.contentInset.top
                    collectionView.contentOffset = CGPoint(x: 0, y: cell.frame.minY - topInset)
                }
            }
        }
    }
    
    public func processData(data: [DataType]) {
        self.data = data
    }
    
    let collectionView: UICollectionView
    let cellId: String
    
    let dataSource       = CollectionViewDataSource()
    let collectionLayout = RAMCollectionViewLayout()
    let scrollDelegate: ScrollViewDelegate
    
    public init(collectionView: UICollectionView, cellId: String) {
        self.collectionView = collectionView
        self.cellId         = cellId
        self.scrollDelegate = ScrollViewDelegate(itemHeight: collectionLayout.itemHeight)

        collectionView.registerClass(CellClass.self, forCellWithReuseIdentifier: cellId)
        
        dataSource.wrapper        = self
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = collectionLayout
        
        let scrollView = collectionView as UIScrollView
        scrollView.delegate = scrollDelegate
    }
    
    func createCell(cv: UICollectionView, _ ip: NSIndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: ip) as! CellClass
        
        let row  = ip.row
        let dat  = self.data[row]
        
        cell.configureCell(dat)
        
        return cell as UICollectionViewCell
    }
    
    var numberOfCells:Int {
        return data.count
    }
    
    public func cellAttributes(rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        let layout     = collectionView.collectionViewLayout
        if
            let returns    = layout.layoutAttributesForElementsInRect(rect),
            let attributes = returns as? [UICollectionViewLayoutAttributes]
        {
            return attributes
        }
    
        return []
    }
    
}

class CollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    weak var wrapper: WrapperProtocol!
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let number = self.wrapper.numberOfCells
        
        return number
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.wrapper.createCell(collectionView, indexPath)
        
        return cell
    }
    
}

class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
    
    let itemHeight: CGFloat
    init (itemHeight: CGFloat) {
        self.itemHeight = itemHeight
        
        super.init()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let inset           = scrollView.contentInset.top
        let currentOffsetY  = scrollView.contentOffset.y + inset
        let itemIndex       = round(currentOffsetY/itemHeight)
        let adjestedOffsetY = itemIndex * itemHeight - inset
        
        let topBorder   : CGFloat = 0                        // Zero offset means that we really have inset size padding at top
        let bottomBorder: CGFloat = scrollView.bounds.height // Max offset is scrollView height without vertical insets
        
        if currentOffsetY.between(topBorder, bottomBorder) && currentOffsetY != adjestedOffsetY {
            
            UIView.performWithoutAnimation({
                let newOffset = CGPoint(x: 0, y: adjestedOffsetY)
                scrollView.contentOffset = newOffset
            })

        }
    }
}

extension CGFloat {
    
    func between(a: CGFloat, _ b: CGFloat) -> Bool {
        return (a <= self) && (self <= b)
    }
    
}