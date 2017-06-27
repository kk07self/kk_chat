//
//  EmojiView.swift
//  01_test
//
//  Created by 陈康 on 2017/6/8.
//  Copyright © 2017年 陈康. All rights reserved.
//

import UIKit


/// 代理
public protocol EmojiViewDelegate {
    
    // 添加一个
    func emojiView(insetText text: String)
    
    // 删除一个
    func emojiViewDeleteEmoj()
    
    // 删除一个
    func emojiViewSendEmoj()
    
}

class EmojiView: UIView {

    private var view: UIView!
    
    var delegate: EmojiViewDelegate?
    
    fileprivate var emojiDict: [String:[String]] = {
        let plistPath = Bundle(path: Bundle(for: EmojiView.classForCoder()).bundlePath + "/resources.bundle")?.path(forResource: "emoji", ofType: "plist")
        return NSDictionary(contentsOfFile: plistPath!) as! [String: [String]]
    }()
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    private func xibSetup() {
        view = UINib(nibName: "EmojiView", bundle: Bundle(path: Bundle(for: EmojiView.classForCoder()).bundlePath + "/resources.bundle")).instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
        
        collectionView.register(UINib(nibName: "EmojiItem", bundle: Bundle(path: Bundle(for: EmojiView.classForCoder()).bundlePath + "/resources.bundle")), forCellWithReuseIdentifier: "EmojiItem")
        
        collectionView.collectionViewLayout = ChatCollectionViewFlowLayout.chatCollectionViewFlowLayout(sections: 8, rows: 3, pageSize: CGSize(width:kScreenWidth, height:155), pageSpacing: 15, columnSpacing: 0, rowSpacing: 0, edgeInsets: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0))
        
        let numbers = (emojiDict["People"]?.count)!/24 + ((emojiDict["People"]?.count)!%24 == 0 ? 0 : 1)
        for index in 0...numbers {
            if index < numbers {
                emojiDict["People"]?.insert("删除", at: index*24 + 23)
            } else {
                if index == numbers {
                    emojiDict["People"]?.append("删除")
                    collectionView.reloadData()
                }
            }
        }
        pageControl.numberOfPages = (emojiDict["People"]?.count)!/24 + ((emojiDict["People"]?.count)!%24 == 0 ? 0 : 1)
        collectionView.reloadData()
    }
    
    @IBAction func leftItem(_ sender: UIButton) {
    }
    
    @IBAction func sendItem(_ sender: UIButton) {
        delegate?.emojiViewSendEmoj()
    }
}


// MARK
extension EmojiView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiDict["People"]!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiItem", for: indexPath) as! EmojiItem
        item.titleString = emojiDict["People"]?[indexPath.row+indexPath.section*24]
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let text = emojiDict["People"]?[indexPath.row]
        if text == "删除" {
            delegate?.emojiViewDeleteEmoj()
        } else {
            delegate?.emojiView(insetText: text ?? "")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(collectionView.contentOffset.x)/Int(kScreenWidth)
    }
    
}
