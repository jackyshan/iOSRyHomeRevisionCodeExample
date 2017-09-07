//
//  RyHomeMoreDetailView.swift
//  renttravel
//
//  Created by jackyshan on 2017/9/1.
//  Copyright © 2017年 GCI. All rights reserved.
//

import UIKit

class RyHomeMoreDetailView: UIView {

    // MARK: - 1、公共属性
    
    // MARK: - 2、私有属性
    
    // MARK: - 3、初始化
    static func view() -> RyHomeMoreDetailView? {
        return Bundle.main.loadNibNamed("RyHomeMoreDetailView", owner: nil
            , options: nil)![0] as? RyHomeMoreDetailView
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
    // MARK: - 8、其他
    deinit {
        if let appIdx = self.getClassName().range(of: Tools.BundleName)?.upperBound {
            Log.i("销毁页面"+self.getClassName().substring(from: appIdx))
        }
    }

}
