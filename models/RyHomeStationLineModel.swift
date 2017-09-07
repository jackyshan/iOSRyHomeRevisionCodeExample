//
//  RyHomeStationLineModel.swift
//  renttravel
//
//  Created by jackyshan on 2017/9/4.
//  Copyright © 2017年 GCI. All rights reserved.
//

import UIKit

class RyHomeStationLineModel: BaseModel {
    var mtype: RyHomeFilterCategoryStationType?
    var name: String = ""
    var desc: String = ""
    var time: Int = 0
    var distance: Int = 0
    var lid: String = ""
    var isHiddenTimeDistance: Bool = false
    
}
