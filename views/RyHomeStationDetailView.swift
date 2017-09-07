//
//  RyHomeStationDetailView.swift
//  renttravel
//
//  Created by jackyshan on 2017/9/1.
//  Copyright © 2017年 GCI. All rights reserved.
//

import UIKit

class RyHomeStationDetailView: UIView {

    // MARK: - 1、公共属性
    var cmodel: RyHomeNearStationModel?
    
    // MARK: - 2、私有属性
    @IBOutlet weak var iconLb: GciUILabel!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var descLb: UILabel!
    @IBOutlet weak var distanceLb: UILabel!
    
    // MARK: - 3、初始化
    static func view() -> RyHomeStationDetailView? {
        return Bundle.main.loadNibNamed("RyHomeStationDetailView", owner: nil
            , options: nil)![0] as? RyHomeStationDetailView
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
    func updateWithModel(_ model: RyHomeNearStationModel) {
        cmodel = model
        
        iconLb.HexString = model.mtype == .subway ? "e723" : model.mtype == .boat ? "e726" : model.mtype == .busStation ? "e710" : "e710"
        nameLb.text = model.name
        descLb.text = model.desc
        distanceLb.text = model.locationDistance == 0 ? "" : "距离您\(Int(model.locationDistance > 1000 ? model.locationDistance/1000 : model.locationDistance))\(model.locationDistance > 1000 ? "km" : "m")"

    }
    
    // MARK: - 7、私有业务
    // MARK: - 8、其他
    deinit {
        if let appIdx = self.getClassName().range(of: Tools.BundleName)?.upperBound {
            Log.i("销毁页面"+self.getClassName().substring(from: appIdx))
        }
    }

}
