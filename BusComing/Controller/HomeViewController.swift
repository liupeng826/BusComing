//
//  HomeViewController.swift
//  BusComing
//
//  Created by liupeng on 2017/6/23.
//  Copyright © 2017年 AutoNavi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class buslineInfo: NSObject {
    var id = 0
    var uuid = ""
    var lat  = ""
    var lng = ""
    var createdTime = ""
    var updateTime = ""
}

class HomeViewController: UIViewController, UITableViewDelegate {

    var netHelper: NetHelper?
    var timer:Timer!
    var dataArray = [buslineInfo]()
    var selectedBusLine: String = "6"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        netHelper = NetHelper()
        
        // 启用计时器，控制每5秒执行一次tickDown方法
        timer = Timer.scheduledTimer(timeInterval: 5, target:self, selector:#selector(getBusGpsInfo), userInfo:nil,repeats:true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getBusGpsInfo() -> [buslineInfo] {
        self.dataArray = [buslineInfo]()
        
        Alamofire.request(netHelper!.REQUEST_URL + "?roleId=\(selectedBusLine)").responseJSON {
            (response)   in
            if let Error = response.result.error
            {
                print(Error)  //请求失败
            }
            else if let jsonresult = response.result.value {
                //print("JSON: \(JSON(jsonresult)["data"])")
                let JSOnDictory = JSON(jsonresult) //请求成功
                let dataDic =  JSOnDictory["data"]  //返回一条数据
                
                if dataDic != JSON.null {
                    let model =  buslineInfo()
                    
                    model.uuid = dataDic["uuid"].string ?? ""
                    model.lat =  dataDic["lat"].string ?? ""
                    model.lng =  dataDic["lng"].string ?? ""
                    model.createdTime =  dataDic["createdTime"].string ?? ""
                    model.updateTime =  dataDic["updateTime"].string ?? ""
                    
                    self.dataArray.append(model)
                    

                }
            }
        }
        return dataArray
    }
    
    
}
