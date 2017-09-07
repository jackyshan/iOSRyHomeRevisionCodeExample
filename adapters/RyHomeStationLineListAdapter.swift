//
//  RyHomeStationLineListAdapter.swift
//  renttravel
//
//  Created by jackyshan on 2017/9/4.
//  Copyright © 2017年 GCI. All rights reserved.
//

import UIKit

class RyHomeStationLineListAdapter: GciBaseTableViewAdapter<RyHomeStationLineModel> {
    override func onCreate() {
        self.cellHeight = 60
    }
    
    override func gciTableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, bingData: RyHomeStationLineModel) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "RyHomeStationLineListTableViewCell") as? RyHomeStationLineListTableViewCell
        
        if cell == nil {
            cell = RyHomeStationLineListTableViewCell.view()
        }
        
        cell?.updateWithModel(model: bingData)
        
        return cell!
    }
}
