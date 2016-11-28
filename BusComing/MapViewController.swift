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
    var id = 0
    var uuid = ""
    var lat  = ""
    var lng = ""
    var createdTime = ""
    var updateTime = ""
}

class MapViewController: UIViewController, MAMapViewDelegate {
    
    var timer:Timer!
    var mapView: MAMapView!
    var picker:LinePickerView?
    var isTrafficOn: Bool = false
    var isDriverOn: Bool = false
    var locationButton: UIButton!
    var driverButton: UIButton!
    var trafficButton: UIButton!
    var busLineButton: UIButton!
    var searchButton: UIButton!
    var imageLocated: UIImage!
    var imageNotLocate: UIImage!
    var imageDriver: UIImage!
    var imageNoDriver: UIImage!
    var imageTrafficOn: UIImage!
    var imageTrafficOff: UIImage!
    var statusView: StatusView!
    var netHelper: NetHelper?
    var dataArray = [itemsModel]()
    var locations: Array<CLLocation>!
    var lastAnnotations: Array<MAPointAnnotation>!
    var myLocation: MAPointAnnotation?
    //var annotations: Array<MAPointAnnotation>!
    var selectedBusLine: Int = 0
    var roleId: Int = 0
    var isPlaying: Bool = false
    var currentLocationIndex: Int = 0
    var averageSpeed: Double = 2
    let SelectedBusLineKey: String? = "SelectedBusLineKey"
    let DRIVERLINE_KEY: String? = "DRIVERLINE_KEY"
    let DRIVER_KEY: String? = "DRIVER_KEY"
    //let locationManager = CLLocationManager()
    
    var _duration:CFTimeInterval = 10.0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.edgesForExtendedLayout = UIRectEdge.bottom
        
        netHelper = NetHelper()
        
        initDriver()
        initLocation()
        initMapView()
        //initStatusView()
        initTraffic()
        initBusLine()
        initVariates()
        
        
        //initRoute()
        
        // 启用计时器，控制每5秒执行一次tickDown方法
        timer = Timer.scheduledTimer(timeInterval: 5, target:self, selector:#selector(MapViewController.getData), userInfo:nil,repeats:true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    //MARK:- Initialization
    
    func initLocation() {
        locations = Array()
        lastAnnotations = Array()
        
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
        
        locationButton = UIButton(frame: CGRect(x: 20, y: view.bounds.height - 100, width: 40, height: 40))
        
        locationButton!.autoresizingMask = [UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin]
        locationButton!.backgroundColor = UIColor.white
        locationButton!.layer.cornerRadius = 5
        locationButton!.layer.shadowColor = UIColor.black.cgColor
        locationButton!.layer.shadowOffset = CGSize(width: 5, height: 5)
        locationButton!.layer.shadowRadius = 5
        locationButton!.addTarget(self, action: #selector(MapViewController.actionLocation(sender:)), for: UIControlEvents.touchUpInside)
        locationButton!.setImage(imageLocated, for: UIControlState.normal)
        view.addSubview(locationButton!)
    }
    
    func initDriver() {
        imageDriver = UIImage(named: "driver_on.png")
        imageNoDriver = UIImage(named: "driver_off.png")
        
        driverButton = UIButton(frame: CGRect(x: 20, y: view.bounds.height - 150, width: 40, height: 40))
        
        driverButton!.autoresizingMask = [UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin]
        //driverButton!.backgroundColor = UIColor.white
        driverButton!.layer.cornerRadius = 5
        driverButton!.layer.shadowColor = UIColor.black.cgColor
        driverButton!.layer.shadowOffset = CGSize(width: 5, height: 5)
        driverButton!.layer.shadowRadius = 5
        driverButton!.addTarget(self, action: #selector(MapViewController.actionDriver(sender:)), for: UIControlEvents.touchUpInside)
        driverButton!.setImage(imageNoDriver, for: UIControlState.normal)
        view.addSubview(driverButton!)
        
        // 读取司机key
        let isDriver = getNormalDefult(key: DRIVER_KEY!) as! Bool? ?? false
        self.roleId = getNormalDefult(key: DRIVERLINE_KEY!) as! Int? ?? 0
        debugPrint("isDriver: \(isDriver), roleId: \(roleId)")
        if (isDriver){
            isDriverOn = true
            driverButton!.setImage(imageDriver, for: UIControlState.normal)
        }
    }
    
    func initMapView() {
        
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        self.view.addSubview(mapView)
        self.view.sendSubview(toBack: mapView)
        
        mapView.zoomLevel = 15.5
        
        // 设定定位的最小更新距离
        mapView.distanceFilter = 3.0
        mapView.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        mapView.showsCompass = true // 设置成NO表示关闭指南针；YES表示显示指南针
        mapView.compassOrigin = CGPoint(x: mapView.compassOrigin.x, y: 25) //设置指南针位置
        
        mapView.showsScale = false  //设置成NO表示不显示比例尺；YES表示显示比例尺
        //mapView.scaleOrigin = CGPoint(x: mapView.scaleOrigin.x, y: 25)  //设置比例尺位置
        
        // 是否允许降帧，默认为YES
        //mapView.isAllowDecreaseFrame = false
        
        let zoomPannelView = self.makeZoomPannelView()
        zoomPannelView.center = CGPoint(x: self.view.bounds.size.width -  zoomPannelView.bounds.width/2 - 10, y: self.view.bounds.size.height -  zoomPannelView.bounds.width/2 - 80)
        
        zoomPannelView.autoresizingMask = [UIViewAutoresizing.flexibleTopMargin , UIViewAutoresizing.flexibleLeftMargin]
        self.view.addSubview(zoomPannelView)
    }
    
    func startLocation()
    {
        // 开始定位
        mapView.showsUserLocation = true
        mapView.userTrackingMode = MAUserTrackingMode.follow
        mapView.pausesLocationUpdatesAutomatically = false
        mapView.allowsBackgroundLocationUpdates = true
    }
    
    func initTraffic() {
        
        imageTrafficOn = UIImage(named: "traffic_on.png")
        imageTrafficOff = UIImage(named: "traffic_off.png")
        
        trafficButton = UIButton(frame: CGRect(x: view.bounds.width - 45, y: 100, width: 40, height: 40))
        
        trafficButton!.autoresizingMask = [UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin]
        //trafficButton!.backgroundColor = UIColor.white
        trafficButton!.layer.cornerRadius = 5
        trafficButton!.layer.shadowColor = UIColor.black.cgColor
        trafficButton!.layer.shadowOffset = CGSize(width: 5, height: 5)
        trafficButton!.layer.shadowRadius = 10
        
        trafficButton!.addTarget(self, action: #selector(MapViewController.actionTraffic(sender:)), for: UIControlEvents.touchUpInside)
        
        trafficButton!.setImage(imageTrafficOff, for: UIControlState.normal)
        
        view.addSubview(trafficButton!)
    }
    
    func initBusLine() {
        
        busLineButton = UIButton(frame: CGRect(x: view.bounds.width - 45, y: 150, width: 40, height: 40))
        busLineButton!.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        selectedBusLine = getNormalDefult(key: SelectedBusLineKey!) as! Int? ?? selectedBusLine
        busLineButton.setTitle(String(describing: selectedBusLine), for: UIControlState())
        busLineButton!.autoresizingMask = [UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin]
        busLineButton!.backgroundColor = UIColor.white
        busLineButton!.layer.cornerRadius = 5
        busLineButton!.layer.shadowColor = UIColor.black.cgColor
        busLineButton!.layer.shadowOffset = CGSize(width: 5, height: 5)
        busLineButton!.layer.shadowRadius = 10
        busLineButton.setTitleColor(UIColor.orange, for: UIControlState())
        
        busLineButton!.addTarget(self, action: #selector(MapViewController.busLineButtonclick(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(busLineButton!)
    }
    
    func initVariates() {
        isPlaying = true
        currentLocationIndex = 0
        averageSpeed = 2
    }
    
    func initStatusView() {
        statusView = StatusView(frame: CGRect(x: 5, y: 35, width: 150, height: 150))
        
        statusView!.showStatusInfo(info: nil)
        
        view.addSubview(statusView!)
        
    }
    
//    func initRoute() {
//    _duration = 10.0
//    var count:Int = 14
//        
//    var coords: [CLLocationCoordinate2D]!
//    coords.append(CLLocationCoordinate2DMake(39.93563,  116.387358))
//    coords.append(CLLocationCoordinate2DMake(39.935564,   116.386414))
//    coords.append(CLLocationCoordinate2DMake(39.935646,  116.386038))
//    coords.append(CLLocationCoordinate2DMake(39.93586, 116.385791))
//    coords.append(CLLocationCoordinate2DMake(39.93586, 116.385791))
//    coords.append(CLLocationCoordinate2DMake(39.937983, 116.38474))
//    coords.append(CLLocationCoordinate2DMake(39.938616, 116.3846))
//    coords.append(CLLocationCoordinate2DMake(39.938888, 116.386971))
//    coords.append(CLLocationCoordinate2DMake(39.938855, 116.387047))
//    coords.append(CLLocationCoordinate2DMake(39.938172,  116.387132))
//    coords.append(CLLocationCoordinate2DMake(39.937604, 116.387218))
//    coords.append(CLLocationCoordinate2DMake(39.937489, 116.387132))
//    coords.append(CLLocationCoordinate2DMake(39.93614,  116.387283))
//    coords.append(CLLocationCoordinate2DMake(39.935622,  116.387347))
//    
//    showRouteForCoords(coords: coords,count:count)
//    initTrackingWithCoords(coords, count)
//    
//    if coords {
//        free(coords)
//    }
//    
//    }
    
    //MARK:- MAMapViewDelegate
    
    func mapView(_ mapView: MAMapView , didUpdate userLocation: MAUserLocation, updatingLocation: Bool) {
        
        let location: CLLocation? = userLocation.location
        
        if location == nil {
            return
        }
        
        // change status view
        //        var speed = location!.speed
        //        if speed < 0.0 {
        //            speed = 0.0
        //        }
        //
        //        let infoArray: [(String, String)] = [
        //            ("coordinate", NSString(format: "<%.4f, %.4f>", location!.coordinate.latitude, location!.coordinate.longitude) as String),
        //            ("speed", NSString(format: "%.2fm/s(%.2fkm/h)", speed, speed * 3.6) as String),
        //            ("accuracy", "\(location!.horizontalAccuracy)m"),
        //            ("altitude", NSString(format: "%.2fm", location!.altitude) as String)]
        //
        //        statusView!.showStatusInfo(info: infoArray)
        
        adjustDistanceFilter(location: location!)
    
        // post data
        if userLocation.location.horizontalAccuracy < 80.0 {
            _ = netHelper!.postLocation(location: location!, roleId: roleId)
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
        
        if annotation.isEqual(myLocation) {
            
            let annotationIdentifier = "myLcoationIdentifier"
            
            var poiAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
            if poiAnnotationView == nil {
                poiAnnotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            }
            
            poiAnnotationView?.image = UIImage.init(named: "car_driver.png")
            poiAnnotationView!.canShowCallout = false
            
            return poiAnnotationView
        }
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as! MAPinAnnotationView?
            
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            annotationView!.canShowCallout = false       //设置气泡可以弹出，默认为NO
            annotationView!.animatesDrop = false         //设置标注动画显示，默认为NO
            annotationView!.isDraggable = true           //设置标注可以拖动，默认为NO
            annotationView!.image = UIImage(named: "marker.png")
            annotationView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure)
            annotationView?.centerOffset = CGPoint(x: 0, y: -18) //设置中心点偏移，使得标注底部中间点成为经纬度对应点
            
            return annotationView!
        }
        
        return nil
    }
    
    // 划线专用
    //    func mapView(_ mapView: MAMapView, rendererFor overlay: MAOverlay) -> MAOverlayRenderer? {
    //
    //        if overlay.isKind(of: MAPolyline.self) {
    //            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: overlay)
    //            renderer.strokeColor = UIColor.red
    //            renderer.lineWidth = 6.0
    //
    //            return renderer
    //        }
    //
    //        return nil
    //    }
    
    //MARK:- Actions
    
    func actionTraffic(sender: UIButton) {
        
        isTrafficOn = !isTrafficOn
        
        if isTrafficOn {
            
            trafficButton!.setImage(imageTrafficOn, for: UIControlState.normal)
            
            mapView.isShowTraffic = true
        }
        else {
            trafficButton!.setImage(imageTrafficOff, for: UIControlState.normal)
            
            mapView.isShowTraffic = false
        }
    }
    
    func actionDriver(sender: UIButton) {
        if !isDriverOn {
            
            if selectedBusLine == 0 {
                let alertController = UIAlertController(title: "请先选择班车路线",
                                                        message: nil, preferredStyle: .alert)
                //显示提示框
                self.present(alertController, animated: true, completion: nil)
                //1秒钟后自动消失
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                }
                return
            }
            
            let alertController = UIAlertController(
                title: "老司机",
                message: "确定要为 " + String(describing: selectedBusLine) + "号线" + " 的同学指条明路吗？", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
                action in
                self.isDriverOn = false
            })
            let okAction = UIAlertAction(title: "确定", style: .default, handler: {
                action in
                self.isDriverOn = true
                self.driverButton!.setImage(self.imageDriver, for: UIControlState.normal)
                
                //存储司机线路
                self.setNormalDefault(key:self.DRIVERLINE_KEY!, value:self.selectedBusLine as AnyObject?)
                self.setNormalDefault(key:self.DRIVER_KEY!, value:true as AnyObject?)
                self.roleId = self.selectedBusLine
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            self.setNormalDefault(key:self.DRIVER_KEY!, value:false as AnyObject?)
            let alertController = UIAlertController(title: "已关闭老司机功能",
                                                    message: nil, preferredStyle: .alert)
            //显示提示框
            self.present(alertController, animated: true, completion: nil)
            //1秒钟后自动消失
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.presentedViewController?.dismiss(animated: false, completion: nil)
            }
                
            driverButton!.setImage(imageNoDriver, for: UIControlState.normal)
            isDriverOn = false
            self.setNormalDefault(key:self.DRIVERLINE_KEY!, value:0 as AnyObject?)
            self.setNormalDefault(key:self.DRIVER_KEY!, value:false as AnyObject?)
        }
    }
    
    func actionLocation(sender: UIButton) {
        print("click Location button")
        mapView!.setUserTrackingMode(MAUserTrackingMode.follow, animated: true)
    }
    
    //MARK:- Helpers
    
    func addAnnotationWithCooordinate(coordinates: Array<CLLocationCoordinate2D>!) {
        //        print("Action: addAnnotationWithCooordinate")
        //
        if locations.count <= 0 { return }
        
        // 删除上次点标注
        if locations.count == 1 {
            removeLastAnnotation()
        }
        //
        //        annotations = Array()
        //
        //        for (idx, coor) in coordinates.enumerated() {
        //            let anno = MAPointAnnotation()
        //            anno.coordinate = coor
        //            anno.title = String(idx)
        //
        //            annotations.append(anno)
        //        }
        //
        //        lastAnnotations = annotations
        //        mapView.addAnnotations(annotations)
        //        mapView.showAnnotations(annotations, edgePadding: UIEdgeInsetsMake(20, 20, 20, 20), animated: true)
        //        mapView.selectAnnotation(annotations.first, animated: true)
        getAverageSpeed()
        actionPlay()
    }
    
    /**
     *  规则: 如果速度小于minSpeed m/s 则把触发范围设定为50m
     *  否则将触发范围设定为minSpeed*minInteval
     *  此时若速度变化超过10% 则更新当前的触发范围(这里限制是因为不能不停的设置distanceFilter,否则uploadLocation会不停被触发)
     */
    func adjustDistanceFilter(location: CLLocation) -> Void
    {
        //print("adjust:",location.speed)
        
        if location.speed < (netHelper?.minSpeed)! {
            if ( fabs(mapView.distanceFilter - (netHelper?.minDistanceFilter)!) > 0.1)
            {
                mapView.distanceFilter = (netHelper?.minDistanceFilter)!
            }
        }
        else
        {
            let lastSpeed = mapView.distanceFilter/(netHelper?.minInteval)!
            
            if ( (fabs(lastSpeed - location.speed)/lastSpeed > 0.1) || (lastSpeed < 0) )
            {
                let newSpeed  = location.speed+0.5
                let newFilter = newSpeed * (netHelper?.minInteval)!
                mapView.distanceFilter = newFilter
            }
        }
    }
    
    
    /**
     *计时器每秒触发事件
     **/
    func getData() -> [itemsModel] {
        //print("Action: getData")
        self.dataArray = [itemsModel]()
        
        //print(netHelper!.REQUEST_URL + "?roleId=\(selectedBusLine)")
        if selectedBusLine == 0 {
            // 删除上次点标注
            actionStop()
            removeLastAnnotation()
            
            return dataArray
        }
        
        Alamofire.request(netHelper!.REQUEST_URL + "?roleId=\(selectedBusLine)").responseJSON {
            (response)   in
            if let Error = response.result.error
            {
                print(Error)  //请求失败
            }
            else if let jsonresult = response.result.value {
                //print("JSON: \(jsonresult)")
                let JSOnDictory = JSON(jsonresult) //请求成功
                //let dataDic =  JSOnDictory["data"].array //返回多条数据
                let dataDic =  JSOnDictory["data"]  //返回一条数据
                var busCoordinates: Array<CLLocationCoordinate2D>! = Array()
                
                if dataDic != nil {
                        let model =  itemsModel()
                        
                        model.uuid = dataDic["uuid"].string ?? ""
                        model.lat =  dataDic["lat"].string ?? ""
                        model.lng =  dataDic["lng"].string ?? ""
                        model.createdTime =  dataDic["createdTime"].string ?? ""
                        model.updateTime =  dataDic["updateTime"].string ?? ""
                        
                        self.dataArray.append(model)
                        
                        if self.locations.count > 1 {
                            self.locations.remove(at: 0)
                        }
                        
                        //if self.netHelper!.deviceImei != model.user {
                        busCoordinates.append(CLLocationCoordinate2D(latitude: Double(model.lat)!, longitude: Double(model.lng)!))
                        self.locations.append(CLLocation(latitude: Double(model.lat)!, longitude: Double(model.lng)!))
                        //}
                    
                }else {
                    self.locations = Array()
                    self.actionStop()
                    self.removeLastAnnotation()
                }
                
                self.addAnnotationWithCooordinate(coordinates: busCoordinates)
                //print("get success", self.netHelper!.timeStampToString())
            }
        }
        return dataArray
    }
    
    /**
     *放大缩小视图
     **/
    func makeZoomPannelView() -> UIView {
        let ret = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 53, height: 98))
        
        let incBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 53, height: 49))
        incBtn.setImage(UIImage.init(named: "increase.png"), for: UIControlState.normal)
        incBtn.sizeToFit()
        incBtn.addTarget(self, action: #selector(self.zoomPlusAction), for: UIControlEvents.touchUpInside)
        
        let decBtn = UIButton.init(frame: CGRect.init(x: 0, y: 49, width: 53, height: 49))
        decBtn.setImage(UIImage.init(named: "decrease.png"), for: UIControlState.normal)
        decBtn.sizeToFit()
        decBtn.addTarget(self, action: #selector(self.zoomMinusAction), for: UIControlEvents.touchUpInside)
        
        ret.addSubview(incBtn)
        ret.addSubview(decBtn)
        
        return ret
    }
    
    func zoomPlusAction() {
        let oldZoom = self.mapView.zoomLevel
        self.mapView.setZoomLevel(oldZoom+1, animated: true)
    }
    
    func zoomMinusAction() {
        let oldZoom = self.mapView.zoomLevel
        self.mapView.setZoomLevel(oldZoom-1, animated: true)
    }
    
    /**
     *路况显示
     **/
    func trafficAction(sender: UISwitch)
    {
        mapView.isShowTraffic = sender.isOn
    }
    
    func busLineButtonclick(_ sender: UIButton)
    {
        picker = LinePickerView.getShareInstance()
        picker!.textColor = UIColor.red
        picker!.showWithDate()
        picker?.block = {
            (busLine:Int)->() in
            self.busLineButton.setTitle(String(describing: busLine) , for: UIControlState())
            self.selectedBusLine = busLine
            self.setNormalDefault(key:self.SelectedBusLineKey!, value:busLine as AnyObject?)
        }
    }
    
    
    /*  使用NSUserDefaults对普通数据对象储存   */
    
    /**
     储存
     - parameter key:   key
     - parameter value: value
     */
    func setNormalDefault(key:String, value:AnyObject?){
        if value == nil {
            UserDefaults.standard.removeObject(forKey: key)
        }
        else{
            UserDefaults.standard.set(value, forKey: key)
            // 同步
            UserDefaults.standard.synchronize()
        }
    }
    
    /**
     通过对应的key移除储存
     - parameter key: 对应key
     */
    func removeNormalUserDefault(key:String?){
        if key != nil {
            UserDefaults.standard.removeObject(forKey: key!)
            UserDefaults.standard.synchronize()
        }
    }
    
    /**
     通过key找到储存的value
     - parameter key: key
     - returns: AnyObject
     */
    func getNormalDefult(key:String)->AnyObject?{
        return UserDefaults.standard.value(forKey: key) as AnyObject?
    }
    
    // 轨迹平滑移动
    func getAverageSpeed() {
        
        //        if locations == nil || locations.count == 0 {
        //            print("Invalid locations")
        //            return
        //        }
        //
        //        let starPoint = MAPointAnnotation()
        //        starPoint.coordinate = getStartLocation()!.coordinate
        //        starPoint.title = "Start"
        //
        //        mapView!.addAnnotation(starPoint)
        //
        //        let endPoint = MAPointAnnotation()
        //        endPoint.coordinate = getEndLocation()!.coordinate
        //        endPoint.title = "End"
        //
        //        mapView!.addAnnotation(endPoint)
        
        //        // 在地图上划线
        //        var coordiantes: [CLLocationCoordinate2D] = coordinates()
        //        let polyline = MAPolyline(coordinates: &coordiantes, count: UInt(coordiantes.count))
        //        mapView!.add(polyline)
        
        // average Speed
        averageSpeed = totalDistance() / 5
    }
    
    //MARK:- Helpers
    
    func actionPlay() {
        //print("Action: actionPlay")
        
        if myLocation == nil {
            myLocation = MAPointAnnotation()
            myLocation!.title = "Bus"
            myLocation!.coordinate = getStartLocation()!.coordinate
            mapView!.addAnnotation(myLocation)
            
            lastAnnotations.removeAll()
            lastAnnotations.append(myLocation!)
            
            mapView!.selectAnnotation(myLocation, animated: true)
        }
        
        animateToNextCoordinate()
    }
    
    func animateToNextCoordinate() {
        
        if myLocation == nil {
            return
        }
        
        //print("currentLocationIndex: \(currentLocationIndex)")
        
        let coordiantes: [CLLocationCoordinate2D] = coordinates()
        
        if currentLocationIndex == coordiantes.count {
            currentLocationIndex = 0
            //actionPlay()
            return
        }
        
        let nextCoord: CLLocationCoordinate2D = coordiantes[currentLocationIndex]
        
        let prevCoord: CLLocationCoordinate2D = currentLocationIndex == 0 ? nextCoord : myLocation!.coordinate
        
        let heading: Double = coordinateHeading(from: prevCoord, to: nextCoord)
        
        let distance: CLLocationDistance  = MAMetersBetweenMapPoints(MAMapPointForCoordinate(nextCoord), MAMapPointForCoordinate(prevCoord))
        
        var duration: TimeInterval = distance / averageSpeed
        if duration.isNaN {
            duration = 0
        }
        
        // 改变地图中心
        self.mapView!.setCenter(nextCoord, animated: true)
        
        UIView.animate(
            withDuration: 5,
            animations: {
                () -> Void in
                self.myLocation!.coordinate = nextCoord
                return
        },
            completion: { (stop: Bool) -> Void in
                self.currentLocationIndex += 1
                if stop {
                    self.animateToNextCoordinate()
                }
                return
        })
        
        
        let view: MAAnnotationView? = mapView!.view(for: myLocation)
        if view != nil {
            view!.transform = CGAffineTransform(rotationAngle: CGFloat(heading / 180.0 * M_PI))
        }
    }
    
    
    func actionStop() {
        print("actionStop")
        
        let view: MAAnnotationView? = mapView!.view(for: myLocation)
        if view != nil {
            view!.layer.removeAllAnimations()
            myLocation = nil
        }
    }
    
    func removeLastAnnotation()
    {
        if lastAnnotations.count > 0 {
            mapView.removeAnnotations(lastAnnotations)
            lastAnnotations = Array()
        }
    }
    
    func coordinateHeading(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        
        if !CLLocationCoordinate2DIsValid(from) || !CLLocationCoordinate2DIsValid(to) {
            return 0.0
        }
        
        let delta_lat_y: Double = to.latitude - from.latitude
        let delta_lon_x: Double = to.longitude - from.longitude
        
        if fabs(delta_lat_y) < 0.000001 {
            return delta_lon_x < 0.0 ? 270.0 : 90.0
        }
        
        var heading: Double = atan2(delta_lon_x, delta_lat_y) / M_PI * 180.0
        
        if heading < 0.0 {
            heading += 360.0
        }
        return heading
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
    
    func getStartLocation() -> CLLocation? {
        return locations.first
    }
    
    func getEndLocation() -> CLLocation? {
        return locations.last
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    func showRouteForCoords(coords:[CLLocationCoordinate2D], count:Int)
//    {
//        //show route
//        let route = MAPolyline(coordinates: coords, count:count)
//        mapView!.add(route)
//        
//        var routeAnno = Array<MAPointAnnotation>()
//        for i in 0..<count {
//            let a = MAPointAnnotation()
//            a.coordinate = coords[i]
//            a.title = "route"
//            routeAnno.append(a)
//        }
//        mapView!.addAnnotations(routeAnno)
//        mapView!.showAnnotations(routeAnno, animated:false)
//    }
//    
//    func initTrackingWithCoords(coords:[CLLocationCoordinate2D], count:Int)
//    {
//        var _tracking = Array<TracingPoint>()
//        var tp = TracingPoint()
//        for i in 0..<count-1 {
//            tp = TracingPoint()
//            tp.coordinate = coords[i]
//            tp.course = Util(coords[i], to:coords[i+1])
//            _tracking.append(tp)
//        }
//        
//        tp = TracingPoint()
//        tp.coordinate = coords[count - 1]
//        tp.course = ((_tracking.last)?.course)!
//        _tracking.append(tp)
//    }
    
}
