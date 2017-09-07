//
//  RyHomeStationLineListTableViewCell.swift
//  renttravel
//
//  Created by jackyshan on 2017/9/4.
//  Copyright © 2017年 GCI. All rights reserved.
//

import UIKit

class RyHomeStationLineListTableViewCell: UITableViewCell {

    // MARK: - 1、公共属性
    
    // MARK: - 2、私有属性
    @IBOutlet weak var iconLb: GciUILabel!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var descLb: UILabel!
    @IBOutlet weak var distanceLb: UILabel!
    @IBOutlet weak var timeLb: UILabel!
    
    // MARK: - 3、初始化
    static func view() -> RyHomeStationLineListTableViewCell? {
        return Bundle.main.loadNibNamed("RyHomeStationLineListTableViewCell", owner: nil
            , options: nil)![0] as? RyHomeStationLineListTableViewCell
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
    func updateWithModel(model: RyHomeStationLineModel) {
        iconLb.HexString = model.mtype == .subway ? "e72b" : model.mtype == .boat ? "e730" : model.mtype == .bus ? "e715" : "e715"
        nameLb.text = model.name
        descLb.text = model.desc

        timeLb.isHidden = model.isHiddenTimeDistance
        distanceLb.isHidden = model.isHiddenTimeDistance
        switch model.time {
            case -1:
                distanceLb.text = "尚未发车"
                timeLb.text =  "---"
            case 0 :
                distanceLb.text = "已进站"
                let str = "\(model.time)分"
                let message = NSMutableAttributedString(string: str)
                let range = (str as NSString).range(of: String("分"))
                message.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 12), range: range)
                let range1 = (str as NSString).range(of: String("\(model.time)"))
                message.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 18), range: range1)
                timeLb.attributedText = message
            default:
                let str1 = "距离本站\(model.distance)站"
                let message1 = NSMutableAttributedString(string: str1)
                let range2 = (str1 as NSString).range(of: String("\(model.distance)"))
                message1.addAttribute(NSForegroundColorAttributeName, value: ViewUitl.colorWithHexString(hex: "#E33E3E"), range: range2)
                
                distanceLb.attributedText = message1
                
                let str = "\(model.time)分"
                let message = NSMutableAttributedString(string: str)
                let range = (str as NSString).range(of: String("分"))
                message.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 12), range: range)
                let range1 = (str as NSString).range(of: String("\(model.time)"))
                message.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 18), range: range1)
                timeLb.attributedText = message
                
                break
        }
    }

    // MARK: - 7、私有业务
    // MARK: - 8、其他
    deinit {
        if let appIdx = self.getClassName().range(of: Tools.BundleName)?.upperBound {
            Log.i("销毁页面"+self.getClassName().substring(from: appIdx))
        }
    }
    
}
