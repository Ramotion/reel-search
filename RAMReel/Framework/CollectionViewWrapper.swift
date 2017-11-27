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
    func createCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell
    
    /**
     Attributes of cells in some rect.
     
     - parameter rect Area in which you want to probe for attributes.
    */
    func cellAttributes(_ rect: CGRect) -> [UICollectionViewLayoutAttributes]
    
}

/**
 CollectionViewWrapper
 --
 
 Wraps collection view and set's collection view data source.
*/
open class CollectionViewWrapper
    <
    DataType,
    CellClass: UICollectionViewCell>: FlowDataDestination, WrapperProtocol
    where
    CellClass: ConfigurableCell,
    DataType == CellClass.DataType
 {
    private var lock : NSLock = NSLock()
    
    var data: [DataType] = [] {
        
        didSet {
            self.scrollDelegate.itemIndex = nil
            
            self.collectionView.reloadData()
            self.updateOffset()
            self.scrollDelegate.adjustScroll(self.collectionView)
        }
    }
    
    /**
     FlowDataDestination protocol implementation method.
     
     - seealso: FlowDataDestination
     
     This method processes data from data flow.
     
     - parameter data: Data array to process.
    */
    open func processData(_ data: [DataType]) {
        self.data = data
    }
    
    let collectionView: UICollectionView
    let cellId: String = "ReelCell"
    
    let dataSource       = CollectionViewDataSource()
    let collectionLayout = RAMCollectionViewLayout()
    let scrollDelegate: ScrollViewDelegate
    
    let rotationWrapper = NotificationCallbackWrapper(name: NSNotification.Name.UIDeviceOrientationDidChange.rawValue, object: UIDevice.current)
    let keyboardWrapper = NotificationCallbackWrapper(name: NSNotification.Name.UIKeyboardDidChangeFrame.rawValue)
    
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
        
        collectionView.register(CellClass.self, forCellWithReuseIdentifier: cellId)
        
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
            
            self.adjustScroll(notification as Notification)
        }
        
        keyboardWrapper.callback = { [weak self] notification in
            guard let `self` = self else {
                return
            }
            
            self.adjustScroll(notification as Notification)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var selectedItem: DataType?
    func indexCallback(_ idx: Int?) {
        guard let index = idx , 0 <= index && index < data.count else {
            selectedItem = nil
            return
        }
        
        let item = data[index]
        selectedItem = item
        
        // TODO: Update cell appearance maybe?
        // Toggle selected?
        let indexPath = IndexPath(item: index, section: 0)
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.isSelected = true
    }
    
    // MARK Implementation of WrapperProtocol
    
    func createCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CellClass
        
        let row  = (indexPath as NSIndexPath).row
        let dat  = self.data[row]
        
        cell.configureCell(dat)
        cell.theme = self.theme
        
        return cell as UICollectionViewCell
    }
    
    var numberOfCells:Int {
        return data.count
    }
    
    func cellAttributes(_ rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        let layout = collectionView.collectionViewLayout
        guard let attributes = layout.layoutAttributesForElements(in: rect) else {
            return []
        }
        
        return attributes
    }
    
    // MARK: Update & Adjust
    
    func updateOffset(_ notification: Notification? = nil) {
        let durationNumber = (notification as NSNotification?)?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber
        let duration = durationNumber?.doubleValue ?? 0.1
        
        UIView.animate(withDuration: duration, animations: {
            let number    = self.collectionView.numberOfItems(inSection: 0)
            let itemIndex = self.scrollDelegate.itemIndex ?? number/2
            
            guard itemIndex > 0 else {
                return
            }
            
            let inset      = self.collectionView.contentInset.top
            let itemHeight = self.collectionLayout.itemHeight
            let offset     = CGPoint(x: 0, y: CGFloat(itemIndex) * itemHeight - inset)
            
            self.collectionView.contentOffset = offset
        }) 
    }
    
    func adjustScroll(_ notification: Notification? = nil) {
        collectionView.contentInset = UIEdgeInsets.zero
        collectionLayout.updateInsets()
        self.updateOffset(notification)
    }
    
}

class CollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    weak var wrapper: WrapperProtocol!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let number = self.wrapper.numberOfCells
        
        return number
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.wrapper.createCell(collectionView, indexPath: indexPath)
        
        return cell
    }
    
}

class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
    
    typealias ItemIndexChangeCallback = (Int?) -> ()
    
    var itemIndexChangeCallback: ItemIndexChangeCallback?
    fileprivate(set) var itemIndex: Int? = nil {
        willSet (newIndex) {
            if let callback = itemIndexChangeCallback {
                callback(newIndex)
            }
        }
    }
    
    let itemHeight: CGFloat
    init (itemHeight: CGFloat) {
        self.itemHeight = itemHeight
        
        super.init()
    }
    
    func adjustScroll(_ scrollView: UIScrollView) {
        let inset           = scrollView.contentInset.top
        let currentOffsetY  = scrollView.contentOffset.y + inset
        let floatIndex      = currentOffsetY/itemHeight
        
        let scrollDirection = ScrollDirection.scrolledWhere(scrollFrom, scrollTo)
        let itemIndex: Int
        if scrollDirection == .up {
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
            UIView.animate(withDuration: 0.25,
                delay: 0.0,
                options: UIViewAnimationOptions.curveEaseOut,
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
        
        case up
        case down
        case noScroll
        
        static func scrolledWhere(_ from: CGFloat, _ to: CGFloat) -> ScrollDirection {
            
            if from < to {
                return .down
            }
            else if from > to {
                return .up
            }
            else {
                return .noScroll
            }
            
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollFrom = scrollView.contentOffset.y
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollTo = scrollView.contentOffset.y
        adjustScroll(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollTo = scrollView.contentOffset.y
            adjustScroll(scrollView)
        }
    }
    
}
