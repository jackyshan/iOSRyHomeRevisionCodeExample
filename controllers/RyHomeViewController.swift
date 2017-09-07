//
//  RyHomeViewController.swift
//  renttravel
//
//  Created by jackyshan on 2017/8/31.
//  Copyright © 2017年 GCI. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RyHomeViewController: GdWalkNaviBaseViewController, MAMapViewDelegate  {

    // MARK: - 1、属性
    @IBOutlet weak var mMapView: UIView!
    @IBOutlet weak var ryHomeSegmentView: RyHomeSegmentView!
    @IBOutlet weak var ryHomeRightCategoryView: RyHomeRightCategoryView!
    @IBOutlet weak var locationBtn: UIButton!
    @IBOutlet weak var lineChangeBtn: UIButton!
    @IBOutlet weak var ryHomeCommonVehicleView: RyHomeCommonVehicleView!
    
    let lineListView = RyHomeStationLineListView.view()
    @IBOutlet weak var ryHomeStationDetailView: RyHomeStationDetailView!
    @IBOutlet weak var ryHomeMoreDetailView: RyHomeMoreDetailView!
    @IBOutlet weak var ryHomeBottomDetailView: UIView!
    @IBOutlet weak var bottomViewHeightConstant: NSLayoutConstraint!
    
    fileprivate var mapView: MAMapView!
    fileprivate let zoomscal: CGFloat = 15.5
    
    var movedLocationCoordinate: CLLocationCoordinate2D?
    let originLocationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: 23.137464, longitude: 113.325062)
    
    var subwayAnnotations: [RyHomeMAPointAnnotation] = [RyHomeMAPointAnnotation]()
    var boatAnnotations: [RyHomeMAPointAnnotation] = [RyHomeMAPointAnnotation]()
    var busStationAnnotations: [RyHomeMAPointAnnotation] = [RyHomeMAPointAnnotation]()
    
    var subWayResponseModel: SubwayResponseModel?
    var shuibaResponseArr: [ShuiBaStationModel]?
    var nearStationModelArr: [RyHomeNearStationModel] = [RyHomeNearStationModel]()
    
    var filterType: RyHomeFilterCategoryStationType = .all
    
    // MARK: - 2、生命周期
    init() {
        super.init(nibName: "RyHomeViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initLinstener()
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: 初始化ui
    func initUI() {
        self.view.backgroundColor = AppConfig.XXT_LightGray
        
        initMapView()
        
        if let listView = self.lineListView {
            self.view.addSubview(listView)
        }
    }
    
    fileprivate func initMapView() {
        mapView = MAMapView(frame: self.mMapView.bounds)
        mapView.showsCompass = false
        mapView.mapType = MAMapType.standard
        mapView.isRotateCameraEnabled = false
        mapView.setUserTrackingMode(.follow, animated: true)
        mapView.zoomLevel = zoomscal
        mapView.showsScale = false
        mapView.pausesLocationUpdatesAutomatically = false
        mapView.distanceFilter = 500
        mapView.desiredAccuracy = kCLLocationAccuracyHundredMeters
        mapView.customizeUserLocationAccuracyCircleRepresentation = true
        mMapView.addSubview(mapView)
        mMapView.insertSubview(mapView, at: 0)
        mapView.delegate = self
        mapView.setCenter(originLocationCoordinate, animated: true)
    }

    
    // MARK: 初始化linstener
    func initLinstener() {
        //点击seg
        clickSegBtnBlockAction()
        //点击filter
        clickFilterBlockAction()
        //点击收藏、提醒、地铁、水巴
        clickCategoryBlockAction()
        
        //ryHomeStationDetailView手势
        addStationDetailTapGesture()
        addStationDetailPanGesture()
        
        //RyHomeStationLineListView
        clickStationHeaderBlock()
    }
    
    // MARK: 初始化data
    func initData() {
        
        //h5配置
        getConfigH5Urls().retry(3).subscribe().addDisposableTo(disposeBag)
    }
    
    // MARK: 设置frame
    override func didSystemAutoLayoutComplete() {
        self.lineListView?.frame = CGRect.init(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height)
    }
    
    // MARK: - 3、代理
    // MARK: MAMapViewDelegate
    func mapViewDidFinishLoadingMap(_ mapView: MAMapView!) {
        Log.i("地图加载完成")
    }
    
    func mapViewDidStopLocatingUser(_ mapView: MAMapView!) {
        Log.i("地图停止定位")
    }
    
    func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool) {
        Log.i("区域改变")
    }
    
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        Log.i("拖动地图移动时执行")
        
        guard wasUserAction == true else {return}
        
        let point:CGPoint = CGPoint(x: mapView.frame.size.width*0.5, y: mapView.frame.size.height*0.5)
        let location2D = mapView.convert(point, toCoordinateFrom: mMapView)
        movedLocationCoordinate = location2D
        getData()
    }
    
    /// 位置更新，回调获取定点经纬度
    var isFirst = true
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        if updatingLocation == true && isFirst == true {
            isFirst = false
            locationUserPlace(nil)
        }
        
        if updatingLocation == true {
            let uLocation = JZLocationConverter.gcj02(toWgs84: userLocation.location.coordinate)
            AuthManager.This.mLatitude = uLocation.latitude
            AuthManager.This.mLongitude = uLocation.longitude
        }
    }
    
    //定位失败
    var isLocationFailFirst = true
    func mapView(_ mapView: MAMapView!, didFailToLocateUserWithError error: Error!) {
        Log.i("定位失败")
        if isLocationFailFirst == true {
            isLocationFailFirst = false
            
            //附近站点
            movedLocationCoordinate = originLocationCoordinate
            getData()
        }
    }
    
    //地图加载失败
    func mapViewDidFailLoadingMap(_ mapView: MAMapView!, withError error: Error!) {
        Log.i("地图加载失败")
    }
    
    //自定义精度圈
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay.isKind(of: MACircle.self) {
            if let mapCircle = MACircleRenderer(overlay: overlay) {
                mapCircle.lineWidth = 1
                mapCircle.strokeColor = UIColor(red: 66/255.0, green: 135/255.0, blue: 255/255.0, alpha: 1)
                mapCircle.fillColor = UIColor(red: 66/255.0, green: 135/255.0, blue: 255/255.0, alpha: 0.1)
                mapCircle.lineDash = true
                return mapCircle
            }
        }
        return nil
    }
    
    //生成annotationView
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationViewIdentifier") as? RyHomeMAAnnotationView
        if annotationView == nil {
            annotationView = RyHomeMAAnnotationView(annotation: annotation, reuseIdentifier: "annotationViewIdentifier")
        }
        
        if annotation is RyHomeMAPointAnnotation {
            let currentAnnoation = annotation as! RyHomeMAPointAnnotation
            annotationView?.mType = currentAnnoation.mType
            annotationView?.mStationModel = currentAnnoation.mStationModel
            annotationView?.updateImg()
        }
        else if annotation is RyUserMAPointAnnotation {
            annotationView?.mType = .userLocation
            annotationView?.image = #imageLiteral(resourceName: "rynew_ic_orient")
        }
        else {//禁用系统圆点
            annotationView?.mType = .userLocation
            annotationView?.image = nil
        }
        
        return annotationView
    }
    
    //选中annotation
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        Log.i("选中annotation")
        if view is RyHomeMAAnnotationView {
            let annotationView = view as! RyHomeMAAnnotationView
            UIView.animate(withDuration: 0.3, animations: {
                annotationView.updateImg()
            })
            clickStationAnnotationAction(annotationView.mStationModel)
        }
        
    }
    
    func mapView(_ mapView: MAMapView!, didDeselect view: MAAnnotationView!) {
        Log.i("取消annotation")
        if view is RyHomeMAAnnotationView {
            let annotationView = view as! RyHomeMAAnnotationView
            UIView.animate(withDuration: 0.3, animations: {
                annotationView.updateImg()
            })
            unClickStationAnnotationAction()
        }
    }
    
    func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        Log.i("点击地图回调")
    }
    
    // MARK: - 4、业务
    // MARK: 添加经度圈
    func addOverlay(_ coordate:CLLocationCoordinate2D) {
        let circle = MACircle(center: coordate, radius: 500)
        mapView.add(circle, level: MAOverlayLevel.aboveLabels)
    }
    
    // MARK: 用户定位
    var userAnnotation = RyUserMAPointAnnotation()
    @IBAction func locationUserPlace(_ sender: UIButton?) {
        guard AppConfig.isSystemOpenLocation() else {
            return
        }
        
        self.mapView.removeAnnotation(userAnnotation)
        userAnnotation.coordinate = self.mapView.userLocation.coordinate
        self.mapView.addAnnotation(userAnnotation)
        
        self.mapView.setCenter(self.mapView.userLocation.coordinate, animated: false)
        self.mapView.setZoomLevel(zoomscal, animated: true)
        
        movedLocationCoordinate = userAnnotation.coordinate
        getData()
    }
    
    // MARK: 点击seg模块
    func clickSegBtnBlockAction() {

        ryHomeSegmentView.clickSegBtnBlock = { [weak self] tag in
            if tag == 1 {
                let vc = RuyueBusTabBarViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            else if tag == 2 {
                let vc = KPWebViewController()
                vc.transferUrl = AuthManager.This.ryH5ConfigModel?.kepiao
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            else if tag == 3 {
                
            }
        }
        
    }
    
    // MARK: 点击filter模块
    func clickFilterBlockAction() {
        
        ryHomeRightCategoryView.clickFilterBlock = { [weak self] in
            let filterView = RyHomeFilterCategoryView.view()
            filterView?.show(superView: self?.view)
            filterView?.clickFilterBlock = { [weak self] tag in
                guard tag != 0 else {return}
                
                if tag == 1 {
                    self?.filterType = .all
                }
                else if tag == 2 {
                    self?.filterType = .bus
                }
                else if tag == 3 {
                    self?.filterType = .subway
                }
                else if tag == 4 {
                    self?.filterType = .boat
                }
                
                self?.getData()
            }
        }
        
    }
    
    // MARK: 点击category模块
    func clickCategoryBlockAction() {
        
        ryHomeRightCategoryView.clickCategoryBlock = { [weak self] tag in
            if tag == 0 {
                guard AppConfig.isLogin() else {return}
                let vc = MyCollectionViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            else if tag == 1 {
                guard AppConfig.isLogin() else {return}
                let vc = RemindDetailsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            else if tag == 2 {
                if let resp = self?.subWayResponseModel {
                    let vc = SubwayViewController()
                    vc.responseModel = resp
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    let vc = WebViewController()
                    vc.transferUrl = AuthManager.This.ryH5ConfigModel?.subway
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else if tag == 3 {
                if let respArr = self?.shuibaResponseArr {
                    let vc = NearTerminalViewController()
                    vc.shuibaResponseArr = respArr
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                else{
                    let vc = AllRoutesViewController()
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    // MARK: 点击滑动站点头部模块
    func clickStationHeaderBlock() {
        lineListView?.clickNaviBlock = { [weak self] model in
            guard let userLocation = self?.mapView.userLocation.location else {return}
            guard let destLocation = model.location else {return}
            
            self?.startWalkWith(startLocation: userLocation.coordinate, endLocation: destLocation.coordinate)
        }
        
        lineListView?.clickLineBlock = { [weak self] model in
            if model.mtype == .bus {
                let vc = BusLineDetailsController()
                vc.transmitRouteId = model.lid
                vc.transmitRouteName = model.name
                vc.transmitRouteDirection = "0"
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            else if model.mtype == .boat {
                let vc = WaterBusLineDeailViewController()
                vc.transmitRouteId = model.lid
                vc.mtransmitDirection = "0"
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            else if model.mtype == .subway {
                guard let sid = Int(model.lid) else {return}
                self?.getSubwayLineData(sid)
            }
        }
    }
    
    // MARK: 点击用户
    @IBAction func clickUserAction() {
        let vc = PersonalCenterVC()
        vc.mtransmitNoticeUrl = AuthManager.This.ryH5ConfigModel?.info
        vc.mtransmitFacebackUrl = AuthManager.This.ryH5ConfigModel?.feedback
        vc.mtransmitJianpaiUrl = AuthManager.This.ryH5ConfigModel?.jianpai
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: 点击搜索
    @IBAction func clickSearchAction() {
        let vc = SearchAllViewController()
        self.navigationController?.pushViewController(vc, animated: false)

    }
    
    // MARK: 点击语音
    @IBAction func clickVoiceAction() {
        let vc = SearchForVoiceVC()
        self.navigationController?.pushViewController(vc, animated: false)
        vc.delegateVoiceResult = { [weak self] text in
            let vc = SearchAllViewController()
            vc.voiceResultText = text
            self?.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    // MARK: 点击路线
    @IBAction func clickLineChangeAction() {
        XXT_BusTranferSingleton.This.haveGetMyLocation = false
        XXT_BusTranferSingleton.This.startName = AppConfig.TransferStartHint
        XXT_BusTranferSingleton.This.ternimalName = AppConfig.TransferTerminalHint
        
        let vc = TransferLineController()
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    // MARK: 点击展开结果
    @IBAction func clickCheckMoreStations() {
        guard nearStationModelArr.isEmpty == false else {return}
        
        executeMapZoomTopAction()
        ryHomeSegmentView.isHidden = true
        locationBtn.isHidden = true
        lineChangeBtn.isHidden = true
        ryHomeRightCategoryView.isHidden = true
        ryHomeCommonVehicleView.isHidden = true
        let listView = RyHomeStationListView.view()
        listView?.updateAdapterWithArr(nearStationModelArr)
        listView?.show(superView: self.view)
        listView?.dismissBlock = { [weak self] in
            self?.executeMapZoomCenterAction()
            self?.ryHomeSegmentView.isHidden = false
            self?.locationBtn.isHidden = false
            self?.lineChangeBtn.isHidden = false
            self?.ryHomeRightCategoryView.isHidden = false
            self?.ryHomeCommonVehicleView.isHidden = false
        }
        
        listView?.clickStationBlock = { [weak self] model in
            if model.mtype == .busStation {
                let vc = StationBusListController()
                vc.transmitStationName = model.name
                vc.transmitStationId = model.sid
                vc.trnsmitRouteNum = Int32(model.linec)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                let lmodel = SearchGdRespModel()
                lmodel.name = model.name
                lmodel.location = "\(model.location?.coordinate.longitude ?? 0),\(model.location?.coordinate.latitude ?? 0)"
                lmodel.address = model.desc
                let vc = LocationPlaceViewController()
                vc.locationModel = lmodel
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: 点击站点
    func clickStationAnnotationAction(_ model: RyHomeNearStationModel?) {
        guard let dmodel = model else {return}
        
        lineListView?.updateWithModel(model: dmodel)
        ryHomeStationDetailView.updateWithModel(dmodel)
        ryHomeStationDetailView.isHidden = false
        bottomViewHeightConstant.constant = 68
        ryHomeCommonVehicleView.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.ryHomeBottomDetailView.layoutIfNeeded()
        }
    }
    
    // MARK: 取消点击站点
    func unClickStationAnnotationAction() {
        ryHomeStationDetailView.isHidden = true
        bottomViewHeightConstant.constant = 36
        ryHomeCommonVehicleView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.ryHomeBottomDetailView.layoutIfNeeded()
        }
    }
    
    // MARK: ryHomeStationDetailView添加手势
    func addStationDetailTapGesture() {
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            
            if let sview = self?.view {
                self?.lineListView?.show(superView: sview)
                self?.ryHomeSegmentView.isHidden = true
                self?.ryHomeRightCategoryView.isHidden = true
                self?.executeMapZoomTopAction()
                self?.lineListView?.dismissBlock = { [weak self] in
                    self?.executeMapZoomCenterAction()
                    self?.ryHomeSegmentView.isHidden = false
                    self?.ryHomeRightCategoryView.isHidden = false
                }
            }
        }).addDisposableTo(disposeBag)
        ryHomeStationDetailView.addGestureRecognizer(tap)
    }
    
    func addStationDetailPanGesture() {
        let pan = UIPanGestureRecognizer()
        pan.rx.event.subscribe(onNext: { [weak self] (recognizer: UIPanGestureRecognizer) in
            guard let wself = self else {return}
            
            wself.lineListView?.isHidden = false
            if recognizer.state == .began || recognizer.state == .changed {
                let movement = recognizer.translation(in: wself.view)
                guard let orect = wself.lineListView?.frame else {return}
                guard let listView = wself.lineListView else {return}
                var old_rect = orect
                let listViewEmptyHeight = listView.getEmptyHeight()
                let stationDetailHeight: CGFloat = 68.0
                if recognizer.state == .began {
                    old_rect.origin.y = old_rect.origin.y - listViewEmptyHeight - stationDetailHeight
                }
                else {
                    old_rect.origin.y = old_rect.origin.y + movement.y
                }
                if old_rect.origin.y < 0 {
                    wself.lineListView?.frame = wself.view.bounds
                }
                else if old_rect.origin.y > wself.view.bounds.height {
                    wself.lineListView?.frame = CGRect.init(x: 0, y: wself.view.bounds.height, width: wself.view.bounds.width, height: wself.view.bounds.height)
                }
                else {
                    wself.lineListView?.frame = old_rect
                }
                
                recognizer.setTranslation(CGPoint.zero, in: wself.view)
            }
            else if recognizer.state == .ended || recognizer.state == .cancelled {
                let halfPoint = wself.view.bounds.height*1/4
                guard let listView = wself.lineListView else {return}
                if listView.frame.origin.y > halfPoint {
                    listView.dismiss()
                }
                else {
                    listView.show(superView: wself.view)
                }
            }
        }).addDisposableTo(disposeBag)
        ryHomeStationDetailView.addGestureRecognizer(pan)
    }
    
    // MARK: 地图缩放范围
    func executeMapZoomTopAction() {
        guard let location = movedLocationCoordinate else {return}
        let mstatus = MAMapStatus.init(center: location, zoomLevel: zoomscal, rotationDegree: 0, cameraDegree: 0, screenAnchor: CGPoint.init(x: 0.5, y: 0.15))
        mapView.setMapStatus(mstatus, animated: true, duration: 0.2)
    }
    
    func executeMapZoomCenterAction() {
        guard let location = movedLocationCoordinate else {return}
        let mstatus = MAMapStatus.init(center: location, zoomLevel: zoomscal, rotationDegree: 0, cameraDegree: 0, screenAnchor: CGPoint.init(x: 0.5, y: 0.5))
        mapView.setMapStatus(mstatus, animated: true, duration: 0.2)

    }
    
    // MARK: - 5、网络
    // MARK: 周边地铁、水巴、公交站
    let disposeBag = DisposeBag()
    func getData() {
        ryHomeRightCategoryView.updateFilterIcon(filterType)
        
        guard let location = movedLocationCoordinate else {return}
        
        mapView.removeOverlays(mapView.overlays)
        addOverlay(location)
        mapView.removeAnnotations(subwayAnnotations)
        mapView.removeAnnotations(boatAnnotations)
        mapView.removeAnnotations(busStationAnnotations)
        subwayAnnotations.removeAll()
        boatAnnotations.removeAll()
        busStationAnnotations.removeAll()
        nearStationModelArr.removeAll()
        
        let wgsLocation = JZLocationConverter.gcj02(toWgs84: location)
        
        let symbol1 = searchSubwayData(wgsLocation)
        let symbol2 = searchBoatData(wgsLocation)
        let symbol3 = searchBusStationData(wgsLocation)
        
        var symbols:Observable<Observable<Bool>>? = nil
        if filterType == .subway {
            symbols = Observable.of(symbol1)
        }
        else if filterType == .boat {
            symbols = Observable.of(symbol2)
        }
        else if filterType == .bus {
            symbols = Observable.of(symbol3)
        }
        else if filterType == .all {
            symbols = Observable.of(symbol1, symbol2, symbol3)
        }
        symbols?.concat().retry(2).subscribe().addDisposableTo(disposeBag)
    }
    
    func searchSubwayData(_ location: CLLocationCoordinate2D) -> Observable<Bool> {
        return Observable<Bool>.create { [weak self] (observer) -> Disposable in
            let send = SubwaySendModel()
            send.latitude = location.latitude
            send.longitude = location.longitude
            send.range = 500
            SubwayNetwork.This.doTask(SubwayNetwork.CMD_getByCoord, data: send, controller: nil, success: {[weak self] (response: SubwayResponseModel?) in
                observer.onCompleted()
                self?.subWayResponseModel = nil
                guard let resp = response else {return}
                guard resp.line.count > 0 else {return}
                self?.subWayResponseModel = response
                guard resp.station.count > 0 else {return}
                guard let stations: [SubwayStationModel] = (resp.station as NSArray).jsonArray() else {return}
                
                for model in stations {
                    let annotation = RyHomeMAPointAnnotation(.subway)
                    annotation.title = model.name
                    annotation.coordinate = JZLocationConverter.wgs84(toGcj02: CLLocationCoordinate2D.init(latitude: CLLocationDegrees(model.latitude), longitude: CLLocationDegrees(model.longitude)))
                    let nearStationModel = RyHomeNearStationModel()
                    nearStationModel.name = model.name
                    nearStationModel.desc = model.lines
                    let nlocation = CLLocation.init(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                    nearStationModel.sid = "\(model.id)"
                    nearStationModel.mtype = .subway
                    if let userLocation = self?.mapView.userLocation.location {
                        nearStationModel.locationDistance = userLocation.distance(from: nlocation)
                    }
                    nearStationModel.location = nlocation
                    annotation.mStationModel = nearStationModel
                    self?.nearStationModelArr.append(nearStationModel)
                    self?.subwayAnnotations.append(annotation)
                }
                self?.mapView.addAnnotations(self?.subwayAnnotations)
                
                }, error: { [weak self] (err, msg) in
                    self?.subWayResponseModel = nil
                }, com: nil, showWait: false)

            return Disposables.create()
        }
    }
    
    func searchBoatData(_ location: CLLocationCoordinate2D) -> Observable<Bool> {
        return Observable<Bool>.create { [weak self] (observer) -> Disposable in
            let send = WaterBusSendModel()
            send.latitude = location.latitude
            send.longitude = location.longitude
            send.range = 500
            
            WaterBusNetWork.This.doArrayTask(WaterBusNetWork.CMD_getByCoord, data: send, controller: nil, success: { [weak self] (response: [ShuiBaStationModel]?) in
                observer.onCompleted()
                self?.shuibaResponseArr = nil
                guard let stations = response else {return}
                guard stations.count > 0 else {return}
                self?.shuibaResponseArr = stations
                
                for model in stations {
                    let annotation = RyHomeMAPointAnnotation(.boat)
                    annotation.title = model.n
                    annotation.coordinate = JZLocationConverter.wgs84(toGcj02: CLLocationCoordinate2D.init(latitude: CLLocationDegrees(model.la), longitude: CLLocationDegrees(model.lo)))
                    let nearStationModel = RyHomeNearStationModel()
                    nearStationModel.name = model.n
                    nearStationModel.desc = "途径\(model.rcount ?? "0")条线路"
                    let nlocation = CLLocation.init(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                    nearStationModel.sid = model.i
                    nearStationModel.mtype = .boat
                    if let userLocation = self?.mapView.userLocation.location {
                        nearStationModel.locationDistance = userLocation.distance(from: nlocation)
                    }
                    nearStationModel.location = nlocation
                    annotation.mStationModel = nearStationModel
                    self?.nearStationModelArr.append(nearStationModel)
                    self?.boatAnnotations.append(annotation)
                }
                self?.mapView.addAnnotations(self?.boatAnnotations)

                }, error: nil, com: nil, showWait: false)

            return Disposables.create()
        }
    }
    
    func searchBusStationData(_ location: CLLocationCoordinate2D) -> Observable<Bool> {
        return Observable<Bool>.create { [weak self] (observer) -> Disposable in
            let send = SendGetFullStationByCoord()
            send.latitude = location.latitude
            send.longitude = location.longitude
            send.range = 500
            send.withLCheck = true
            BusNetWork.This.doArrayTask(BusNetWork.CMD_getByCoord, data: send, controller: self, success: { (responseObj:[GetFullStationByCoord]?) in
                observer.onCompleted()
                guard let stations = responseObj else {return}
                guard stations.count > 0 else {return}
                
                for model in stations {
                    let annotation = RyHomeMAPointAnnotation(.busStation)
                    annotation.title = model.n
                    annotation.coordinate = JZLocationConverter.wgs84(toGcj02: CLLocationCoordinate2D.init(latitude: CLLocationDegrees(model.la), longitude: CLLocationDegrees(model.lo)))
                    let nearStationModel = RyHomeNearStationModel()
                    nearStationModel.name = model.n
                    nearStationModel.desc = "途径\(model.c)条线路"
                    let nlocation = CLLocation.init(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                    nearStationModel.sid = model.i
                    nearStationModel.mtype = .busStation
                    nearStationModel.linec = Int(model.c)
                    if let userLocation = self?.mapView.userLocation.location {
                        nearStationModel.locationDistance = userLocation.distance(from: nlocation)
                    }
                    nearStationModel.location = nlocation
                    annotation.mStationModel = nearStationModel
                    self?.nearStationModelArr.append(nearStationModel)
                    self?.busStationAnnotations.append(annotation)
                }
                self?.mapView.addAnnotations(self?.busStationAnnotations)
                
            }, error: nil, com: nil, showWait: false)

            return Disposables.create()
        }

    }
    
    // MARK: 获取后台h5配置
    func getConfigH5Urls() -> Observable<Bool> {
        return Observable<Bool>.create {(observer) -> Disposable in
            AdvertiseNetWork.This.doArrayTask(AdvertiseNetWork.CMD_getUrl, data: BaseModel(), controller: nil, success: { (responseObj:[UrlListInfo]?) in
                observer.onCompleted()
                
                let listInfo:[UrlListInfo] = responseObj!
                if listInfo.count != 0 {
                    let h5ConfigModel = RyH5ConfigModel()
                    for i in 0...(listInfo.count - 1) {
                        if listInfo[i].name == "p.goodreputation" {
                            h5ConfigModel.goodreputation = listInfo[i].url
                        }
                        if listInfo[i].name == "yhq.sharetxt" {
                            AuthManager.This.shareTxt = listInfo[i].url
                            h5ConfigModel.sharetxt = listInfo[i].url
                        }
                        
                        if listInfo[i].name == "h5.yct" {
                            h5ConfigModel.yct = listInfo[i].url
                            
                        }
                        if listInfo[i].name == "h5.subway" {
                            AuthManager.This.subwayUrl = listInfo[i].url
                            h5ConfigModel.subway = listInfo[i].url
                        }
                        if listInfo[i].name == "h5.info" {
                            h5ConfigModel.info = listInfo[i].url
                        }
                        if listInfo[i].name == "h5.feedback" {
                            h5ConfigModel.feedback = listInfo[i].url
                        }
                        if listInfo[i].name == "h5.kepiao" {
                            AuthManager.This.mTicket = listInfo[i].url
                            h5ConfigModel.kepiao = listInfo[i].url
                        }
                        if listInfo[i].name == "h5.sytk" {
                            AuthManager.This.AgreementUrl = listInfo[i].url
                            h5ConfigModel.sytk = listInfo[i].url
                        }
                        if listInfo[i].name == "h5.share" {
                            AuthManager.This.ShareUrl = listInfo[i].url
                            h5ConfigModel.share = listInfo[i].url
                        }
                        if listInfo[i].name == "h5.jianpai" {
                            h5ConfigModel.jianpai = listInfo[i].url
                        }
                        if listInfo[i].name == "h5.yaoyiyao" {
                            AuthManager.This.yaoyiyaoUrl = listInfo[i].url
                            h5ConfigModel.yaoyiyao = listInfo[i].url
                        }
                        if listInfo[i].name == "h5.cxd" {
                            AuthManager.This.cxdUrl = listInfo[i].url
                            h5ConfigModel.cxd = listInfo[i].url
                        }
                        if listInfo[i].name == "h5.redbag" {
                            h5ConfigModel.redbag = listInfo[i].url
                        }
                        if listInfo[i].name == "h5.jianpai_share" {
                            AuthManager.This.mJianpai = listInfo[i].url
                            h5ConfigModel.jianpai_share = listInfo[i].url
                        }
                    }
                    AuthManager.This.ryH5ConfigModel = h5ConfigModel
                }
                
            }, error: nil, com: nil, showWait: false)
            
            return Disposables.create()
        }
    }
    
    // MARK: 获取地铁线路数据
    func getSubwayLineData(_ lid: Int) {
        let send = SearchSubwayLineSendModel()
        send.lid = lid
        SearchAllNetwork.This.doTask(SearchAllNetwork.CMD_getByLid, data: send, controller: self, success: { [weak self] (response: SubwayLineModel?) in
            if let resp = response {
                let respmodel = SubwayResponseModel()
                respmodel.line = [resp.toDictionary()]
                let vc = SubwayViewController()
                vc.responseModel = respmodel
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            }, error: nil, com: nil, showWait: true)
    }

    // MARK: - 6、其他
    deinit {
        if let appIdx = self.getClassName().range(of: Tools.BundleName)?.upperBound {
            Log.i("销毁页面"+self.getClassName().substring(from: appIdx))
        }
    }

}

public enum RyHomeFilterCategoryStationType {
    case all, bus, subway, boat
}

public enum RyHomeAnnotationType {
    case subway, boat, busStation, userLocation
}

class RyHomeMAPointAnnotation: MAPointAnnotation {
    
    var mStationModel: RyHomeNearStationModel?
    
    init(_ type: RyHomeAnnotationType) {
        self.mType = type
    }
    
    var mType: RyHomeAnnotationType = .busStation
}

class RyHomeMAAnnotationView: MAAnnotationView {
    var mType: RyHomeAnnotationType = .busStation
    
    var mStationModel: RyHomeNearStationModel?

    
    var iskSelected = false
    
    func updateImg() {
        if isSelected == false {
            self.image = mType == .subway ? #imageLiteral(resourceName: "rynew_ic_metro") : mType == .boat ? #imageLiteral(resourceName: "rynew_ic_mt") : mType == .busStation ? #imageLiteral(resourceName: "rynew_ic_busstop") : nil
        }
        else {
            self.image = mType == .subway ? #imageLiteral(resourceName: "rynew_ic_metro_selected") : mType == .boat ? #imageLiteral(resourceName: "rynew_ic_mt_selected") : mType == .busStation ? #imageLiteral(resourceName: "rynew_ic_busstop_selected") : nil
        }
    }
}

class RyUserMAPointAnnotation: MAPointAnnotation {
}
