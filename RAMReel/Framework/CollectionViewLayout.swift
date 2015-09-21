//
//  RAMCollectionViewLayout.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/9/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

/**
  Example collection view layout
*/
@objc(RAMCollectionViewLayout)
class RAMCollectionViewLayout: UICollectionViewLayout {
    
    internal override func prepareLayout() {
        super.prepareLayout()
        
        updateInsets()
    }
    
    func updateInsets() {
        if let collectionView = self.collectionView {
            let insets = (collectionView.bounds.height - itemHeight)/2
            collectionView.contentInset = UIEdgeInsets(top: insets, left: 0, bottom: insets, right: 0)
        }
    }
    
    internal override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutAttributesForItemAtIndexPath(itemIndexPath)
    }
    
    internal override func layoutAttributesForItemAtIndexPath(indexPath:NSIndexPath) -> UICollectionViewLayoutAttributes {
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        self.modifyLayoutAttributes(attributes)
        
        return attributes
    }
    
    internal override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        
        var allAttributesInRect = [(UICollectionViewLayoutAttributes, CGFloat)]()
        
        if let numberOfItems = collectionView?.numberOfItemsInSection(0) {
            for item in 0 ..< numberOfItems {
                let indexPath = NSIndexPath(forItem: item, inSection: 0)
                
                let attributes = self.layoutAttributesForItemAtIndexPath(indexPath)
                
                if rect.intersects(attributes.frame) {
                    let intersection = CGRectIntersection(rect, attributes.frame)
                    allAttributesInRect.append((attributes, intersection.area))
                }
            }
        }
        
        allAttributesInRect.sortInPlace {
            let (_, a1) = $0
            let (_, a2) = $1
            
            return a1 > a2
        }
        
        let attributes = allAttributesInRect.map ({ (attr, _) -> UICollectionViewLayoutAttributes in
            attr
        })

        return attributes
    }
    
    var itemHeight: CGFloat = 44
    func modifyLayoutAttributes(layoutattributes: UICollectionViewLayoutAttributes) {
        
        if
            let collectionView = self.collectionView
        {
            let number = collectionView.numberOfItemsInSection(0)
            let height = CGFloat(number) * itemHeight
            
            var frame               = layoutattributes.frame
            frame.size.height       = itemHeight
            frame.size.width        = collectionView.bounds.width
            frame.origin.x          = collectionView.bounds.origin.x
            frame.origin.y          = itemHeight * CGFloat(layoutattributes.indexPath.item)
            layoutattributes.frame  = frame
        }
        
    }
    
    internal override func collectionViewContentSize() -> CGSize {
        
        if let collectionView = self.collectionView
        {
            let number = collectionView.numberOfItemsInSection(0)
            let height = CGFloat(number) * itemHeight
            
            let size = CGSize(width: collectionView.bounds.width, height: height)
            return size
        }
        
        return CGSizeZero
        
    }
}

private extension CGRect {
    
    var area: CGFloat {
        
        return self.height * self.width
        
    }
    
}