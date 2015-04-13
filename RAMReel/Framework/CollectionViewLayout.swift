//
//  RAMCollectionViewLayout.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/9/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

@objc(RAMCollectionViewLayout)
public class RAMCollectionViewLayout: UICollectionViewFlowLayout {
    
    func itemOffset(item: Int) -> CGFloat {
        
        let halfItem  = round(Double(item)/2)
        let result = halfItem * pow(-1, Double(item))
        
        return CGFloat(result)
    }
    
    override public func layoutAttributesForItemAtIndexPath(indexPath:NSIndexPath) -> UICollectionViewLayoutAttributes {
        let attributes = super.layoutAttributesForItemAtIndexPath(indexPath)
        
        self.modifyLayoutAttributes(attributes)
        return attributes
    }
   
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject] {
        let allAttributesInRect = super.layoutAttributesForElementsInRect(rect)
        
        for cellAttributes in allAttributesInRect! {
            self.modifyLayoutAttributes(cellAttributes as! UICollectionViewLayoutAttributes)
        }
        return allAttributesInRect!
    }
    
    var itemHeight: CGFloat = 0
    func modifyLayoutAttributes(layoutattributes: UICollectionViewLayoutAttributes) {
        
        println(layoutattributes)
        
        if let collectionView = self.collectionView {
            layoutattributes.center = collectionView.center
            
            var frame              = layoutattributes.frame
            itemHeight             = frame.size.height
            
            frame.size.width       = collectionView.bounds.width
            frame.origin.x         = collectionView.bounds.origin.x
            frame.origin.y        += itemHeight * itemOffset(layoutattributes.indexPath.item)
            layoutattributes.frame = frame
        }
        
    }
    
    public override func collectionViewContentSize() -> CGSize {
        if
            let collectionView = self.collectionView,
            let number = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: 0)
        {
            let size = CGSize(width: collectionView.bounds.width, height: CGFloat(number) * itemHeight)
            return size
        }
        
        return CGSizeZero
    }
    
}
