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

// model
//class itemsModel: NSObject {
//    var user = ""
//    var lat  = ""
//    var lng = ""
//    var createdTime = ""
//    var updateTime = ""
//}

class Route: NSObject, NSCoding {
    
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
    var postLocation: CLLocation
    
    override init() {
        
        startTime = NSDate()
        endTime = startTime
        locations = Array()
        deviceImei = DeviceHelper.deviceIdfa()!
        postLocation = CLLocation()
    }
    
    deinit {
//        println("deinit")
    }
    
    /// NSCoding

    required init?(coder aDecoder: NSCoder) {
        startTime = aDecoder.decodeObject(forKey: "startTime") as! NSDate
        endTime = aDecoder.decodeObject(forKey: "endTime") as! NSDate
        locations = aDecoder.decodeObject(forKey: "locations") as! Array
        postLocation = aDecoder.decodeObject(forKey: "postLocation") as! CLLocation
    }
    
    /// Interface
    
    func addLocation(location: CLLocation?) -> Bool {
        
        if location == nil {
            return false
        }
        
        let lastLocation: CLLocation? = locations.last
        
        if lastLocation != nil {
            
            let distance: CLLocationDistance = lastLocation!.distance(from: location!)
            
            if distance < minDistanceFilter {
                return false
            }
        }

        locations.append(location!)
        
        endTime = NSDate()
        
        return true
    }
    
    func postLocation(location: CLLocation?) -> Bool {
        
        if location == nil {
            return false
        }
        
        let lastLocation: CLLocation? = postLocation
        
        if lastLocation != nil {
            
            let distance: CLLocationDistance = lastLocation!.distance(from: location!)
            let duration = location!.timestamp.timeIntervalSince((lastLocation!.timestamp) as Date)
            
            if !(duration >= minInteval || (location?.speed)! >= minSpeed || distance >= minDistanceFilter) {
                return false
            }
        }
        
        postLocation = location!
        // post location into database
        putData(coordinate: location!.coordinate)
        
        return true
    }
    
    func title() -> String! {
        
        let formatter: DateFormatter = DateFormatter()
        formatter.timeZone = NSTimeZone.local
        formatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
        
        return formatter.string(from: self.startTime as Date)
    }
    
    func detail() -> String! {
        return NSString(format: "point: %d, distance: %.2fm, duration: %@", locations.count, totalDistance(), formattedDuration(duration: totalDuration())) as String
    }
    
    func startLocation() -> CLLocation? {
        return locations.first
    }
    
    func endLocation() -> CLLocation? {
        return locations.last
    }
    
    func totalDistance() -> CLLocationDistance {
        
        var distance: CLLocationDistance = 0
        if locations.count > 1 {
            
            var currentLocation: CLLocation? = nil
            
            for location in locations {

                if currentLocation != nil {
                    distance += location.distance(from: currentLocation!)
                }
                currentLocation = location
            }
            
        }

        return distance
    }
    
    func totalDuration() -> TimeInterval {
        
        return endTime.timeIntervalSince(startTime as Date)
    }
    
    func formattedDuration(duration: TimeInterval) -> String {

        var component: [Double] = [0, 0, 0]
        var t = duration
        
        for i in 0 ..< component.count {
            component[i] = Double(Int(t) % 60)
            t /= 60.0
        }
        
        return NSString(format: "%.0fh %.0fm %.0fs", component[2], component[1], component[0]) as String
    }
    
    func coordinates() -> [CLLocationCoordinate2D]! {
        
        var coordinates: [CLLocationCoordinate2D] = []
        if locations.count > 1 {
            
            for location: AnyObject in locations {
                
                let loc = location as! CLLocation
                
                coordinates.append(loc.coordinate)
            }
        }
        return coordinates
    }

    
    func putData(coordinate: CLLocationCoordinate2D?) -> Void {
        
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
        
        let parameters:[String : Any] = [
            "user": deviceImei,
            "lat": String(describing: coordinate!.latitude),
            "lng": String(describing: coordinate!.longitude)
        ]
        
        Alamofire.request(REQUEST_URL, method: .post, parameters: parameters,
                          encoding: JSONEncoding.default).responseJSON {
                            (response)   in
                            
                            if let Error = response.result.error
                            {
                                print(Error)  //请求失败
                                
                            }
                                //                            else if let jsonresult = response.result.value {
                                //
                                //                                //let JSOnDictory = JSON(jsonresult) //请求成功
                                //                                debugPrint("post success", NSDate().timeIntervalSince1970)
                                //                            }
                                
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
