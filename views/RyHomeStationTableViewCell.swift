//
//  RyHomeStationTableViewCell.swift
//  renttravel
//
//  Created by jackyshan on 2017/9/2.
//  Copyright © 2017年 GCI. All rights reserved.
//

import UIKit

class RyHomeStationTableViewCell: UITableViewCell {

    // MARK: - 1、公共属性
    
    // MARK: - 2、私有属性
    @IBOutlet weak var iconLb: GciUILabel!
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var descLb: UILabel!
    @IBOutlet weak var distanceLb: UILabel!
    @IBOutlet weak var nearLb: UILabel!
    
    // MARK: - 3、初始化
    static func view() -> RyHomeStationTableViewCell? {
        return Bundle.main.loadNibNamed("RyHomeStationTableViewCell", owner: nil
            , options: nil)![0] as? RyHomeStationTableViewCell
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
    func updateWithModel(model: RyHomeNearStationModel) {
        iconLb.HexString = model.mtype == .subway ? "e723" : model.mtype == .boat ? "e726" : model.mtype == .busStation ? "e710" : "e710"
        titleLb.text = model.name
        descLb.text = model.desc
        distanceLb.text = "距离您\(Int(model.locationDistance > 1000 ? model.locationDistance/1000 : model.locationDistance))\(model.locationDistance > 1000 ? "km" : "m")"
        nearLb.isHidden = model.locationDistance == 0 ? true : !model.isNearest
    }
    
    // MARK: - 7、私有业务
    // MARK: - 8、其他
    deinit {
        if let appIdx = self.getClassName().range(of: Tools.BundleName)?.upperBound {
            Log.i("销毁页面"+self.getClassName().substring(from: appIdx))
        }
    }
    
}
