//
//  RyHomeStationListView.swift
//  renttravel
//
//  Created by jackyshan on 2017/9/2.
//  Copyright © 2017年 GCI. All rights reserved.
//

import UIKit

class RyHomeStationListView: UIView {

    // MARK: - 1、公共属性
    var clickStationBlock: ((_ model: RyHomeNearStationModel) -> Void)?
    
    var dismissBlock: (() -> Void)?
    
    // MARK: - 2、私有属性
    @IBOutlet weak var tableView: UITableView!
    
    var mAdapter: RyHomeStationListAdapter?
    
    // MARK: - 3、初始化
    static func view() -> RyHomeStationListView? {
        return Bundle.main.loadNibNamed("RyHomeStationListView", owner: nil
            , options: nil)![0] as? RyHomeStationListView
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
        mAdapter = RyHomeStationListAdapter(tableView: tableView)
    }
    
    func initLinstener() {
        mAdapter?.cellOnClick({ [weak self] (model) in
            self?.clickStationBlock?(model)
        })
    }
    
    // MARK: - 4、视图
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - 5、代理
    
    // MARK: - 6、公共业务
    func show(superView: UIView) {
        superView.addSubview(self)
        self.frame = CGRect.init(x: 0, y: superView.bounds.height, width: superView.bounds.width, height: superView.bounds.height)
        UIView.animate(withDuration: 0.3) { 
            self.frame = superView.bounds
        }
        
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.3, animations: { 
            self.frame = CGRect.init(x: 0, y: self.bounds.height, width: self.bounds.width, height: self.bounds.height)
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
    
    func updateAdapterWithArr(_ dataArr: [RyHomeNearStationModel]) {
        let models = sortModelArray(dataArr)
        models.first?.isNearest = true
        mAdapter?.DataSoure = models
    }
    
    // MARK: - 7、私有业务
    //MARK: 对数组中的模型进行排序
    func sortModelArray(_ responseData:[RyHomeNearStationModel]) -> [RyHomeNearStationModel] {
        let tempM = NSMutableArray(array: (responseData as NSArray))
        for i in 0..<tempM.count {
            for j in i..<tempM.count {
                let bingData1 = tempM[i] as! RyHomeNearStationModel
                let bingData2 = tempM[j] as! RyHomeNearStationModel
                if bingData1.locationDistance > bingData2.locationDistance {
                    tempM.replaceObject(at: i, with: bingData2)
                    tempM.replaceObject(at: j, with: bingData1)
                }
            }
        }
        return (tempM as NSArray) as! [RyHomeNearStationModel]
    }
    
    @IBAction func clickDisBtn() {
        dismiss()
        dismissBlock?()
    }
    // MARK: - 8、其他
    deinit {
        if let appIdx = self.getClassName().range(of: Tools.BundleName)?.upperBound {
            Log.i("销毁页面"+self.getClassName().substring(from: appIdx))
        }
    }

}
