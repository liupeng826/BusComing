//
//  Route.swift
//  BusComing
//
//  Created by Peng Liu on 16-10-29.
//  Copyright (c) 2016 LiuPeng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetHelper: NSObject, NSCoding {
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(startTime, forKey: "startTime")
        aCoder.encode(endTime, forKey: "endTime")
        aCoder.encode(locations, forKey: "locations")
    }
    
    let REQUEST_URL: String = "http://180.76.169.196:8000/api/coordinate"
    var deviceImei: String = ""

    let minSpeed = 5.0 //最小速度 m/s
    var minDistanceFilter = 20.0 //设定定位的最小更新距离 m
    let minInteval = 5.0 //最小时间间隔 s
    
    var startTime: NSDate
    var endTime: NSDate
    var locations: Array<CLLocation>
    var postLocations: Array<CLLocation>
    
    override init() {
        
        startTime = NSDate()
        endTime = startTime
        locations = Array()
        deviceImei = DeviceHelper.deviceIdfa()!
        postLocations = Array()
        
    }
    
    deinit {
//        println("deinit")
    }
    
    /// NSCoding

    required init?(coder aDecoder: NSCoder) {
        startTime = aDecoder.decodeObject(forKey: "startTime") as! NSDate
        endTime = aDecoder.decodeObject(forKey: "endTime") as! NSDate
        locations = aDecoder.decodeObject(forKey: "locations") as! Array
        postLocations = aDecoder.decodeObject(forKey: "postLocations") as! Array
    }
    
    func postLocation(location: CLLocation?, roleId: Int, stationId: Int) -> Bool {
        
        if location == nil {
            return false
        }
        
        let lastLocation: CLLocation? = postLocations.last
        
        if lastLocation != nil {
            
            let distance: CLLocationDistance = lastLocation!.distance(from: location!)
            let duration = location!.timestamp.timeIntervalSince((lastLocation!.timestamp) as Date)
            
            if !(duration >= minInteval || (location?.speed)! >= minSpeed || distance >= minDistanceFilter) {
                return false
            }
        }
        
        if postLocations.count > 1 {
            postLocations.remove(at: 0)
        }
        
        postLocations.append(location!)
        // post location into database
        putData(coordinate: location!.coordinate, roleId: roleId, stationId: stationId)
        
        return true
    }
    
    func putData(coordinate: CLLocationCoordinate2D?, roleId: Int, stationId: Int) -> Void {
//            if ( [UIApplication sharedApplication].applicationState == UIApplicationStateActive )
//            {
//                //TODO HTTP upload
//        
//                endBackgroundUpdateTask()
//            }
//            else//后台定位
//            {
//                //假如上一次的上传操作尚未结束 则直接return
//                if ( self.taskIdentifier != UIBackgroundTaskInvalid )
//                {
//                    return
//                }
//        
//                beingBackgroundUpdateTask()
//                
//                //TODO HTTP upload
//                //上传完成记得调用 endBackgroundUpdateTask
//            }
        let parameters:[String : Any]
        
        if stationId > 0 {
            parameters = [
            "uuid": deviceImei,
            "roleId": roleId,
            "stationId": stationId,
            "lat": String(describing: coordinate!.latitude),
            "lng": String(describing: coordinate!.longitude)
            ]
        }else{
        parameters = [
            "uuid": deviceImei,
            "roleId": roleId,
            "lat": String(describing: coordinate!.latitude),
            "lng": String(describing: coordinate!.longitude)
        ]
        }
        
        Alamofire.request(REQUEST_URL, method: .post, parameters: parameters,
                          encoding: JSONEncoding.default).responseJSON {
                            (response)   in
                            
                            if let Error = response.result.error
                            {
                                print(Error)  //请求失败
                                
                            }
                            else {
                                //endBackgroundUpdateTask()
                                debugPrint("post success",  self.timeStampToString())
                            }
        }
    }
    
    
    func timeStampToString()->String {
        
        //获取当前时间
        let now = NSDate()
        
        // 创建一个日期格式器
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        return ("当前日期时间：\(dformatter.string(from: now as Date))")
    }
    
    
    
}
