//
//  RouteViewController.swift
//  BusComing
//
//  Created by liupeng on 2017/6/24.
//  Copyright © 2017年 AutoNavi. All rights reserved.
//

import Foundation
import UIKit

class RouteViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, AMapLocationManagerDelegate, AMapSearchDelegate {

    @IBOutlet weak var myRouteLocationLbl: UILabel!
    
    let lines = ["1号线","2号线","3号线","4号线","5号线","6号线"]
    lazy var locationManager = AMapLocationManager()
    var reGoecodeSearch = AMapSearchAPI()
    
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
            self.myRouteLocationLbl.text = response.regeocode.formattedAddress
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configLocationManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! BuslineViewTableCell
        cell.labelText.text = lines[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let sectionData = lines[indexPath.row]
        //print(sectionData)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let vc = segue.destination
        switch vc {
        case is RouteDatilesViewControl:
            (vc as! RouteDatilesViewControl).myTitle = (sender as! BuslineViewTableCell).labelText?.text
            break;
        default:
            break;
        }

    }

}
