//
//  ViewController.swift
//  chatDemo
//
//  Created by K K on 2019/1/14.
//  Copyright © 2019 K K. All rights reserved.
//

import UIKit
import kk_chat
import SnapKit

class ViewController: UIViewController {

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero)
        return tableView
    }()
    
    lazy var chatToolBar: ChatToolBar = {
        let chatToolBar = ChatToolBar(frame: CGRect.zero)
        chatToolBar.delegate = self
        chatToolBar.dataSource = self
        return chatToolBar
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        view.addSubview(chatToolBar)
        chatToolBar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.snp.bottomMargin)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(chatToolBar.snp.top)
        }
    }

}


extension ViewController: ChatToolBarDataSource {
    
    func itemsFromChatToolBar(_ chatToolBar: ChatToolBar) -> [ItemModel]? {
        
        return [Item(title: "FM",icon: UIImage(named: "chatItem_FM")!),
                Item(title: "计算器",icon: UIImage(named: "chatItem_jisuanqi")!),
                Item(title: "日历",icon: UIImage(named: "chatItem_rili")!),
                Item(title: "视频",icon: UIImage(named: "icon_shipinginwen")!),
                Item(title: "FM",icon: UIImage(named: "chatItem_FM")!),
                Item(title: "计算器",icon: UIImage(named: "chatItem_jisuanqi")!),
                Item(title: "日历",icon: UIImage(named: "chatItem_rili")!),
                Item(title: "视频",icon: UIImage(named: "icon_shipinginwen")!),
                Item(title: "FM",icon: UIImage(named: "chatItem_FM")!),
                Item(title: "计算器",icon: UIImage(named: "chatItem_jisuanqi")!),
                Item(title: "日历",icon: UIImage(named: "chatItem_rili")!),
                Item(title: "视频",icon: UIImage(named: "icon_shipinginwen")!)]
    }
    
    func chatToolBar(_ chatToolBar: ChatToolBar, didSelectItemAt index: Int) {
        print("\(index)")
    }
}

extension ViewController: ChatToolBarDelegate {
    func chatToolBar(_ chatToolBar: ChatToolBar, heightChanged height: CGFloat) {
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func chatToolBar(_ chatToolBar: ChatToolBar, didSend text: String) {
        print(text)
    }
}



struct Item: ItemModel {
    
    var title: String
    
    var icon: UIImage
    
}
