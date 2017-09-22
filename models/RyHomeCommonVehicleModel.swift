//
//  RyHomeCommonVehicleModel.swift
//  renttravel
//
//  Created by jackyshan on 2017/9/18.
//  Copyright © 2017年 GCI. All rights reserved.
//

import UIKit

class RyHomeCommonVehicleModel: BaseModel {

}

class RyHomeRouteHotResponseModel: BaseModel {
    var routeid: String?
    var routename: String?
    var direction: String?
    var dname: String?
}

class RyHomeNearStationSendModel: BaseModel {
    var routeId: String?
    var direction: String?
    var longitude: Double = 0
    var latitude: Double = 0
}

class RyHomeNearStationResponseModel: BaseModel {
    var i: String?
    var lng: String?
    var lat: Double = 0
    var n: String?
    var distance: String?
}

class RyHomeWaitTimeSendModel: BaseModel {
    var routeStationId: String?
    var num: Int = 0
}

class RyHomeWaitTimeResponseModel: BaseModel {
    var id: String?
    var list: [[String: Any]]?
}
