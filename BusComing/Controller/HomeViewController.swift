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

class HomeViewController: UIViewController, UITableViewDelegate, AMapLocationManagerDelegate, AMapSearchDelegate {

    var netHelper: NetHelper?
    var timer:Timer!
    var dataArray = [buslineInfo]()
    lazy var locationManager = AMapLocationManager()
    var reGoecodeSearch = AMapSearchAPI()
    var selectedBusLine: String = "6"
    
    @IBOutlet weak var myLocationLbl: UILabel!
    
    func configLocationManager() {
        
        reGoecodeSearch?.delegate = self
        
        locationManager.delegate = self
        
        locationManager.pausesLocationUpdatesAutomatically = false
        
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    //MARK: - AMapLocationManagerDelegate
    func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error!) {
        let error = error as NSError
        NSLog("didFailWithError:{\(error.code) - \(error.localizedDescription)};")
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode?) {

        let coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        searchReGeocodeWithCoordinate(coordinate: coordinate)
    }
    
    // 发起逆地理编码请求
    func searchReGeocodeWithCoordinate(coordinate: CLLocationCoordinate2D!) {
        let regeo: AMapReGeocodeSearchRequest = AMapReGeocodeSearchRequest()
        regeo.location = AMapGeoPoint.location(withLatitude: CGFloat(coordinate.latitude), longitude: CGFloat(coordinate.longitude))
        self.reGoecodeSearch!.aMapReGoecodeSearch(regeo)
    }
    
    //MARK:- AMapSearchDelegate
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        print("request :\(request), error: \(error)")
    }
    
    // 逆地理查询回调
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest, response: AMapReGeocodeSearchResponse) {
        
        if (response.regeocode != nil) {
            //let a = response.regeocode.addressComponent.province
            //解析response获取地址描述
            self.myLocationLbl.text = response.regeocode.formattedAddress
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configLocationManager()
        
        netHelper = NetHelper()
        
        // 启用计时器，控制每5秒执行一次tickDown方法
        timer = Timer.scheduledTimer(timeInterval: 5, target:self, selector:#selector(getBusGpsInfo), userInfo:nil,repeats:true)
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // segue with value
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let vc = segue.destination
        switch vc {
        case is RouteDatilesViewControl:
            (vc as! RouteDatilesViewControl).myTitle = self.selectedBusLine + "号线"
            break;
        default:
            break;
        }
        
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
