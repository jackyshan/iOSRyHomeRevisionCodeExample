//
//  RyHomeNearStationModel.swift
//  renttravel
//
//  Created by jackyshan on 2017/9/1.
//  Copyright © 2017年 GCI. All rights reserved.
//

import UIKit

class RyHomeNearStationModel: BaseModel {
    var name: String = ""
    var desc: String = ""
    var linec: Int = 0
    var location: CLLocation?
    var locationDistance: CLLocationDistance = 0
    var mtype: RyHomeAnnotationType?
    var sid: String = ""
    var isNearest: Bool = false
}
