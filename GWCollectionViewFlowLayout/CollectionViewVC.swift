//
//  CollectionViewVC.swift
//  GWCollectionViewFlowLayout
//
//  Created by langyue on 16/8/10.
//  Copyright © 2016年 langyue. All rights reserved.
//

import UIKit


class CusHeaderView: UICollectionReusableView {


    var btn : UIButton! = nil

    override init(frame: CGRect) {
        super.init(frame: frame)

        let btn = UIButton(type: .Custom)
        self.addSubview(btn)
        btn.frame = CGRectMake(100, 20, 80, 40)
        btn.setTitle("我是按钮", forState: .Normal)
        self.btn = btn

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}




class BannerHeaderView: UICollectionReusableView {

    var banner : CycleScrollView! = nil

    override init(frame: CGRect) {
        super.init(frame: frame)



        let banner = CycleScrollView(frame: CGRectZero,mode: Mode_Image.LocalImage)
        self.banner = banner
        banner.backgroundColor = UIColor.brownColor()
        banner.frame = CGRectMake(0, 64, kScreen_Width, 180)
        banner.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(banner)


        self.backgroundColor = UIColor.blackColor()


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}





class CusCollectionCell: UICollectionViewCell {


    var label : UILabel! = nil


    override init(frame: CGRect) {
        super.init(frame: frame)

        label = UILabel()
        label.frame = CGRectMake(0, 20, contentView.frame.size.width, 20)
        contentView.addSubview(label)


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}











private let reuseIdentifier = "Cell"

class CollectionViewVC: UICollectionViewController,GWCollectionViewDelegateFlowLayout,LocalImageDelegate {


    var sizes = NSMutableArray()
    var banner : CycleScrollView! = nil
    var imgArray = [UIImage]()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes



        let banner = CycleScrollView(frame: CGRectZero,mode: Mode_Image.LocalImage)
        banner.controller = self
        self.banner = banner
        banner.backgroundColor = UIColor.brownColor()
        //banner.frame = CGRectMake(0,0, kScreen_Width, 180)
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.delegateLocal = self

        self.edgesForExtendedLayout = .None
        self.banner.beginScrollContents()

        //self.edgesForExtendedLayout = UIRectEdge.None







        self.collectionView!.registerClass(CusCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.registerClass(CusHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView?.registerClass(BannerHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderBanner")
        collectionView?.registerClass(CusHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "Footer")



//        sizes.addObject(NSValue.init(CGSize: CGSizeMake(100, 120)))
//        sizes.addObject(NSValue.init(CGSize: CGSizeMake(100, 90)))
//        sizes.addObject(NSValue.init(CGSize: CGSizeMake(100, 80)))
//        sizes.addObject(NSValue.init(CGSize: CGSizeMake(100, 110)))


        let width = (UIScreen.mainScreen().bounds.size.width - 12 )/2

        sizes.addObject(NSValue.init(CGSize: CGSizeMake(100, width)))
        sizes.addObject(NSValue.init(CGSize: CGSizeMake(100, width)))
        sizes.addObject(NSValue.init(CGSize: CGSizeMake(100, width)))
        sizes.addObject(NSValue.init(CGSize: CGSizeMake(100, width)))


        // Do any additional setup after loading the view.
    }

    func cycleScrollViewLocalImage()->[UIImage]{
        return [UIImage(named:"1.jpeg")!,UIImage(named:"2.jpeg")!,UIImage(named:"3.jpeg")!]
    }

    func ClickItemAtIndex(idx:Int){

        print("点击了 \(idx)")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 90
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : CusCollectionCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CusCollectionCell


        cell.backgroundColor = UIColor.init(red: CGFloat.init(random()%255) / CGFloat.init(255), green: CGFloat.init(random()%255) / CGFloat.init(255), blue: CGFloat.init(random()%255) / CGFloat.init(255), alpha: 1.0)


        cell.label.text = "===== \(indexPath.item) ====="



    
        // Configure the cell
    
        return cell
    }


    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: GWCollectionViewFlowLayout, numberOfColumnInSection section: Int) -> NSInteger {
        return 2
    }


    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        if kind == UICollectionElementKindSectionHeader {

            if indexPath.section == 0 {

                //BannerHeaderView

                let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderBanner", forIndexPath: indexPath)
                header.backgroundColor = UIColor.init(red: CGFloat(arc4random()%255), green: 0, blue: 0, alpha: 0.75)

                if banner.superview == nil {
                    header.addSubview(banner)
                    banner.snp.makeConstraints { (make) in

                        make.left.right.equalTo(header)
                        make.top.equalTo(0)
                        make.height.equalTo(180)
                        
                    }

                }


                return header

            }else{
                let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath)
                header.backgroundColor = UIColor.init(red: CGFloat(arc4random()%255), green: 0, blue: 0, alpha: 0.75)
                return header
            }

        }


        if kind == UICollectionElementKindSectionFooter {


            let footer = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "Footer", forIndexPath: indexPath)

            return footer

        }

        return UICollectionReusableView()

    }





    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let size = self.sizes[indexPath.row % 4] as! NSValue
        return size.CGSizeValue()

    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(2, 2, 2, 2)
    }


    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }


    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        if section == 0 {
            return CGSizeMake(view.bounds.width, 180)
        }else{
            return CGSizeMake(view.bounds.width, 120)
        }

    }


    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSizeMake(0.1, 0.01)
    }



    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        print("选择了第 \(indexPath.section)  Section \(indexPath.item) Item")


    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
