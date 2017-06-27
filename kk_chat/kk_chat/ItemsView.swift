//
//  ItemsView.swift
//  01_test
//
//  Created by 陈康 on 2017/6/8.
//  Copyright © 2017年 陈康. All rights reserved.
//

import UIKit


/// 代理
public protocol ItemsViewDelegate {
    // 点击按钮
    func itemView(didSelectItemAt index: Int)
}


class ItemsView: UIView {

    var view: UIView!
    var delegate: ItemsViewDelegate?
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    var items = [ItemModel]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    fileprivate func xibSetup() {
        view = UINib(nibName: "ItemsView", bundle: Bundle(for: type(of: self))).instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)

        collectionView.collectionViewLayout = ChatCollectionViewFlowLayout.chatCollectionViewFlowLayout(sections: 4, rows: 2, pageSize: CGSize(width:kScreenWidth, height:170), pageSpacing: 15, columnSpacing: 0, rowSpacing: 0, edgeInsets: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0))
        collectionView.register(UINib(nibName: "ItemsItem",bundle: nil), forCellWithReuseIdentifier: "ItemsItem")
        collectionView.reloadData()
        pageControl.numberOfPages = items.count / 8 + ((items.count % 8 == 0) ? 0 : 1)
    }
}

extension ItemsView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemsItem", for: indexPath) as! ItemsItem
        let itemModel = items[indexPath.row]
        item.icon.image = itemModel.icon
        item.text.text = itemModel.title
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.itemView(didSelectItemAt: indexPath.row)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(collectionView.contentOffset.x)/Int(kScreenWidth)
    }
}

