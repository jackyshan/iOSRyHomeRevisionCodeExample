//
//  RySubwayLineListModel.swift
//  renttravel
//
//  Created by jackyshan on 2017/9/15.
//  Copyright © 2017年 GCI. All rights reserved.
//

import UIKit

class RySubwayLineListSendModel: BaseModel {
    var sid: Int = 0
    var sname: String?
    var latitude: Double = 0
    var longitude: Double = 0
}

class RySubwayLineListRespModel: BaseModel {
    var lines: [RySubwayLineListRespModel]?
}

class RySubwayLineListDetailRespModel: BaseModel {
    var lid: String?
    var lname: String?
    var sname: String?
    var ename: String?
}
