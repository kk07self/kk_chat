//
//  ChatCollectionViewFlowLayout.swift
//  01_test
//
//  Created by 陈康 on 2017/6/9.
//  Copyright © 2017年 陈康. All rights reserved.
//

import UIKit

class ChatCollectionViewFlowLayout: UICollectionViewFlowLayout {

    private var size: CGSize = CGSize.zero
    private var sections: Int = 0 // 行数
    private var rows: Int = 0 // 每一行的个数
    private var edgeInsets: UIEdgeInsets = UIEdgeInsets.zero // 内边距
    private var columnSpacing: CGFloat = 0 // 列间距
    private var rowSpacing: CGFloat = 0 // 行间距
    private var attributesArray = [UICollectionViewLayoutAttributes]()
    private var pageSpacing: CGFloat = 0
    
    private var itemW: CGFloat {
        get {
            return (size.width - edgeInsets.left - CGFloat(sections)*rowSpacing - pageSpacing*2)/CGFloat(sections)
        }
    }
    
    /// 构造方法
    ///
    /// - Parameters:
    ///   - sections: 行数数
    ///   - rows: 每行的格式
    /// - Returns: 实例
    public class func chatCollectionViewFlowLayout(sections:Int,
                                                   rows: Int,
                                                   pageSize: CGSize,
                                                   pageSpacing: CGFloat?,
                                                   columnSpacing: CGFloat?,
                                                   rowSpacing: CGFloat?,
                                                   edgeInsets: UIEdgeInsets?) -> ChatCollectionViewFlowLayout {
        let chat = ChatCollectionViewFlowLayout()
        chat.scrollDirection = .horizontal
        chat.sections = sections
        chat.rows = rows
        chat.size = pageSize
        chat.pageSpacing = pageSpacing ?? 0
        chat.rowSpacing = rowSpacing ?? 0
        chat.columnSpacing = columnSpacing ?? 0
        chat.edgeInsets = edgeInsets ?? UIEdgeInsets.zero
        return chat
    }
    
    // 准备
    override func prepare() {
        super.prepare()
        
        // 行数
        if let sections = collectionView?.numberOfSections {
            for section in 0..<sections {
                if let items = collectionView?.numberOfItems(inSection: section) {
                    for row in 0..<items {
                        let indexPath = IndexPath(row: row, section: section)
                        if let attr = layoutAttributesForItem(at: indexPath) {
                            attributesArray.append(attr)
                        }
                    }
                }
            }
        }
    }
    
    
    override var collectionViewContentSize: CGSize {
        get {
            let items = collectionView!.numberOfItems(inSection: 0)
            let pageItems = sections * rows
            let remaind = items % pageItems
            var page = items / pageItems
            page = remaind > 0 ? page + 1 : page
            return CGSize(width: CGFloat(page) * size.width, height: 0)
        }
    }
    
    // 计算布局
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let itemH = (size.height - edgeInsets.top - CGFloat(rows)*columnSpacing)/CGFloat(rows)
        let pageNum = indexPath.row / (sections * rows)
        let x = indexPath.row % sections + pageNum * sections
        let y = indexPath.row / sections - pageNum * rows
        let itemX = edgeInsets.left + (itemW + columnSpacing) * CGFloat(x) + CGFloat(pageNum)*2*pageSpacing + pageSpacing
        let itemY = edgeInsets.top + (itemH + rowSpacing) * CGFloat(y)
        let attr = super.layoutAttributesForItem(at: indexPath)
        attr?.frame = CGRect(x: itemX, y: itemY, width: itemW, height: itemH)
        return attr
    }
    
    // 返回布局
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesArray
    }
}
