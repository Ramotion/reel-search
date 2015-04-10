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
    
    func modifyLayoutAttributes(layoutattributes: UICollectionViewLayoutAttributes) {
        
        if let collectionView = self.collectionView {
            layoutattributes.center = collectionView.center
            
            var frame              = layoutattributes.frame
            frame.size.width       = collectionView.bounds.width
            frame.origin.x         = collectionView.bounds.origin.x
            frame.origin.y        += frame.size.height * itemOffset(layoutattributes.indexPath.item)
            layoutattributes.frame = frame
        }
        
    }
    
}
