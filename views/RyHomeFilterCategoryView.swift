//
//  RyHomeFilterCategoryView.swift
//  renttravel
//
//  Created by jackyshan on 2017/9/4.
//  Copyright © 2017年 GCI. All rights reserved.
//

import UIKit

class RyHomeFilterCategoryView: UIView {

    // MARK: - 1、公共属性
    var clickFilterBlock: ((_ tag: Int) -> Void)?
    
    // MARK: - 2、私有属性
    
    // MARK: - 3、初始化
    static func view() -> RyHomeFilterCategoryView? {
        return Bundle.main.loadNibNamed("RyHomeFilterCategoryView", owner: nil
            , options: nil)![0] as? RyHomeFilterCategoryView
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
        self.backgroundColor = ViewUitl.getUIColorByHex(red: 0, green: 0, blue: 0, alpha: 0.5)
    }
    
    func initLinstener() {
        
    }
    
    // MARK: - 4、视图
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - 5、代理
    
    // MARK: - 6、公共业务
    func show(superView: UIView?) {
        guard let superView = superView else {return}
        
        superView.addSubview(self)
        self.frame = superView.bounds
    }
    
    func dismiss() {
        self.removeFromSuperview()
    }
    
    // MARK: - 7、私有业务
    @IBAction func clickDisBtn(_ sender: UIButton) {
        dismiss()
        clickFilterBlock?(sender.tag)
    }

    
    // MARK: - 8、其他
    deinit {
        if let appIdx = self.getClassName().range(of: Tools.BundleName)?.upperBound {
            Log.i("销毁页面"+self.getClassName().substring(from: appIdx))
        }
    }

}
