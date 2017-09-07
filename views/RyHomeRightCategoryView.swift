//
//  RyHomeRightCategoryView.swift
//  renttravel
//
//  Created by jackyshan on 2017/9/1.
//  Copyright © 2017年 GCI. All rights reserved.
//

import UIKit

class RyHomeRightCategoryView: UIView {

    // MARK: - 1、公共属性
    var clickFilterBlock: (() -> Void)?
    var clickCategoryBlock: ((_ tag: Int) -> Void)?
    
    // MARK: - 2、私有属性
    @IBOutlet weak var filterIconBtn: UIButton!
    
    // MARK: - 3、初始化
    static func view() -> RyHomeRightCategoryView? {
        return Bundle.main.loadNibNamed("RyHomeRightCategoryView", owner: nil
            , options: nil)![0] as? RyHomeRightCategoryView
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
    func updateFilterIcon(_ type: RyHomeFilterCategoryStationType) {
        let iconImg = type == .all ? #imageLiteral(resourceName: "rynew_ic_sort") : type == .bus ? #imageLiteral(resourceName: "rynew_ic_buss") : type == .subway ? #imageLiteral(resourceName: "rynew_ic_dt") : type == .boat ? #imageLiteral(resourceName: "rynew_ic_matou") : #imageLiteral(resourceName: "rynew_ic_sort")
        
        filterIconBtn.setImage(iconImg, for: .normal)
    }
    
    // MARK: - 7、私有业务
    @IBAction func clickFilterAction(sender: UIButton) {
        clickFilterBlock?()
    }
    
    @IBAction func clickCategoryAction(sender: UIButton) {
        clickCategoryBlock?(sender.tag)
    }
    
    // MARK: - 8、其他
    deinit {
        if let appIdx = self.getClassName().range(of: Tools.BundleName)?.upperBound {
            Log.i("销毁页面"+self.getClassName().substring(from: appIdx))
        }
    }

}
