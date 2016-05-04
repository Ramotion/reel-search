//
//  TableViewWrapper.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/9/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

// MARK: - Collection view wrapper

/**
 WrapperProtocol
 --
 
 Helper protocol for CollectionViewWrapper.
*/
protocol WrapperProtocol : class {
    
    /// Number of cells in collection
    var numberOfCells: Int { get }
    
    /**
     Cell constructor, replaces standard Apple way of doing it.
     
     - parameters: 
        - collectionView `UICollectionView` instance in which cell should be created.
        - indexPath `NSIndexPath` where to put cell to.
     
     - returns: Fresh (or reused) cell.
     */
    func createCell(collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell
    
    /**
     Attributes of cells in some rect.
     
     - parameter rect Area in which you want to probe for attributes.
    */
    func cellAttributes(rect: CGRect) -> [UICollectionViewLayoutAttributes]
    
}

/**
 CollectionViewWrapper
 --
 
 Wraps collection view and set's collection view data source.
*/
public class CollectionViewWrapper
    <
    DataType: Equatable,
    CellClass: UICollectionViewCell
    where
    CellClass: ConfigurableCell,
    DataType == CellClass.DataType
>: FlowDataDestination, WrapperProtocol {
    
    var data: [DataType] = [] {
        didSet {
            guard data != oldValue else {
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.scrollDelegate.itemIndex = nil
                
                self.collectionView.reloadData()
                self.updateOffset()
                self.scrollDelegate.adjustScroll(self.collectionView)
            }
        }
    }
    
    /**
     FlowDataDestination protocol implementation method.
     
     - seealso: FlowDataDestination
     
     This method processes data from data flow.
     
     - parameter data: Data array to process.
    */
    public func processData(data: [DataType]) {
        self.data = data
    }
    
    let collectionView: UICollectionView
    let cellId: String = "ReelCell"
    
    let dataSource       = CollectionViewDataSource()
    let collectionLayout = RAMCollectionViewLayout()
    let scrollDelegate: ScrollViewDelegate
    
    let rotationWrapper = NotificationCallbackWrapper(name: UIDeviceOrientationDidChangeNotification, object: UIDevice.currentDevice())
    let keyboardWrapper = NotificationCallbackWrapper(name: UIKeyboardDidChangeFrameNotification)
    
    var theme: Theme
    
    /**
     - parameters:
        - collectionView: Collection view to wrap around.
        - theme: Visual theme of collection view.
    */
    public init(collectionView: UICollectionView, theme: Theme) {
        self.collectionView = collectionView
        self.theme = theme
        
        self.scrollDelegate = ScrollViewDelegate(itemHeight: collectionLayout.itemHeight)
        
        self.scrollDelegate.itemIndexChangeCallback = indexCallback
        
        collectionView.registerClass(CellClass.self, forCellWithReuseIdentifier: cellId)
        
        dataSource.wrapper        = self
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = collectionLayout
        collectionView.bounces    = false
        
        let scrollView = collectionView as UIScrollView
        scrollView.delegate = scrollDelegate
        
        rotationWrapper.callback = { [weak self] notification in
            guard let `self` = self else {
                return
            }
            
            self.adjustScroll(notification)
        }
        
        keyboardWrapper.callback = { [weak self] notification in
            guard let `self` = self else {
                return
            }
            
            self.adjustScroll(notification)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    var selectedItem: DataType?
    func indexCallback(idx: Int?) {
        if let index = idx
            where 0 <= index && index < data.count {
                let item = data[index]
                selectedItem = item
                
                // TODO: Update cell appearance maybe?
                // Toggle selected?
                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                let cell = collectionView.cellForItemAtIndexPath(indexPath)
                cell?.selected = true
        }
        else {
            selectedItem = nil
        }
    }
    
    // MARK Implementation of WrapperProtocol
    
    func createCell(collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as! CellClass
        
        let row  = indexPath.row
        let dat  = self.data[row]
        
        cell.configureCell(dat)
        cell.theme = self.theme
        
        return cell as UICollectionViewCell
    }
    
    var numberOfCells:Int {
        return data.count
    }
    
    func cellAttributes(rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        let layout = collectionView.collectionViewLayout
        if let attributes    = layout.layoutAttributesForElementsInRect(rect)
        {
            return attributes
        }
        
        return []
    }
    
    // MARK: Update & Adjust
    
    func updateOffset(notification: NSNotification? = nil) {
        let durationNumber = notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber
        let duration = durationNumber?.doubleValue ?? 0.1
        
        UIView.animateWithDuration(duration) {
            let number    = self.collectionView.numberOfItemsInSection(0)
            let itemIndex = self.scrollDelegate.itemIndex ?? number/2
            
            if itemIndex > 0 {
                let inset      = self.collectionView.contentInset.top
                let itemHeight = self.collectionLayout.itemHeight
                let offset     = CGPoint(x: 0, y: CGFloat(itemIndex) * itemHeight - inset)
                
                self.collectionView.contentOffset = offset
            }
        }
    }
    
    func adjustScroll(notification: NSNotification? = nil) {
        collectionView.contentInset = UIEdgeInsetsZero
        collectionLayout.updateInsets()
        self.updateOffset(notification)
    }
    
}

class CollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    weak var wrapper: WrapperProtocol!
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let number = self.wrapper.numberOfCells
        
        return number
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.wrapper.createCell(collectionView, indexPath: indexPath)
        
        return cell
    }
    
}

class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
    
    typealias ItemIndexChangeCallback = (Int?) -> ()
    
    var itemIndexChangeCallback: ItemIndexChangeCallback?
    private(set) var itemIndex: Int? = nil {
        willSet (newIndex) {
            if let callback = itemIndexChangeCallback
            {
                callback(newIndex)
            }
        }
    }
    
    let itemHeight: CGFloat
    init (itemHeight: CGFloat) {
        self.itemHeight = itemHeight
        
        super.init()
    }
    
    func adjustScroll(scrollView: UIScrollView) {
        let inset           = scrollView.contentInset.top
        let currentOffsetY  = scrollView.contentOffset.y + inset
        let floatIndex      = currentOffsetY/itemHeight
        
        let scrollDirection = ScrollDirection.scrolledWhere(scrollFrom, scrollTo)
        let itemIndex: Int
        if scrollDirection == .Up {
            itemIndex = Int(floor(floatIndex))
        }
        else {
            itemIndex = Int(ceil(floatIndex))
        }
        
        let adjestedOffsetY = CGFloat(itemIndex) * itemHeight - inset
        
        if itemIndex >= 0 {
            self.itemIndex = itemIndex
        }
        
        // Difference between actual and designated position in pixels
        let Δ = fabs(scrollView.contentOffset.y - adjestedOffsetY)
        // Allowed differenct between actual and designated position in pixels
        let ε:CGFloat = 0.5
        
        // If difference is larger than allowed, then adjust position animated
        if Δ > ε {            
            UIView.animateWithDuration(0.25,
                delay: 0.0,
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: {
                    let newOffset = CGPoint(x: 0, y: adjestedOffsetY)
                    scrollView.contentOffset = newOffset
                },
                completion: nil)
        }
    }
    
    var scrollFrom: CGFloat = 0
    var scrollTo:   CGFloat = 0
    
    enum ScrollDirection {
        
        case Up
        case Down
        case NoScroll
        
        static func scrolledWhere(from: CGFloat, _ to: CGFloat) -> ScrollDirection {
            
            if from < to {
                return .Down
            }
            else if from > to {
                return .Up
            }
            else {
                return .NoScroll
            }
            
        }
        
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollFrom = scrollView.contentOffset.y
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollTo = scrollView.contentOffset.y
        adjustScroll(scrollView)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollTo = scrollView.contentOffset.y
            adjustScroll(scrollView)
        }
    }
    
}