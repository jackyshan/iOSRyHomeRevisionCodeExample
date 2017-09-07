//
//  RyHomeStationLineListView.swift
//  renttravel
//
//  Created by jackyshan on 2017/9/4.
//  Copyright © 2017年 GCI. All rights reserved.
//

import UIKit

class RyHomeStationLineListView: UIView {

    // MARK: - 1、公共属性
    var dismissBlock: (() -> Void)?
    var clickNaviBlock: ((_ model: RyHomeNearStationModel) -> Void)?
    var clickLineBlock: ((_ model: RyHomeStationLineModel) -> Void)?
    // MARK: - 2、私有属性
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var descLb: UILabel!
    @IBOutlet weak var distanceLb: UILabel!
    @IBOutlet weak var emptyBtn: UIButton!

    var mAdapter: RyHomeStationLineListAdapter?
    var cmodel: RyHomeNearStationModel?
    
    // MARK: - 3、初始化
    static func view() -> RyHomeStationLineListView? {
        return Bundle.main.loadNibNamed("RyHomeStationLineListView", owner: nil
            , options: nil)![0] as? RyHomeStationLineListView
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
        mAdapter = RyHomeStationLineListAdapter(tableView: tableView)
    }
    
    func initLinstener() {
        mAdapter?.cellOnClick({ [weak self] (model) in
            self?.clickLineBlock?(model)
        })
    }
    
    // MARK: - 4、视图
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - 5、代理
    
    // MARK: - 6、公共业务
    func updateWithModel(model: RyHomeNearStationModel) {
        cmodel = model
        
        nameLb.text = model.name
        descLb.text = model.desc
        distanceLb.text = "距离您\(Int(model.locationDistance > 1000 ? model.locationDistance/1000 : model.locationDistance))\(model.locationDistance > 1000 ? "km" : "m")"
        
        mAdapter?.DataSoure = []
        if model.mtype == .busStation {
            getBusLineListData()
        }
        else if model.mtype == .boat {
            getBoatLineListData()
        }
        else if model.mtype == .subway {
            getSubwayLineListData()
        }
    }
    
    func show(superView: UIView) {
        UIView.animate(withDuration: 0.3) {
            self.frame = superView.bounds
        }
        
    }
    
    func dismiss() {
        dismissBlock?()
        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect.init(x: 0, y: self.bounds.height, width: self.bounds.width, height: self.bounds.height)
        }
    }
    
    func getEmptyHeight() -> CGFloat {
        return emptyBtn.frame.height
    }
    
    // MARK: - 7、私有业务
    @IBAction func clickDisBtn() {
        dismiss()
    }
    
    @IBAction func clickNaviBtn() {
        guard let model = cmodel else {return}
        
        clickNaviBlock?(model)
    }
    
    // MARK: - 网络
    // MARK: 巴士线路
    var datalst = [SiteInfo]()
    func getBusLineListData() {
        let send = SendGetByStation()
        send.stationNameId = cmodel?.sid
        self.datalst.removeAll()
        ViewUitl.showLoadingInView(tableView)
        BusNetWork.This.doTask(BusNetWork.CMD_routeStationGetByStation, data: send, controller: nil, success: {(responseObj:QueryStationResult?)in
            guard responseObj != nil else {
                return
            }
            let lineArray:[StationInfo] = (responseObj!.l as NSArray).jsonArray()!
            for itm in lineArray {
                var info = SiteInfo()
                info.lineName = itm
                self.datalst.append(info)
            }
            self.getForecastData()
            
        }, error: nil, com: {
            ViewUitl.hideLoadingInView(self.tableView)
        }, showWait: false)
    }
    //到站时间及站点数预测
    func getForecastData(){
        let  send2 = SendGetByStationNameID()
        send2.stationNameId = cmodel?.sid
        ViewUitl.showLoadingInView(tableView)
        BusNetWork.This.doArrayTask(BusNetWork.CMD_forecastGetByStationNameID, data: send2, controller: nil, success: {(responseObj:[GetByStationNameID]?) in
            let forecastArray:[GetByStationNameID] = responseObj!
            for i in 0...(forecastArray.count - 1) {
                self.datalst[i].forecast = forecastArray[i]
            }
            
            var models = [RyHomeStationLineModel]()
            for line in self.datalst {
                let model = RyHomeStationLineModel()
                model.mtype = .bus
                model.name = line.lineName.rn
                let end = line.lineName.dn.components(separatedBy: "-").last
                model.desc = "开往: \(end!)"
                model.time = Int(line.forecast.time)
                model.distance = Int(line.forecast.c)
                model.lid = line.lineName.ri
                models.append(model)
            }
            self.mAdapter?.DataSoure = models
            
        }, error: nil, com: {
            ViewUitl.hideLoadingInView(self.tableView)
        }, showWait: true)
    }
    
    // MARK: 水巴线路
    func getBoatLineListData() {
        let send = WaterBusSendModel()
        send.stationNameId = cmodel?.sid
        WaterBusNetWork.This.doTask(WaterBusNetWork.CMD_getStationDeail, data: send, controller: nil, success: { [weak self] (response: GetRoutesStationDeailModel?) in
            guard let wself = self else {
                return
            }
            
            guard let res = response else {
                return
            }
            
            var models = [RyHomeStationLineModel]()
            let lines: [ShuibaLineModel] = (res.l as NSArray).jsonArray()!
            for smodel in  lines {
                let model = RyHomeStationLineModel()
                model.mtype = .boat
                model.name = smodel.rn
                let end = smodel.dn.components(separatedBy: "-").last
                model.desc = "开往: \(end!)"
                model.lid = smodel.ri
                model.isHiddenTimeDistance = true
                models.append(model)
            }
            wself.mAdapter?.DataSoure = models
            
            }, error:nil, com: nil, showWait: false)

    }
    
    func getSubwayLineListData() {
        
    }

    // MARK: - 8、其他
    deinit {
        if let appIdx = self.getClassName().range(of: Tools.BundleName)?.upperBound {
            Log.i("销毁页面"+self.getClassName().substring(from: appIdx))
        }
    }

}
