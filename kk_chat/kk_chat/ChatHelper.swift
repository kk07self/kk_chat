//
//  TBHelper.swift
//  01_test
//
//  Created by 陈康 on 2017/5/15.
//  Copyright © 2017年 陈康. All rights reserved.
//

import UIKit

// MARK: 屏幕尺寸
var kScreenWidth: CGFloat! {
    get{
        return UIScreen.main.bounds.size.width
    }
}

var kScreenHeight: CGFloat! {
    get{
        return UIScreen.main.bounds.size.height
    }
}


enum SelectedRightItemIndex {
    case none
    case emoji
    case items
}


// 按钮模型
public struct ItemModel {
    var title: String
    var icon: UIImage
    
    public init(_ title: String, icon: UIImage) {
        self.title = title
        self.icon = icon
    }
}
