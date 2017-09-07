//
//  RyHomeStationListAdapter.swift
//  renttravel
//
//  Created by jackyshan on 2017/9/2.
//  Copyright © 2017年 GCI. All rights reserved.
//

import UIKit

class RyHomeStationListAdapter: GciBaseTableViewAdapter<RyHomeNearStationModel> {
    override func onCreate() {
        self.cellHeight = 60
    }
    
    override func gciTableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, bingData: RyHomeNearStationModel) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "RyHomeStationTableViewCell") as? RyHomeStationTableViewCell
        
        if cell == nil {
            cell = RyHomeStationTableViewCell.view()
        }
        
        cell?.updateWithModel(model: bingData)
        
        return cell!
    }

}
