//
//  GWCollectionViewFlowLayout.swift
//  GWCollectionViewFlowLayout
//
//  Created by langyue on 16/8/10.
//  Copyright © 2016年 langyue. All rights reserved.
//

import UIKit



@objc protocol GWCollectionViewDelegateFlowLayout : UICollectionViewDelegateFlowLayout{

    func collectionView(collectionView:UICollectionView, layout collectionViewLayout: GWCollectionViewFlowLayout,numberOfColumnInSection section: Int) -> NSInteger

}





class GWCollectionViewFlowLayout: UICollectionViewFlowLayout {



    private var sectionRects = NSMutableArray()
    private var columnRectsInSection = NSMutableArray()
    private var layoutItemAttributes = NSMutableArray()
    private var headerItemAttributes = NSMutableArray()
    private var footerItemAttributes = NSMutableArray()
    private var sectionInsetses = NSMutableArray()
    private var currentEdgeInsets : UIEdgeInsets = UIEdgeInsetsZero


    //
    weak var delegate : GWCollectionViewDelegateFlowLayout?
    var enableStickyHeaders = false

    //


    override func collectionViewContentSize() -> CGSize {
        super.collectionViewContentSize()

        let lastSectionRect = sectionRects.lastObject?.CGRectValue()
        let lastSize = CGSizeMake(collectionView!.bounds.width, lastSectionRect!.maxY)
        return lastSize

    }

    override func prepareLayout() {

        let numberOfSections : Int = collectionView!.numberOfSections()

        layoutItemAttributes.removeAllObjects()

        footerItemAttributes.removeAllObjects()

        headerItemAttributes.removeAllObjects()

        sectionRects.removeAllObjects()

        columnRectsInSection.removeAllObjects()

        for i in 0 ..< numberOfSections {

            let itemsInSection = self.collectionView?.numberOfItemsInSection(i)
            layoutItemAttributes.addObject(NSMutableArray.init(capacity: 0))
            self.prepareLayoutInSection(i, numberOfItems: itemsInSection!)

        }

    }



    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {

        return layoutItemAttributes[indexPath.section].objectAtIndex(indexPath.item) as? UICollectionViewLayoutAttributes

    }


    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {

        if elementKind == UICollectionElementKindSectionHeader {

            return headerItemAttributes[indexPath.section] as? UICollectionViewLayoutAttributes

        }else{

            return footerItemAttributes[indexPath.section] as? UICollectionViewLayoutAttributes

        }

    }



    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        return self.searchVisibleLayoutAttributesInRect(rect)

    }

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return self.enableStickyHeaders
    }

//====

    private func prepareLayoutInSection(index: Int,numberOfItems items: Int){


        let collectionView = self.collectionView
        let indexPath = NSIndexPath.init(forItem: 0, inSection: index)
        let previsouseSectionRect = self.rectForSectionAtIndex(indexPath.section - 1)

        var sectionRect : CGRect = CGRectZero

        sectionRect.origin.x = 0
        sectionRect.origin.y = previsouseSectionRect.height + previsouseSectionRect.minY
        sectionRect.size.width = collectionView!.bounds.size.width

        var headerHeight : CGFloat = 0.0


        if self.delegate?.collectionView!(collectionView!, layout: self, referenceSizeForHeaderInSection: index)  != nil {

            var headerFrame: CGRect = CGRectZero
            headerFrame.origin.x = 0.0
            headerFrame.origin.y = sectionRect.origin.y

            let headerSize = self.delegate?.collectionView!(collectionView!, layout: self, referenceSizeForHeaderInSection: index)

            headerFrame.size.width = headerSize!.width
            headerFrame.size.height = headerSize!.height

            let headerAttributes = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withIndexPath: indexPath)
            headerAttributes.frame = headerFrame
            headerHeight = headerFrame.size.height
            self.headerItemAttributes.addObject(headerAttributes)

        }



        var sectionInsets = UIEdgeInsetsZero
        if self.delegate?.collectionView!(collectionView!, layout: self, insetForSectionAtIndex: index) != nil {

            sectionInsets = self.delegate!.collectionView!(collectionView!, layout: self, insetForSectionAtIndex: index)

        }

        self.sectionInsetses.addObject(NSValue.init(UIEdgeInsets: sectionInsets))

        var interitemSpacing : CGFloat = self.minimumInteritemSpacing
        var lineSpacing : CGFloat = self.minimumLineSpacing

        if self.delegate?.collectionView!(collectionView!, layout: self, minimumLineSpacingForSectionAtIndex: index) != nil {

            interitemSpacing = self.delegate!.collectionView!(collectionView!, layout: self, minimumLineSpacingForSectionAtIndex: index)

        }

        if self.delegate?.collectionView!(collectionView!, layout: self, minimumLineSpacingForSectionAtIndex: index) != nil {

            lineSpacing = self.delegate!.collectionView!(collectionView!, layout: self, minimumLineSpacingForSectionAtIndex: index)

        }


        var itemsContentRect: CGRect = CGRectZero
        itemsContentRect.origin.x = sectionInsets.left
        itemsContentRect.origin.y = headerHeight + sectionInsets.top


        

        let numberOfColumns : Int = self.delegate!.collectionView(collectionView!, layout: self, numberOfColumnInSection: index)
        itemsContentRect.size.width = collectionView!.frame.size.width - (sectionInsets.left + sectionInsets.right)

        let columnSpace : CGFloat = itemsContentRect.size.width - (interitemSpacing * CGFloat.init(floatLiteral: Double(numberOfColumns) - 1))

        let columnWidth : CGFloat = columnSpace / CGFloat.init(integerLiteral: (numberOfColumns == 0 ? 1 : numberOfColumns))


        let columns = NSMutableArray.init(capacity: numberOfColumns)
        for _ in 0 ..< numberOfColumns {
            columns.addObject(NSMutableArray.init(capacity: 0))

        }

        columnRectsInSection.addObject(columns)

        for itemIndex in 0 ..< items {


            let itemIndexPath = NSIndexPath.init(forItem: itemIndex, inSection: index)
            let destinationColumnIndex = self.preferredColumnIndexInSection(index)
            let destinationRowInColumn = self.numberOfitemsForColumn(destinationColumnIndex, inSection: index)

            var lastItemInColumnOffsetY = self.lastItemOffsetYForColumn(destinationColumnIndex, inSection: index)


            if destinationRowInColumn == 0 {
                lastItemInColumnOffsetY += sectionRect.origin.y
            }


            var itemRect : CGRect = CGRectZero
            itemRect.origin.x = itemsContentRect.origin.x + CGFloat.init(integerLiteral: destinationColumnIndex) * (interitemSpacing + columnWidth)
            itemRect.origin.y = lastItemInColumnOffsetY + (destinationRowInColumn > 0 ? lineSpacing : sectionInsets.top)
            itemRect.size.width = columnWidth
            itemRect.size.height = columnWidth

            if self.delegate?.collectionView!(collectionView!, layout: self, sizeForItemAtIndexPath: itemIndexPath) != nil {

                let itemSize = self.delegate?.collectionView!(collectionView!, layout: self, sizeForItemAtIndexPath: itemIndexPath)
                itemRect.size.height = itemSize!.height

            }



            let itemAttributes = UICollectionViewLayoutAttributes.init(forCellWithIndexPath: itemIndexPath)
            itemAttributes.frame = itemRect
            self.layoutItemAttributes[index].addObject(itemAttributes)
            self.columnRectsInSection[index].objectAtIndex(destinationColumnIndex).addObject(NSValue.init(CGRect: itemRect))
        }



        itemsContentRect.size.height = self.heightOfItemsInSection(indexPath.section) + sectionInsets.bottom


        var footerHeight : CGFloat = 0
        if self.delegate?.collectionView!(collectionView!, layout: self, referenceSizeForFooterInSection: index) != nil {

            var footerFrame : CGRect = CGRectZero
            footerFrame.origin.x = 0.0
            footerFrame.origin.y = sectionRect.origin.y

            let footerSize = self.delegate?.collectionView!(collectionView!, layout: self, referenceSizeForFooterInSection: index)

            footerFrame.size.width = footerSize!.width
            footerFrame.size.height = footerSize!.height


            let footerAttributes = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withIndexPath: indexPath)
            footerAttributes.frame = footerFrame
            footerHeight = footerFrame.size.height
            self.footerItemAttributes.addObject(footerAttributes)

        }

        if index > 0 {
            itemsContentRect.size.height -= sectionRect.origin.y
        }
        sectionRect.size.height = itemsContentRect.size.height + footerHeight

        self.sectionRects.addObject(NSValue.init(CGRect: sectionRect))

    }


    private func heightOfItemsInSection(index: Int) -> CGFloat {

        var maxHeightBetweenColumn : CGFloat = 0.0
        let columnsInSection : NSArray = self.columnRectsInSection[index] as! NSArray
        for columnIndex in 0 ..< columnsInSection.count {

            let heightOfColumn = self.lastItemOffsetYForColumn(columnIndex, inSection: index)
            maxHeightBetweenColumn = max(maxHeightBetweenColumn, heightOfColumn)

        }
        return maxHeightBetweenColumn
    }

    private func rectForSectionAtIndex(index:Int) -> CGRect{
        if index < 0 || index >= self.sectionRects.count {
            return CGRectZero
        }
        let sectionRectValue = self.sectionRects.objectAtIndex(index) as! NSValue
        let sectionRect = sectionRectValue.CGRectValue()
        return sectionRect
    }

    private func preferredColumnIndexInSection(index: Int) -> Int {

        var shortestColumnIndex = 0
        var heightOfShortestColumn = CGFloat.max
        let columnRects = self.columnRectsInSection.objectAtIndex(index) as! NSArray
        for columnIndex in 0 ..< columnRects.count {

            let columnHeight = self.lastItemOffsetYForColumn(columnIndex, inSection: index)
            if columnHeight < heightOfShortestColumn {
                heightOfShortestColumn = columnHeight
                shortestColumnIndex = columnIndex
            }
        }
        return shortestColumnIndex
    }


    private func lastItemOffsetYForColumn(columnIndex: Int,inSection sectionIndex: Int) -> CGFloat {

        let columnsInSection = self.columnRectsInSection.objectAtIndex(sectionIndex) as! NSArray
        let itemsInColumn = columnsInSection.objectAtIndex(columnIndex)
        if itemsInColumn.count == 0 {
            if self.headerItemAttributes.count > sectionIndex {

                let headerAttributes = headerItemAttributes[sectionIndex] as! UICollectionViewLayoutAttributes
                let headerFrame = headerAttributes.frame
                return headerFrame.size.height

            }
            return 0
        }else{
            let lastItemRectValue = itemsInColumn.lastObject as! NSValue
            let lastItemRect = lastItemRectValue.CGRectValue()
            return lastItemRect.maxY
        }


    }



    private func numberOfitemsForColumn(columnIndex: Int,inSection sectionIndex: Int) -> Int {

        let sectionColumns = self.columnRectsInSection[sectionIndex] as! NSArray
        return sectionColumns[columnIndex].count

    }




    //
    private func searchVisibleLayoutAttributesInRect(rect:CGRect) -> [UICollectionViewLayoutAttributes]? {


        let itemAttrs = NSMutableArray()
        let visibleSection = self.sectionIndexesInRect(rect)

        visibleSection.enumerateIndexesUsingBlock { (sectionIndex: Int, pointer: UnsafeMutablePointer<ObjCBool>) in


            let sectionLayoutItemAttributes = self.layoutItemAttributes[sectionIndex]
            for i in 0 ..< sectionLayoutItemAttributes.count {

                let layoutItemAttributes = sectionLayoutItemAttributes[i] as! UICollectionViewLayoutAttributes
                layoutItemAttributes.zIndex = 1
                let itemRect = layoutItemAttributes.frame
                let isVisible = CGRectIntersectsRect(rect, itemRect)
                if isVisible {
                    itemAttrs.addObject(layoutItemAttributes)
                }

            }


            if self.footerItemAttributes.count > sectionIndex {

                let footerLayoutAttributes = self.footerItemAttributes[sectionIndex] as! UICollectionViewLayoutAttributes
                let isVisible = CGRectIntersectsRect(rect, footerLayoutAttributes.frame)
                if isVisible {
                    itemAttrs.addObject(footerLayoutAttributes)
                }
                self.currentEdgeInsets = UIEdgeInsetsZero

            } else {

                let insetsValue = self.sectionInsetses[sectionIndex] as! NSValue
                self.currentEdgeInsets = insetsValue.UIEdgeInsetsValue()

            }


            if self.headerItemAttributes.count > sectionIndex {

                let headerLayoutAttributes = self.headerItemAttributes[sectionIndex] as! UICollectionViewLayoutAttributes
                if self.enableStickyHeaders {

                    let lastItemAttributes = itemAttrs.lastObject as! UICollectionViewLayoutAttributes
                    itemAttrs.addObject(headerLayoutAttributes)

                    self.updateTheHeaderLayoutAttributes(headerLayoutAttributes, lastItemAttributes: lastItemAttributes)

                }else{

                    let isVisible = CGRectIntersectsRect(rect, headerLayoutAttributes.frame)
                    if isVisible {
                        itemAttrs.addObject(headerLayoutAttributes)
                    }

                }
            }
        }
        return NSArray(array: itemAttrs) as? [UICollectionViewLayoutAttributes]
    }



    private func sectionIndexesInRect(rect: CGRect) -> NSIndexSet {
        let visibleIndexes = NSMutableIndexSet()
        let numberOfSections : Int = collectionView!.numberOfSections()
        for index in 0 ..< numberOfSections {

            let sectionRectValue = self.sectionRects[index] as! NSValue
            let sectionRect = sectionRectValue.CGRectValue()
            let isVisible = CGRectIntersectsRect(rect, sectionRect)
            if isVisible {
                visibleIndexes.addIndex(index)
            }

        }
        return visibleIndexes as NSIndexSet
    }


    private func updateTheHeaderLayoutAttributes(headerAttributes: UICollectionViewLayoutAttributes,lastItemAttributes:UICollectionViewLayoutAttributes) -> Void {

        let currentBounds = self.collectionView?.bounds
        headerAttributes.zIndex = 1024
        headerAttributes.hidden = false

        var origin = headerAttributes.frame.origin
        let sectionMaxY = lastItemAttributes.frame.maxY - lastItemAttributes.frame.size.height + self.currentEdgeInsets.bottom

        let y = (currentBounds?.maxY)! - (currentBounds?.size.height)! + (collectionView?.contentInset.top)!
        let maxY = min(max(y, headerAttributes.frame.origin.y), sectionMaxY)
        origin.y = maxY

        headerAttributes.frame = CGRectMake(origin.x, origin.y, headerAttributes.frame.size.width, headerAttributes.frame.size.height)

    }



}
