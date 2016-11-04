//
//  MainViewController.swift
//  BusComing
//
//  Created by Peng Liu on 16-10-29.
//  Copyright (c) 2016 LiuPeng. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// model
class itemsModel: NSObject {
    var user = ""
    var lat  = ""
    var lng = ""
    var createdTime = ""
    var updateTime = ""
}

class MainViewController: UIViewController, MAMapViewDelegate {
    
    var timer:Timer!
    var mapView: MAMapView!
    var isRecording: Bool = false
    var locationButton: UIButton!
    var searchButton: UIButton!
    var imageLocated: UIImage!
    var imageNotLocate: UIImage!
    var statusView: StatusView!
    var currentRoute: Route?
//    var deviceImei : String = ""
//    let REQUEST_URL : String = "http://180.76.169.196:8000/api/coordinate"
    var dataArray = [itemsModel]()
    var lastAnnotations: Array<MAPointAnnotation>!
    var annotations: Array<MAPointAnnotation>!
    
//    let minSpeed = 5.0 //最小速度 m/s
//    var minDistanceFilter = 20.0 //设定定位的最小更新距离 m
//    let minInteval = 5.0 //最小时间间隔 s
    let locationManager = CLLocationManager()

    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.edgesForExtendedLayout = UIRectEdge.bottom
        
        currentRoute = Route()
        
        initLocation()
        //initToolBar()
        initMapView()
        initStatusView()
        
        // 启用计时器，控制每5秒执行一次tickDown方法
        timer = Timer.scheduledTimer(timeInterval: 5, target:self, selector:#selector(MainViewController.getData),
                                     userInfo:nil,repeats:true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    //MARK:- Initialization
    
    func initToolBar() {
        
        // start button
        let leftButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_play.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MainViewController.actionRecordAndStop))
        
        navigationItem.leftBarButtonItem = leftButtonItem
        
        // history button
        let rightButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_list.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MainViewController.actionHistory))
        
        navigationItem.rightBarButtonItem = rightButtonItem
        
        
    }
    
    func initLocation() {
//        if #available(iOS 8.0, *) {
//            locationManager.requestAlwaysAuthorization()
//        }
//        //这是iOS9中针对后台定位推出的新属性 不设置的话 可是会出现顶部蓝条的哦(类似热点连接)
//        if #available(iOS 9.0, *) {
//            locationManager.allowsBackgroundLocationUpdates = true
//        }
//        locationManager.startMonitoringSignificantLocationChanges()
//        
        imageLocated = UIImage(named: "location_yes.png")
        imageNotLocate = UIImage(named: "location_no.png")
        
        locationButton = UIButton(frame: CGRect(x: 20, y: view.bounds.height - 80, width: 40, height: 40))
        
        locationButton!.autoresizingMask = [UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin]
        locationButton!.backgroundColor = UIColor.white
        locationButton!.layer.cornerRadius = 5
        locationButton!.layer.shadowColor = UIColor.black.cgColor
        locationButton!.layer.shadowOffset = CGSize(width: 5, height: 5)
        locationButton!.layer.shadowRadius = 5
        
        locationButton!.addTarget(self, action: #selector(MainViewController.actionLocation(sender:)), for: UIControlEvents.touchUpInside)
        
        locationButton!.setImage(imageLocated, for: UIControlState.normal)
        
        view.addSubview(locationButton!)
    }
    
    func initMapView() {
        
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        self.view.addSubview(mapView)
        self.view.sendSubview(toBack: mapView)
        
        // 是否允许降帧，默认为YES
        mapView.isAllowDecreaseFrame = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = MAUserTrackingMode.follow
        mapView.pausesLocationUpdatesAutomatically = false
        mapView.allowsBackgroundLocationUpdates = true
        // 设定定位的最小更新距离
        mapView.distanceFilter = (currentRoute?.minDistanceFilter)!
        mapView.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    func initStatusView() {
        statusView = StatusView(frame: CGRect(x: 5, y: 35, width: 150, height: 150))
        
        statusView!.showStatusInfo(info: nil)
        
        view.addSubview(statusView!)
        
    }
    
    //MARK:- Actions
    
    func stopLocationIfNeeded() {
        if !isRecording {
            print("stop location")
            mapView!.setUserTrackingMode(MAUserTrackingMode.none, animated: false)
            mapView!.showsUserLocation = false
        }
    }
    
    func actionHistory() {
        print("actionHistory")
        
        let historyController = RecordViewController(nibName: nil, bundle: nil)
        historyController.title = "Records"
        
        navigationController!.pushViewController(historyController, animated: true)
    }
    
    func actionRecordAndStop() {
        print("actionRecord")
        
        isRecording = !isRecording
        
        if isRecording {
            
            navigationItem.leftBarButtonItem!.image = UIImage(named: "icon_stop.png")
            
            if currentRoute == nil {
                currentRoute = Route()
            }
            
            addLocation(location: mapView!.userLocation.location)
        }
        else {
            navigationItem.leftBarButtonItem!.image = UIImage(named: "icon_play.png")
            
            addLocation(location: mapView!.userLocation.location)
            // save posation information
            saveRoute()
        }
        
    }
    
    func actionLocation(sender: UIButton) {
        print("click Location button")
        mapView!.setUserTrackingMode(MAUserTrackingMode.follow, animated: true)
    }
    
    func actionSearch(sender: UIButton) {
        
        let searchDemoController = SearchViewController(nibName: nil, bundle: nil)
        navigationController!.pushViewController(searchDemoController, animated: true)
    }
    
    //MARK:- Helpers
    
    func addLocation(location: CLLocation?) {
        let success = currentRoute!.addLocation(location: location)
        if success {
            print("locations: \(currentRoute!.locations.count)")
        }
    }
    
    func postLocation(location: CLLocation?) {
        _ = currentRoute!.postLocation(location: location)
    }
    
    func saveRoute() {
        
        if currentRoute == nil {
            return
        }
        
        let name = currentRoute!.title()
        
        let path = FileHelper.recordPathWithName(name: name)
        
        NSKeyedArchiver.archiveRootObject(currentRoute!, toFile: path!)
        
        currentRoute = nil
    }
    
    func addAnnotationWithCooordinate(coordinates: Array<CLLocationCoordinate2D>!) {
        // 删除上次点标注
        mapView.removeAnnotations(lastAnnotations)
        
        annotations = Array()
        lastAnnotations = Array()
        
        for (idx, coor) in coordinates.enumerated() {
            let anno = MAPointAnnotation()
            anno.coordinate = coor
            anno.title = String(idx)
            
            annotations.append(anno)
        }
        
        lastAnnotations = annotations
        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, edgePadding: UIEdgeInsetsMake(20, 20, 20, 20), animated: true)
        mapView.selectAnnotation(annotations.first, animated: true)

    }

    //MARK:- MAMapViewDelegate
    
    func mapView(_ mapView: MAMapView , didUpdate userLocation: MAUserLocation, updatingLocation: Bool) {
        
        if isRecording {
            // filter the result
            if userLocation.location.horizontalAccuracy < 80.0 {
                
                addLocation(location: userLocation.location)
            }
        }
        
        let location: CLLocation? = userLocation.location
        
        if location == nil {
            return
        }
        
        var speed = location!.speed
        if speed < 0.0 {
            speed = 0.0
        }
        
        let infoArray: [(String, String)] = [
            ("coordinate", NSString(format: "<%.4f, %.4f>", location!.coordinate.latitude, location!.coordinate.longitude) as String),
            ("speed", NSString(format: "%.2fm/s(%.2fkm/h)", speed, speed * 3.6) as String),
            ("accuracy", "\(location!.horizontalAccuracy)m"),
            ("altitude", NSString(format: "%.2fm", location!.altitude) as String)]
        
        statusView!.showStatusInfo(info: infoArray)
        
        adjustDistanceFilter(location: location!)
        
        // post data
        if userLocation.location.horizontalAccuracy < 80.0 {
            _ = currentRoute!.postLocation(location: location!)
        }
        
    }
    
    func mapView(_ mapView: MAMapView, didChange mode: MAUserTrackingMode, animated: Bool) {
        if mode == MAUserTrackingMode.none {
            locationButton?.setImage(imageNotLocate, for: UIControlState.normal)
        }
        else {
            locationButton?.setImage(imageLocated, for: UIControlState.normal)
        }
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as! MAPinAnnotationView?
            
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView!.canShowCallout = false
            annotationView!.animatesDrop = true
            annotationView!.isDraggable = true
            annotationView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure)
            
            var idx = annotations.index(of: annotation as! MAPointAnnotation)
            if idx == nil {
                idx = 1
            }
            annotationView!.pinColor = MAPinAnnotationColor(rawValue: idx!)!
            
            return annotationView!
        }
        
        return nil
    }
    
//    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
//        
//        if annotation is MAPointAnnotation {
//            let customReuseIndetifier: String = "customReuseIndetifier"
//            
//            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: customReuseIndetifier) as? CustomAnnotationView
//            
//            if annotationView == nil {
//                annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: customReuseIndetifier)
//                
//                annotationView?.canShowCallout = false
//                annotationView?.isDraggable = true
//                annotationView?.calloutOffset = CGPoint.init(x: 0, y: -5)
//            }
//            
//            annotationView?.portrait = UIImage.init(named: "bus.png")
//            annotationView?.name = "班车"
//            
//            return annotationView
//        }
//        
//        return nil
//    }
    

    /**
     *  规则: 如果速度小于minSpeed m/s 则把触发范围设定为50m
     *  否则将触发范围设定为minSpeed*minInteval
     *  此时若速度变化超过10% 则更新当前的触发范围(这里限制是因为不能不停的设置distanceFilter,否则uploadLocation会不停被触发)
     */
    func adjustDistanceFilter(location: CLLocation) -> Void
    {
        //print("adjust:",location.speed)
        
        if location.speed < (currentRoute?.minSpeed)! {
            if ( fabs(mapView.distanceFilter - (currentRoute?.minDistanceFilter)!) > 0.1)
            {
                mapView.distanceFilter = (currentRoute?.minDistanceFilter)!
            }
        }
        else
        {
            let lastSpeed = mapView.distanceFilter/(currentRoute?.minInteval)!;
            
            if ( (fabs(lastSpeed - location.speed)/lastSpeed > 0.1) || (lastSpeed < 0) )
            {
                let newSpeed  = location.speed+0.5
                let newFilter = newSpeed * (currentRoute?.minInteval)!
                mapView.distanceFilter = newFilter;
            }
        }
    }

    
    /**
     *计时器每秒触发事件
     **/
    func getData() -> [itemsModel] {
        self.dataArray = [itemsModel]()
        
        Alamofire.request(currentRoute!.REQUEST_URL + "?role=BUS").responseJSON {
            (response)   in
            
            if let Error = response.result.error
            {
                print(Error)  //请求失败
            }
            else if let jsonresult = response.result.value {
                
                let JSOnDictory = JSON(jsonresult) //请求成功
                let data =  JSOnDictory["data"].array
                var busCoordinates: Array<CLLocationCoordinate2D>! = Array()
                
                for dataDic in data!
                {
                    let model =  itemsModel()
                    
                    model.user = dataDic["user"].string ?? ""
                    model.lat =  dataDic["lat"].string ?? ""
                    model.lng =  dataDic["lng"].string ?? ""
                    model.createdTime =  dataDic["createdTime"].string ?? ""
                    model.updateTime =  dataDic["updateTime"].string ?? ""
                    
                    self.dataArray.append(model)
                    
                    if self.currentRoute!.deviceImei != model.user {
                        busCoordinates.append(CLLocationCoordinate2D(latitude: Double(model.lat)!, longitude: Double(model.lng)!))
                    }
                }
                
                self.addAnnotationWithCooordinate(coordinates: busCoordinates)
                debugPrint("get success", self.currentRoute!.timeStampToString())
            }
        }
        return dataArray
    }
    

    
    
    
}
