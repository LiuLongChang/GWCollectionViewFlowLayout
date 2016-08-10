//
//  StringProcess.swift
//  NanchangWater
//
//  Created by 刘隆昌 on 16/5/18.
//  Copyright © 2016年 langyue. All rights reserved.
//

import Foundation
import UIKit



func PathForResource_PngImg(name:String)->String{
    return NSBundle.mainBundle().pathForResource(name, ofType: "png")!
}




//

extension NSString{
    
    //字体一定的情况下 获取尺寸
    func getSize(Font font:UIFont,ConstrainedToSize size:CGSize)->CGSize{
        var resultSize = CGSizeZero
        if self.length <= 0 {
            return resultSize
        }
        resultSize = self.boundingRectWithSize(size, options: [.UsesFontLeading,.UsesLineFragmentOrigin], attributes: [NSFontAttributeName:font], context: nil).size
        
        resultSize = CGSizeMake(min(size.width, ceil(size.width)), min(size.height, ceil(resultSize.height)))
        return resultSize
    }
    
    //字体和宽度限制的情况下 获取高度
    func height(WithFont font:UIFont,withinWidth width:CGFloat)->CGFloat{
        let textRect = self.boundingRectWithSize(CGSizeMake(width, CGFloat(MAXFLOAT)), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil)
        return ceil(textRect.size.height)
    }
    
    
    func widthWithFont(font:UIFont)->CGFloat{
        let textRect = self.boundingRectWithSize(CGSizeMake(CGFloat(MAXFLOAT), font.pointSize), options: [.UsesLineFragmentOrigin,.UsesFontLeading], attributes: [NSFontAttributeName:font], context: nil)
        return textRect.size.width
    }
    
    
    
    
}

//String MD5


extension NSString{
    
    func md5() -> String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CUnsignedInt(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        CC_MD5(str, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.destroy()
        return String(format: hash as String)
    }
    
}

extension String{
    
    func md5() -> String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CUnsignedInt(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.destroy()
        return String(format: hash as String)
    }
    
    
}





class regix: NSObject {
    
    
    //邮箱正则表达式
    let emailRegix = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
    //
    
    
    
    //用户名验证（允许使用小写字母、数字、下滑线、横杠，一共3~16个字符）
    let userNameValid = "^[a-z0-9_-]{3,16}$"
    
    
    
    //手机号码验证
    let phoneRegix = "^1[0-9]{10}$"
    



    let urlValid = "(https?|ftp|file)://[-A-Z0-9+&@#/%?=~_|!:,.;]*[-A-Z0-9+&@#/%=~_|]"

    
    
    
    
    
    //let n = RegexHelper(phoneRegix)
    
    
    

}




//MARK 验证正则表达式
struct RegexHelper {
    
    let regex : NSRegularExpression
    init (_ pattern: String)  {
        
        try! regex = NSRegularExpression(pattern: pattern,options: .CaseInsensitive)
        
    }
    
    func match(input:String)->Bool{
        let matches = regex.matchesInString(input, options: [], range: NSMakeRange(0, input.utf16.count))
        return matches.count > 0
    }
}




//验证身份证号
extension String{
    
    
    
    
    /*没废话,直接上代码*/
    //iso加权数组
    static let iso7064Arr = [7,9, 10, 5, 8, 4,2, 1, 6, 3, 7,9, 10, 5 ,8, 4,2]
    //iso校验数组,其中大小写x均视为10
    static let iso7064ModArr = [1,0, 10, 9, 8, 7,6, 5, 4, 3, 2]
    
    //验证身份证号
    func validateChinaId() -> Bool {
        let regex:NSPredicate = NSPredicate(format:"SELF MATCHES %@", "(^\\d{15}$)|(^\\d{18}$)|(^\\d{17}(\\d|X|x)$)")
        if regex.evaluateWithObject(self) == false {
            return false;
        }
        
        
        
        if self.unicodeScalars.count == 15 {
            return true;
        }
        var intArr = [Int]()
        for item in self.unicodeScalars {
            var intItem = Int(item.value)
            //大小写x均视为10,方便计算
            if intItem == 88 || intItem == 120 {
                intItem = 58
            }
            intArr.append(intItem - 48)
        }
        var total = 0
        for i in 0...16 {
            total += intArr[i] * String.iso7064Arr[i]
        }
        let mode = total % 11;
        if String.iso7064ModArr[mode] == intArr[17] {
            return true
        }
        else {
            return false
        }
    }
    
    
    
    
    //验证身份证号存不存在
//    class func validateIDCardNumber(value: NSString)->Bool{
//    
//        
//        let valueUse : NSString! = value.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
//        var length : Int = 0
//        if valueUse == nil {
//            return false
//        }else{
//            
//            length = valueUse!.length
//            if length != 15 && length != 18 {
//                return false
//            }
//            
//        }
//        //省份代码
//        let areasArray = ["11","12","13","14","15","21","22","23","31","32","33","34","35","36","37","41","42","43","44","45","46","50","51","52","53","54","61","62","63","64","65","71","81","82","91"]
//        
//        let valueStart2 = valueUse!.substringToIndex(2)
//        var areaFlag = false
//        for areaCode in areasArray {
//            
//            
//            if areaCode == valueStart2 {
//                areaFlag = true
//                break
//            }
//            
//            
//        }
//        
//        
//        if areaFlag == false {
//            return false
//        }
//        
//        
//        var regularExpression : NSRegularExpression! = nil
//        var numberOfMatch : NSInteger
//        var year : Int = 0
//        switch length {
//        case 15:
//            
//            let str : NSString = valueUse!.substringWithRange(NSMakeRange(6, 2))
//            year = Int(str.intValue) + 1900
//            if ((year % 4 == 0) || (year % 100 == 0 && year % 4 == 0 )) {
//                
//                try! regularExpression = NSRegularExpression(pattern: "^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$",options: [.CaseInsensitive])
//                
//            }else{
//                
//                try! regularExpression = NSRegularExpression(pattern: "^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$",options: [.CaseInsensitive])
//                
//                
//            }
//            
//            numberOfMatch = regularExpression.numberOfMatchesInString(valueUse as String, options: [.ReportProgress], range: NSMakeRange(0,valueUse!.length))
//            
//            if numberOfMatch > 0 {
//                return true
//            }else{
//                return false
//            }
//           
//        case 18:
//            
//            
//            
//            year = Int((valueUse!.substringWithRange(NSMakeRange(6, 4)) as NSString).intValue)
//            if ((year % 4 == 0) || (year % 100 == 0 && year % 4 == 0)) {
//                
//                try! regularExpression = NSRegularExpression(pattern: "^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$",options: [.CaseInsensitive])
//                
//                
//            }else{
//                
//                try! regularExpression = NSRegularExpression(pattern: "^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$",options: [.CaseInsensitive])
//                
//            }
//            
//            
//            numberOfMatch = regularExpression.numberOfMatchesInString(valueUse as String, options:[.ReportProgress], range: NSMakeRange(0,valueUse!.length))
//            
//            
//            if numberOfMatch > 0 {
//                
//                
//                let n1 = (valueUse!.substringWithRange(NSMakeRange(0, 1)) as NSString).intValue
//                let n2 = (valueUse!.substringWithRange(NSMakeRange(10, 1)) as NSString).intValue * 7
//                let n3 = (valueUse!.substringWithRange(NSMakeRange(1, 1)) as NSString).intValue
//                let n4 = (valueUse!.substringWithRange(NSMakeRange(11, 1)) as NSString).intValue * 9
//                let n5 = (valueUse!.substringWithRange(NSMakeRange(2, 1)) as NSString).intValue
//                let n6 = (valueUse!.substringWithRange(NSMakeRange(12, 1)) as NSString).intValue * 10
//                let n7 = (valueUse!.substringWithRange(NSMakeRange(3, 1)) as NSString).intValue
//                let n8 = (valueUse!.substringWithRange(NSMakeRange(13, 1)) as NSString).intValue * 5
//                let n9 = (valueUse!.substringWithRange(NSMakeRange(4, 1)) as NSString).intValue
//                let n10 = (valueUse!.substringWithRange(NSMakeRange(14, 1)) as NSString).intValue * 8
//                let n11 = (valueUse!.substringWithRange(NSMakeRange(5, 1)) as NSString).intValue
//                let n12 = (valueUse!.substringWithRange(NSMakeRange(15, 1)) as NSString).intValue * 4
//                let n13 = (valueUse!.substringWithRange(NSMakeRange(6, 1)) as NSString).intValue
//                let n14 = (valueUse!.substringWithRange(NSMakeRange(16, 1)) as NSString).intValue * 2
//                let n15 = (valueUse!.substringWithRange(NSMakeRange(7, 1)) as NSString).intValue * 1
//                let n16 = (valueUse!.substringWithRange(NSMakeRange(8, 1)) as NSString).intValue * 6
//                let n17 = (valueUse!.substringWithRange(NSMakeRange(9, 1)) as NSString).intValue * 3
//                
//                
//                
//                let S = n1 + n2 + n3 + n4 + n5 + n6 + n7 + n8 + n9 + n10 + n11 + n12 + n13 + n14 + n15 + n16 + n17
//                  
//                
//                let Y : Int32 = S % 11
//                var M : NSString = ""
//                let JYM : NSString = "10X98765432"
//                M = JYM.substringWithRange(NSMakeRange(Int(Y)+1, 1))  //判断校验位
//                
//                
//                
//                if M.isEqualToString(valueUse!.substringWithRange(NSMakeRange(17, 1))) {
//                    return true
//                }else{
//                    return false
//                }
//                
//                
//            }else{
//                return false
//            }
//            
//            
//            
//        default: break
//            
//        }
//        
//        return false
//    
//    }
//    
    
    
    
    
    
}







