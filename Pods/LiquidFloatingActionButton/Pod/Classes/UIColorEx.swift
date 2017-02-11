//
//  UIColorEx.swift
//  LiquidLoading
//
//  Created by Takuma Yoshida on 2015/08/21.
//  Copyright (c) 2015年 yoavlt. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    /*var red: CGFloat {
        get {
            let components = self.cgColor.components
            return components![0]
        }
    }
    
    var green: CGFloat {
        get {
            let components = self.cgColor.components
            return components![1]
        }
    }
    
    var blue: CGFloat {
        get {
            let components = self.cgColor.components
            return components![2]
        }
    }*/
    
    var alpha: CGFloat {
        get {
            return self.cgColor.alpha
        }
    }

    //UIColor.red.cgColor.components![0]
    //UIColor.green.cgColor.components![1]
    //UIColor.blue.cgColor.components![2]
    
    func alpha(_ alpha: CGFloat) -> UIColor {
        return UIColor(red: UIColor.red.cgColor.components![0], green: UIColor.green.cgColor.components![1], blue: UIColor.blue.cgColor.components![2], alpha: alpha)
    }
    
    func white(_ scale: CGFloat) -> UIColor {
        return UIColor(
            red: UIColor.red.cgColor.components![0] + (1.0 - UIColor.red.cgColor.components![0]) * scale,
            green: UIColor.green.cgColor.components![1] + (1.0 - UIColor.green.cgColor.components![1]) * scale,
            blue: UIColor.blue.cgColor.components![2] + (1.0 - UIColor.blue.cgColor.components![2]) * scale,
            alpha: 1.0
        )
    }
}
