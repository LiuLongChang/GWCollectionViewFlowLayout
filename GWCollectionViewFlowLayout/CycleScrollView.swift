//
//  CycleScrollView.swift
//  NanchangWater
//
//  Created by langyue on 16/5/20.
//  Copyright © 2016年 langyue. All rights reserved.
//

import Foundation
import UIKit



import SnapKit

import Kingfisher





enum Mode_Image {
    case LocalImage,NetImage
}


typealias ClickItem = (imgView:UIImageView)->Void

protocol LocalImageDelegate {
    func cycleScrollViewLocalImage()->[UIImage]
    func ClickItemAtIndex(idx:Int)
}

protocol NetImgDelegate{
    func cycleScrollViewNotImgUrls()->[String]
    func netClickItemAtIndex(idx:Int)
}

let notKonw : CGFloat = 64


class CycleScrollView: UIView,UIScrollViewDelegate {
    
    var clickItem : ClickItem?
    var scrollView : UIScrollView! = nil
    var mode:Mode_Image! = nil
    
    
    var delegateLocal : LocalImageDelegate?
    var delegateNet : NetImgDelegate?
    
    //本地内容数组
    var localImgArray : [UIImage] = []
    //网络图片数组
    var netImgArray : [String] = []
    //当前模式下使用哪个数组
    var currentModeArray  = []
    
    
    var width:CGFloat!
    
    
    var leftImgView : UIImageView!
    var middleImgView : UIImageView!
    var rightImgView : UIImageView!
    
    
    var middleIndex : Int = 0
    
    
    //var pageControl : UIPageControl!
    var cusPage : CusPageControl! = nil
    
    
    var timer : NSTimer!
    
//    http://blog.sina.com.cn/s/blog_83b365f60102vxky.html
//    处理scrollview和tableview偏移64个像素的处理方法 (2015-09-09 16:41:36)转载▼
//    标签： ios tableview 64 scrollview
//    第一种方法：
//    // 设置CGRectZero从导航栏下开始计算
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    第二种方法：
//    //    self.navigationController.navigationBar.translucent = YES;或者NO；
//    第三种方法：
//    //    self.automaticallyAdjustsScrollViewInsets = NO;
//    三种方法效果差不多，但是也有部分差异，笔者推荐第一种
    
    
    var controller : UIViewController! = nil



    init(frame:CGRect,mode:Mode_Image) {
        super.init(frame:frame)
        //mode: mode

        self.mode = mode
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.top.equalTo(self)
        }
        scrollView.bounces = false
        scrollView.delegate = self
        
        
        leftImgView = makeImageView(ToView: scrollView)
        middleImgView = makeImageView(nil, ToView: scrollView)
        middleImgView.userInteractionEnabled = true
        middleImgView.addSingleTapGestureRecognizerWithResponder { (tap) in
            
            if self.mode == Mode_Image.LocalImage {
                self.delegateLocal?.ClickItemAtIndex(self.middleIndex)
            }
            if self.mode == Mode_Image.NetImage{
                self.delegateNet?.netClickItemAtIndex(self.middleIndex)
            }
            
        }
        rightImgView = makeImageView(ToView: scrollView)
        




        leftImgView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.width.equalTo(scrollView.snp.width)
            make.top.equalTo(0)
            make.height.equalTo(scrollView.snp.height)
        }
        
        middleImgView.snp.makeConstraints { (make) in
            make.left.equalTo(leftImgView.snp.right)
            make.width.equalTo(leftImgView.snp.width)
            make.top.equalTo(0)
            make.height.equalTo(scrollView.snp.height)
        }
        
        rightImgView.snp.makeConstraints { (make) in
            make.left.equalTo(middleImgView.snp.right)
            make.width.equalTo(middleImgView.snp.width)
            make.top.equalTo(0)
            make.height.equalTo(scrollView.snp.height)
        }
        
        self.width = kScreen_Width
        scrollView.pagingEnabled = true
//        scrollView.contentOffset = CGPointMake(self.width, 0)
        middleIndex = 0
        
        
        
//        self.pageControl = UIPageControl()
//        self.addSubview(pageControl)
//        pageControl.snp_makeConstraints { (make) in
//            make.centerX.equalTo(self.snp_centerX)
//            make.width.equalTo(150)
//            make.height.equalTo(30)
//            make.bottom.equalTo(self.snp_bottom).offset(-20)
//        }
//        pageControl.addTarget(self, action: #selector(CycleScrollView.changePage(_:)), forControlEvents: .ValueChanged)
     
        
        cusPage = CusPageControl(frame: CGRectZero,numbers: 0)
        self.addSubview(cusPage)
        //cusPage.backgroundColor = UIColor.cyanColor()
        cusPage.snp.makeConstraints { (make) in
           make.centerX.equalTo(self.snp.centerX)
           make.width.equalTo(150)
           make.height.equalTo(30)
           make.bottom.equalTo(self.snp.bottom).offset(-20)
        }
        cusPage.cusPageAction = { (btn: UIButton) in
            
            self.changePage(btn.tag)
            
        }
        
    }
    
    //自动轮播
    func loopAuto(){
        scrollView.setContentOffset(CGPointMake(self.width*2, 0), animated: true)
    }
    
    //点击PageControl事件
    func changePage(obj:AnyObject){
        //middleIndex = pageControl.currentPage
        middleIndex = cusPage.currentIndex
        self.locationImg()
    }
    
    func beginScrollContents(){



        
        
        //self.viewController()!.edgesForExtendedLayout = UIRectEdge.None
        
        if self.mode == Mode_Image.LocalImage {
            if self.delegateLocal != nil {
                self.localImgArray = self.delegateLocal!.cycleScrollViewLocalImage()
            }
        }
        
        if self.mode == Mode_Image.NetImage {
            
            if self.delegateNet != nil {
                self.netImgArray = self.delegateNet!.cycleScrollViewNotImgUrls()
            }
            
            if netImgArray.count >= 2 {
                
                if timer != nil {
                    timer.invalidate()
                }
                scrollView.contentOffset = CGPointMake(self.width, 0)
                scrollView.scrollEnabled = true
                timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(CycleScrollView.loopAuto), userInfo: nil, repeats: true)
                let runloop = NSRunLoop.currentRunLoop()
                runloop.addTimer(self.timer, forMode: NSRunLoopCommonModes)
                
            }
            
        }
        
        
        
        if self.mode == Mode_Image.LocalImage {
            currentModeArray = self.localImgArray
        }
        if self.mode == Mode_Image.NetImage {
            currentModeArray = self.netImgArray
        }
        if self.mode == Mode_Image.LocalImage {
            
            middleImgView.image = self.localImgArray[0]
            leftImgView.image = self.localImgArray.last
            rightImgView.image = self.localImgArray[1]
            
        }else if self.mode == Mode_Image.NetImage{
            
            if netImgArray.count >= 2 {
                
                let url0 =  NSURL(string: self.netImgArray[0])
                let url1 =  NSURL(string: self.netImgArray.last!)
                let url2 =  NSURL(string: self.netImgArray[1])
                middleImgView.kf_setImageWithURL(url0!, placeholderImage: nil, optionsInfo: nil, progressBlock: { (receivedSize, totalSize) in
                    
                    }, completionHandler: { (image, error, cacheType, imageURL) in
                        
                })
                leftImgView.kf_setImageWithURL(url1!, placeholderImage: nil, optionsInfo: nil, progressBlock: { (receivedSize, totalSize) in
                    
                    }, completionHandler: { (image, error, cacheType, imageURL) in
                        
                })
                rightImgView.kf_setImageWithURL(url2!, placeholderImage: nil, optionsInfo: nil, progressBlock: { (receivedSize, totalSize) in
                    
                    }, completionHandler: { (image, error, cacheType, imageURL) in
                        
                })
                
            }
            
            if netImgArray.count == 1 {
                let url0 =  NSURL(string: self.netImgArray[0])
                middleImgView.kf_setImageWithURL(url0!, placeholderImage: nil, optionsInfo: nil, progressBlock: { (receivedSize, totalSize) in
                    
                    }, completionHandler: { (image, error, cacheType, imageURL) in
                        
                })
                cusPage.hidden = true
                scrollView.contentOffset = CGPointMake(self.width, 0)
                scrollView.scrollEnabled = false
            }
            
        }
        
        
        if self.mode == Mode_Image.LocalImage {
            //self.scrollView.contentSize = CGSizeMake(self.width*CGFloat(self.localImgArray.count), 0)
            self.scrollView.contentSize = CGSizeMake(self.width*CGFloat(3), 0)
            //self.scrollView.scrollEnabled = true
            //pageControl.numberOfPages = self.localImgArray.count
            cusPage.numberOfPages = self.localImgArray.count
            
        }else if self.mode == Mode_Image.NetImage {
            //self.scrollView.contentSize = CGSizeMake(self.width*CGFloat(self.netImgArray.count), 0)
            self.scrollView.contentSize = CGSizeMake(self.width*CGFloat(3), 0)
            //self.scrollView.scrollEnabled = true
            //pageControl.numberOfPages = self.netImgArray.count
            cusPage.numberOfPages = self.netImgArray.count
        }
        
    }
    
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        //print("\(self.scrollView.contentOffset)===\(self.width)")
        
        //正向滑动
        if scrollView.contentOffset == CGPointMake(2*self.width, 0) {
            //处理Index
            
            self.middleIndex += 1
            
            if self.middleIndex == currentModeArray.count {
                self.middleIndex = 0
            }
            //摆放图片
            self.locationImg()
        }
        
        //反向滑动
        if scrollView.contentOffset == CGPointMake(0, 0) {
            self.middleIndex -= 1
            if self.middleIndex == -1  {
                self.middleIndex = currentModeArray.count - 1
            }
            self.locationImg()
        }
        
    }
    
    
    //MARK 减速
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        
        
    }
    
    
    //根据当前显示Index放置图片
    func locationImg(){
        //print("选中:  \(self.middleIndex)")
        
        if netImgArray.count == 0 {
            return;
        }
        if netImgArray.count == 1 {
            return;
        }
        
        if self.middleIndex == currentModeArray.count - 1 {
            
            if self.mode == Mode_Image.LocalImage {
                middleImgView.image = localImgArray.last
                leftImgView.image = localImgArray[self.localImgArray.count-1-1]
                rightImgView.image = localImgArray[0]
            }else if self.mode == Mode_Image.NetImage {
                
                let url0 =  NSURL(string: netImgArray.last!)
                let url1 =  NSURL(string: netImgArray[self.netImgArray.count-1-1])
                let url2 =  NSURL(string: netImgArray[0])
                middleImgView.kf_setImageWithURL(url0!, placeholderImage: nil, optionsInfo: nil, progressBlock: { (receivedSize, totalSize) in
                    
                    }, completionHandler: { (image, error, cacheType, imageURL) in
                        
                })
                leftImgView.kf_setImageWithURL(url1!, placeholderImage: nil, optionsInfo: nil, progressBlock: { (receivedSize, totalSize) in
                    
                    }, completionHandler: { (image, error, cacheType, imageURL) in
                        
                })
                rightImgView.kf_setImageWithURL(url2!, placeholderImage: nil, optionsInfo: nil, progressBlock: { (receivedSize, totalSize) in
                    
                    }, completionHandler: { (image, error, cacheType, imageURL) in
                        
                })
                
            }
            
            
        }else if (self.middleIndex == 0){
            
            if self.mode == Mode_Image.LocalImage {
                self.middleImgView.image = self.localImgArray[0]
                self.leftImgView.image = self.localImgArray.last
                self.rightImgView.image = self.localImgArray[1]
            }else if self.mode == Mode_Image.NetImage{
                
                let url0 =  NSURL(string: self.netImgArray[0])
                let url1 =  NSURL(string: self.netImgArray.last!)
                let url2 =  NSURL(string: self.netImgArray[1])
                middleImgView.kf_setImageWithURL(url0!, placeholderImage: nil, optionsInfo: nil, progressBlock: { (receivedSize, totalSize) in
                    
                    }, completionHandler: { (image, error, cacheType, imageURL) in
                        
                })
                leftImgView.kf_setImageWithURL(url1!, placeholderImage: nil, optionsInfo: nil, progressBlock: { (receivedSize, totalSize) in
                    
                    }, completionHandler: { (image, error, cacheType, imageURL) in
                        
                })
                rightImgView.kf_setImageWithURL(url2!, placeholderImage: nil, optionsInfo: nil, progressBlock: { (receivedSize, totalSize) in
                    
                    }, completionHandler: { (image, error, cacheType, imageURL) in
                        
                })
                
            }
            
        }else{
            
            if self.mode == Mode_Image.LocalImage {
                
                self.middleImgView.image = self.localImgArray[self.middleIndex]
                self.leftImgView.image = self.localImgArray[self.middleIndex-1]
                self.rightImgView.image = self.localImgArray[self.middleIndex+1]
                
            }else if(self.mode == Mode_Image.NetImage){
                
                
                //print("AAAA: \(self.netImgArray.count)   ===  \(self.middleIndex)")
                let url0 =  NSURL(string: self.netImgArray[self.middleIndex])
                let url1 =  NSURL(string: self.netImgArray[self.middleIndex-1])
                let url2 =  NSURL(string: self.netImgArray[self.middleIndex+1])
                
                
                middleImgView.kf_setImageWithURL(url0!, placeholderImage: nil, optionsInfo: nil, progressBlock: { (receivedSize, totalSize) in
                    
                    }, completionHandler: { (image, error, cacheType, imageURL) in
                        
                })
                leftImgView.kf_setImageWithURL(url1!, placeholderImage: nil, optionsInfo: nil, progressBlock: { (receivedSize, totalSize) in
                    
                    }, completionHandler: { (image, error, cacheType, imageURL) in
                        
                })
                rightImgView.kf_setImageWithURL(url2!, placeholderImage: nil, optionsInfo: nil, progressBlock: { (receivedSize, totalSize) in
                    
                    }, completionHandler: { (image, error, cacheType, imageURL) in
                        
                })
                
            }
            
        }
        
        scrollView.contentOffset = CGPointMake(self.width,0)
        //self.pageControl.currentPage = self.middleIndex
        
        cusPage.currentIndex = self.middleIndex

    }
    
    
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        if timer != nil {
            timer.invalidate()
        }
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(CycleScrollView.loopAuto), userInfo: nil, repeats: true)
        let runloop = NSRunLoop.currentRunLoop()
        runloop.addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}






typealias CusPageAction = (UIButton) -> Void


class CusPageControl: UIView {
    
    var cusPageAction : CusPageAction?
    
    
    var btnArr : NSMutableArray! = []
    
    
    private var _currentIndex : Int?
    var currentIndex : Int {
        
        
        set{
            
            let btn : UIButton = btnArr[newValue] as! UIButton
            for obj in btnArr {
                let btnT : UIButton = obj as! UIButton
                btnT.selected = false
            }
            btn.selected = true
            _currentIndex = newValue
            
        }
        
        get{
            return _currentIndex!
        }
        
        
    }
    
    
    
    private var _numberOfPages : Int?
    var numberOfPages : Int {
        set{
            self.makeIt(newValue)
            _numberOfPages = newValue
        }
        get{
            return _numberOfPages!
        }
        
    }
    
    
    func makeIt(num:Int){
        
        
        self.btnArr = NSMutableArray()




//        for view in self.subviews {
//
//            if view is UIButton {
//                 view.removeFromSuperview()
//            }
//
//        }




        
        var preBtn : UIButton! = nil
        for idx in 0..<num {
            
            let btn = makeButton(Target: self, Selector: #selector(CusPageControl.pageClickAction(_:)), ToView: self)
            btn.setImage(UIImage(named: "bannerIcon"), forState: .Normal)
            btn.setImage(UIImage(named: "bannerIconSelect"), forState: .Selected)
            btn.backgroundColor = UIColor.clearColor()
            btn.snp.makeConstraints(closure: { (make) in
                
                if idx == 0 {
                    make.left.equalTo(5)
                    make.width.height.equalTo(15)
                    make.centerY.equalTo(self)
                    preBtn = btn
                    btn.selected = true
                }else if idx == num-1 {
                    make.right.equalTo(self.snp.right).offset(-5)
                    make.width.height.equalTo(15)
                    make.centerY.equalTo(self)
                    
                    self.snp.updateConstraints(closure: { (make) in
                        
                        make.width.equalTo(15*num+5*(num+1))
                        
                    })
                    
                    
                }else{
                    make.left.equalTo(preBtn.snp.right).offset(5)
                    make.width.height.equalTo(15)
                    make.centerY.equalTo(self)
                    preBtn = btn
                }
                
                
            })
            
            
            self.addSubview(btn)
            
            self.btnArr.addObject(btn)
            
        }

        
        
    }
    
    
    init(frame: CGRect,numbers:Int) {
        super.init(frame: frame)
        //self.backgroundColor = UIColor.greenColor()
        if numbers == 0 {
            
        }else{
            self.makeIt(numbers)
        }
        
    }
    
    
    
    func pageClickAction(btn:UIButton){
        
        if self.cusPageAction != nil {
            self.cusPageAction!(btn)
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
}







