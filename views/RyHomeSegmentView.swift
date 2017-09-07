//
//  RyHomeSegmentView.swift
//  renttravel
//
//  Created by jackyshan on 2017/9/1.
//  Copyright © 2017年 GCI. All rights reserved.
//

import UIKit

class RyHomeSegmentView: UIView {

    // MARK: - 1、公共属性
    var clickSegBtnBlock: ((_ tag: Int) -> Void)?
    
    // MARK: - 2、私有属性
    @IBOutlet weak var moveLineView: UIView!
    
    // MARK: - 3、初始化
    static func view() -> RyHomeSegmentView? {
        return Bundle.main.loadNibNamed("RyHomeSegmentView", owner: nil
            , options: nil)![0] as? RyHomeSegmentView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initUI()
        initLinstener()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
        initLinstener()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initUI() {
        
    }
    
    func initLinstener() {
        
    }
    
    // MARK: - 4、视图
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - 5、代理
    
    // MARK: - 6、公共业务
    
    // MARK: - 7、私有业务
    @IBAction func clickSegBtnAction(sender: UIButton) {
//        UIView.animate(withDuration: 0.3) { [weak self] in
//            self?.moveLineView.center.x = sender.center.x
//        }
        
        clickSegBtnBlock?(sender.tag)
    }
    
    // MARK: - 8、其他
    deinit {
        if let appIdx = self.getClassName().range(of: Tools.BundleName)?.upperBound {
            Log.i("销毁页面"+self.getClassName().substring(from: appIdx))
        }
    }

}
