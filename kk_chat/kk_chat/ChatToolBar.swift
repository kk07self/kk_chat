//
//  ChatToolBar.swift
//  01_test
//
//  Created by 陈康 on 2017/6/8.
//  Copyright © 2017年 陈康. All rights reserved.
//

import UIKit

private let ItemsViewHeight: CGFloat = 215
private let isiphonex: Bool = {
    if #available(iOS 11.0, *) {
        guard let window = UIApplication.shared.keyWindow else {
            return false
        }
       return window.safeAreaInsets.bottom > 0.0
    } else {
        return false
    }
}()

/// 代理
@objc public protocol ChatToolBarDelegate: NSObjectProtocol {
    
    /// 点击键盘的发送按钮
    ///
    /// - Parameters:
    ///   - chatToolBar: self
    ///   - text: 要发送的内容
    @objc optional func chatToolBar(_ chatToolBar: ChatToolBar, didSend text: String)
    
    
    /// 录音太短
    ///
    /// - Parameter chatToolBar: self
    @objc optional func shortRecord(_ chatToolBar: ChatToolBar)
    
    /// 开始录音
    ///
    /// - Parameter chatToolBar: self
    
    /// 开始录音
    ///
    /// - Parameters:
    ///   - chatToolBar: self
    ///   - button: 按钮
    @objc optional func chatToolBar(_ chatToolBar: ChatToolBar, beginRecord button: UIButton)
    
    
    /// 正在录音
    ///
    /// - Parameters:
    ///   - chatToolBar: self
    ///   - button: 按钮
    @objc optional func chatToolBar(_ chatToolBar: ChatToolBar, recording button: UIButton)
    
    
    /// 手指移入到按钮区域
    ///
    /// - Parameters:
    ///   - chatToolBar: self
    ///   - button: 按钮
    @objc optional func chatToolBar(_ chatToolBar: ChatToolBar, inRecord button: UIButton)
    
    /// 手指移出按钮区域
    ///
    /// - Parameters:
    ///   - chatToolBar: self
    ///   - button: 按钮
    @objc optional func chatToolBar(_ chatToolBar: ChatToolBar, outRecord button: UIButton)
    
    /// 结束录音
    ///
    /// - Parameters:
    ///   - chatToolBar: self
    ///   - button: 按钮
    @objc optional func chatToolBar(_ chatToolBar: ChatToolBar, endRecord button: UIButton)
    
    
    /// 高度变化
    ///
    /// - Parameters:
    ///   - chatToolBar: self
    ///   - height: 高度
    func chatToolBar(_ chatToolBar: ChatToolBar, heightChanged height: CGFloat)
}


// MARK: - items
public protocol ChatToolBarDataSource: NSObjectProtocol {
    
    /// 获取底部按钮区域数据源
    ///
    /// - Parameter chatToolBar: toolbar
    /// - Returns: 数据源
    func itemsFromChatToolBar(_ chatToolBar: ChatToolBar) -> [ItemModel]?
    
    /// 更多下面的按钮点击
    ///
    /// - Parameters:
    ///   - chatToolBar: self
    ///   - index: 点击了哪一个按钮
    func chatToolBar(_ chatToolBar: ChatToolBar, didSelectItemAt index: Int)
}


public class ChatToolBar: UIView {
    
    public var delegate: ChatToolBarDelegate?
    public var dataSource: ChatToolBarDataSource?
    
    public var recode_min_second: TimeInterval = 1
    
    /// 显示键盘的图标
    public var keyboardIcon: UIImage? {
        didSet {
            leftItem.setImage(keyboardIcon, for: .selected)
            emojiItem.setImage(keyboardIcon, for: .selected)
        }
    }
    
    /// 显示emoji的图标
    public var emojiIcon: UIImage? {
        didSet {
            emojiItem.setImage(emojiIcon, for: .normal)
        }
    }
    
    
    /// 显示更多的图标
    public var moreIcon: UIImage? {
        didSet {
            moreItem.setImage(moreIcon, for: .normal)
            moreItem.setImage(moreIcon, for: .selected)
        }
    }
    
    /// 显示录音的图标
    public var recordIcon: UIImage? {
        didSet {
            leftItem.setImage(recordIcon, for: .normal)
        }
    }
    
    fileprivate var view: UIView!
    
    fileprivate var inputText: String = ""
    fileprivate var beginRecordTime = Date()
    
    // 记住选中了哪个按钮
    fileprivate var selectedItemIndex: SelectedRightItemIndex = .none
    
    @IBOutlet fileprivate weak var textView: UITextView!
    @IBOutlet fileprivate weak var leftItem: UIButton!
    @IBOutlet fileprivate weak var emojiItem: UIButton!
    @IBOutlet fileprivate weak var moreItem: UIButton!
    
    @IBOutlet fileprivate weak var recordSuperView: UIView!
    @IBOutlet fileprivate weak var recordButton: UIButton!
    @IBOutlet fileprivate weak var recordView: UIView!
    
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var rightItemsWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var contentView: UIView!
    @IBOutlet fileprivate weak var itemsView: ItemsView!
    @IBOutlet fileprivate weak var emojiView: EmojiView!
    
    fileprivate let textViewMinHeight: CGFloat = 34
    fileprivate let textViewMaxHeight: CGFloat = 122
    fileprivate var textViewLastHeight: CGFloat!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        contentViewHeightConstraint.removeObserver(self, forKeyPath: "constant")
        textViewHeightConstraint.removeObserver(self, forKeyPath: "constant")
    }
    
    /// 初始化控件
    private func xibSetup() {
        view = UINib(nibName: "ChatToolBar", bundle: Bundle(path: Bundle(for: type(of: self)).bundlePath + "/resources.bundle")).instantiate(withOwner: self, options: nil)[0] as? UIView
        view.frame = bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
        
        // 录音控件
        
        recordView.isHidden = true
        recordView.layer.cornerRadius = 5
        recordView.layer.masksToBounds = true
        recordView.layer.borderWidth = 1
        recordView.layer.borderColor = UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1).cgColor
        
        recordButton.addTarget(self, action: #selector(touchUpInside(button:)), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(touchDown(button:)), for: .touchDown)
        recordButton.addTarget(self, action: #selector(touchUpOutside(button:)), for: .touchUpOutside)
        recordButton.addTarget(self, action: #selector(touchDragEixt(button:)), for: .touchDragExit)
        recordButton.addTarget(self, action: #selector(touchDragEnter(button:)), for: .touchDragEnter)
        
        
        // 按钮事件
        leftItem.addTarget(self, action: #selector(ChatToolBar.clickLeftItem), for: .touchUpInside)
        emojiItem.addTarget(self, action: #selector(ChatToolBar.clickItem), for: .touchUpInside)
        moreItem.addTarget(self, action: #selector(ChatToolBar.clickItem), for: .touchUpInside)
        
        // textView样式
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 3, bottom: 8, right: 3)
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        contentViewHeightConstraint.constant = 0
        textView.returnKeyType = .send
        
        // 监听通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange(note:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        contentViewHeightConstraint.addObserver(self, forKeyPath: "constant", options: .new, context: nil)
        textViewHeightConstraint.addObserver(self, forKeyPath: "constant", options: .new, context: nil)
                
        // 初始化高度
        textViewLastHeight = textViewMinHeight
        
        // 设置代理
        emojiView.delegate = self
        itemsView.delegate = self
        
        let bundle =  Bundle(for: ChatToolBar.classForCoder())
        leftItem.setImage(UIImage(named:"resources.bundle/chat_voice_icon",in:bundle, compatibleWith:nil), for: .normal)
        leftItem.setImage(UIImage(named:"resources.bundle/chat_keyboard_icon",in:bundle, compatibleWith:nil), for: .selected)
        emojiItem.setImage(UIImage(named:"resources.bundle/chat_emoji_icon",in:bundle, compatibleWith:nil), for: .normal)
        emojiItem.setImage(UIImage(named:"resources.bundle/chat_keyboard_icon",in:bundle, compatibleWith:nil), for: .selected)
        moreItem.setImage(UIImage(named:"resources.bundle/chat_more_icon",in:bundle, compatibleWith:nil), for: .normal)
        emojiItem.setImage(UIImage(named:"resources.bundle/chat_emoji_icon",in:bundle, compatibleWith:nil), for: .normal)
        
    }
    
    // 手动显示、隐藏按钮
    public func isHideChatToolBarContentView(_ isHide: Bool) {
        
        // 隐藏
        if isHide {
            // 隐藏键盘
            if textView.isFirstResponder {
                self.selectedItemIndex = .none
                textView.resignFirstResponder()
            } else {
                // 隐藏按钮
                self.contentViewHeightConstraint.constant = 0
                self.selectedItemIndex = .none
                contentView.isHidden = isHide
            }
        } else {
            // 显示
            textView.becomeFirstResponder()
        }
    }
}


// MARK: toolBar录音控件点击事件
extension ChatToolBar {
    
    @objc func touchUpInside(button: UIButton) {
        recordView.backgroundColor = UIColor.white
        recordButton.setTitle("请按住说话", for: .normal)
        let bti = beginRecordTime.timeIntervalSince1970
        let eti = Date().timeIntervalSince1970
        if (eti - bti) < recode_min_second {
            delegate?.shortRecord?(self)
            return
        }
        delegate?.chatToolBar?(self, endRecord: button)
    }
    
    @objc func touchUpOutside(button: UIButton) {
        recordView.backgroundColor = UIColor.white
        recordButton.setTitle("请按住说话", for: .normal)
        let bti = beginRecordTime.timeIntervalSince1970
        let eti = Date().timeIntervalSince1970
        if (eti - bti) < recode_min_second {
            delegate?.shortRecord?(self)
            return
        }
        delegate?.chatToolBar?(self, endRecord: button)
    }
    
    @objc func touchDown(button: UIButton) {
        recordView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        beginRecordTime = Date()
        recordButton.setTitle("松开 发送", for: .normal)
        delegate?.chatToolBar?(self, beginRecord: button)
    }
    
    @objc func touchDragEnter(button: UIButton) {
        recordButton.setTitle("松开 发送", for: .normal)
        delegate?.chatToolBar?(self, inRecord: button)
    }
    
    @objc func touchDragEixt(button: UIButton) {
        recordButton.setTitle("松开 取消发送", for: .normal)
        delegate?.chatToolBar?(self, outRecord: button)
    }
}


// MARK: toolBar的按钮点击事件
extension ChatToolBar {
    
    // 点击左侧按钮
    @objc fileprivate func clickLeftItem(item: UIButton) {
        
        leftItem.isSelected = !leftItem.isSelected
        selectedItemIndex = .none
        
        // 取消右侧两个按钮的选中
        emojiItem.isSelected = false
        moreItem.isSelected = false
        
        if leftItem.isSelected {
            recordView.isHidden = false
            textView.resignFirstResponder()
            inputText = textView.text
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self.contentView.isHidden = true
            })
            textView.text = ""
            textView.delegate?.textViewDidChange!(textView)
            contentViewHeightConstraint.constant = 0
            
        } else {
            recordView.isHidden = true
            contentView.isHidden = false
            textView.becomeFirstResponder()
            textView.text = inputText
            textView.delegate?.textViewDidChange!(textView)
        }
    }
    
    // 点击右侧的两个按钮
    @objc fileprivate func clickItem(item: UIButton) {
        
        // 还原左侧按钮状态及隐藏录音控件
        leftItem.isSelected = false
        recordView.isHidden = true
        contentView.isHidden = false
        
        // 恢复textView的内容
        textView.text = inputText
        textView.delegate?.textViewDidChange!(textView)
        
        // 判断点击了哪个按钮
        switch item {
        case emojiItem:
            emojiItem.isSelected = !emojiItem.isSelected
            // 如果之前是更多选中，现在就更多选中；如果不是，就更多选中取反
            selectedItemIndex = moreItem.isSelected ? .emoji : ( emojiItem.isSelected ? .emoji : .none )
            
            // 取消更多的选中
            moreItem.isSelected = false
            
        case moreItem:
            
            moreItem.isSelected = !moreItem.isSelected
            // 如果之前是emoji选中，现在就更多选中；如果不是，就更多选中取反
            selectedItemIndex = emojiItem.isSelected ? .items : (moreItem.isSelected ? .items : .none)
            
            // 取消emoji的选中
            emojiItem.isSelected = false
            
            
        default:
            break
        }
        
        if selectedItemIndex == .none {
            // 显示键盘
            textView.becomeFirstResponder()
            return
        }
        
        // 显示非键盘内容
        if !textView.isFirstResponder {
            showContentView()
            if self.contentViewHeightConstraint.constant != ItemsViewHeight {
                self.contentViewHeightConstraint.constant = ItemsViewHeight
            }
        } else {
            textView.resignFirstResponder()
            showContentView()
        }
    }
    
    // 显示emoji内容
    private func showContentView() {
        if selectedItemIndex == .emoji {
            // 显示emoj键盘
            itemsView.isHidden = true
            emojiView.isHidden = false
            return
        }
        
        if selectedItemIndex == .items {
            // 显示相机等按钮键盘
            itemsView.isHidden = false
            itemsView.items = dataSource?.itemsFromChatToolBar(self) ?? [ItemModel]()
            emojiView.isHidden = true
            return
        }
    }
}


// MARK: emoji键盘代理
extension ChatToolBar: EmojiViewDelegate, ItemsViewDelegate {
    
    public func emojiViewDeleteEmoj() {
        // 删除
        if textView.text.count == 0 {
            return
        }
        textView.text.remove(at: textView.text.index(before: textView.text.endIndex))
        textView.delegate?.textViewDidChange!(textView)
    }
    
    public func emojiView(insetText text: String) {
        // 添加
        textView.text = textView.text + text
        textView.delegate?.textViewDidChange?(textView)
    }
    
    public func emojiViewSendEmoj() {
        // 发送
        delegate?.chatToolBar?(self, didSend: textView.text)
        textView.text = ""
        inputText = ""
        textViewDidChange(textView)
    }
    
    public func itemView(didSelectItemAt index: Int) {
        dataSource?.chatToolBar(self, didSelectItemAt: index)
    }
    
}


// MARK: 监听textView的内容变化、键盘的变化
extension ChatToolBar: UITextViewDelegate {
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            delegate?.chatToolBar?(self, didSend: textView.text)
            textView.text = ""
            inputText = ""
            textViewDidChange(textView)
            return false
        }
        return true
    }

    
    public func textViewDidChange(_ textView: UITextView) {
        if leftItem.isSelected == false {
            inputText = textView.text
        }
        
        // 计算textView内容的高度
        let size = (textView.text! as NSString).boundingRect(with: CGSize(width:textView.frame.size.width - textView.textContainerInset.left - textView.textContainerInset.right - textView.textContainer.lineFragmentPadding*2,height:CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font:textView.font!], context: nil).size
        
        var height = max(size.height, textViewMinHeight)
        
        if height > textViewMaxHeight {
            height = textViewMaxHeight
        }
        if textViewLastHeight != height {
            textViewLastHeight = height
            if height != textViewMinHeight && height != textViewMaxHeight {
                height += 8
                textView.textContainerInset = UIEdgeInsets(top: 4, left: 3, bottom: 4, right: 3)
            } else {
                textView.textContainerInset = UIEdgeInsets(top: 8, left: 3, bottom: 8, right: 3)
                if height == textViewMaxHeight && !textView.isFirstResponder {
                    var offset = textView.contentOffset
                    offset.y = textView.contentSize.height - height
                    textView.contentOffset = offset
                }
            }
            
            // 已经相等了，退出后面的再布局
            if textViewHeightConstraint.constant == height {
                return
            }
            
            // 再布局
            textViewHeightConstraint.constant = height
            UIView.animate(withDuration: 0.25, animations: {
                self.textView.scrollRangeToVisible(NSRange(location: self.textView.text.count, length: 1))
            })
        } else {
            if height == textViewMaxHeight && !textView.isFirstResponder {
                var offset = textView.contentOffset
                offset.y = textView.contentSize.height - height
                textView.contentOffset = offset
            }
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "constant" {
            if (change?[NSKeyValueChangeKey.newKey] as? CGFloat) != nil {
                delegate?.chatToolBar(self, heightChanged: contentViewHeightConstraint.constant + textViewHeightConstraint.constant + 20)
            }
        }
    }
    
    @objc fileprivate func keyboardChange(note: NSNotification) {
        // 键盘信息
        let size = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect).size
        let origin = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect).origin
        var height = size.height
        if isiphonex, #available(iOS 11.0, *) {
            height -= UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        }
        // origin.y < kscreenHeight  显示键盘；> 隐藏键盘，切需要判断是不是显示emoji键盘
        self.contentViewHeightConstraint.constant = origin.y < kScreenHeight ? height : (selectedItemIndex == .none ? 0 : ItemsViewHeight)
        contentView.isHidden = selectedItemIndex == .none
    }
}
