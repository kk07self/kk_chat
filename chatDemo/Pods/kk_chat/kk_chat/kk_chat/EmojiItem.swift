//
//  EmojiItem.swift
//  01_test
//
//  Created by 陈康 on 2017/6/8.
//  Copyright © 2017年 陈康. All rights reserved.
//

import UIKit

class EmojiItem: UICollectionViewCell {

    @IBOutlet weak var button: UIButton!

    var titleString: String! {
        didSet {
            if titleString == "删除" {
                button.setTitle("", for: .normal)
                let bundle =  Bundle(for: ItemsView.classForCoder())
                button.setImage(UIImage(named:"resources.bundle/DeleteEmoticonBtn",in:bundle, compatibleWith:nil), for: .normal)
            } else {
                button.setTitle(titleString, for: .normal)
                button.setImage(nil, for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button.imageView?.contentMode = .scaleAspectFit
    }
}
