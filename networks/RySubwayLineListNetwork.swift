//
//  RySubwayLineListNetwork.swift
//  renttravel
//
//  Created by jackyshan on 2017/9/15.
//  Copyright © 2017年 GCI. All rights reserved.
//

import UIKit

class RySubwayLineListNetwork: BaseNetWork {
    fileprivate static var my:RySubwayLineListNetwork!
    
    static var This:RySubwayLineListNetwork{
        if my == nil {
            my = RySubwayLineListNetwork(mould: "subway")
        }
        return my
    }
    /** 获取地铁线路 */
    static let CMD_getTransferLinesBySid = "getTransferLinesBySid.do"

}
