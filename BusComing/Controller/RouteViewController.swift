//
//  RouteViewController.swift
//  BusComing
//
//  Created by liupeng on 2017/6/24.
//  Copyright © 2017年 AutoNavi. All rights reserved.
//

import Foundation
import UIKit

class RouteViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    let lines = ["1号线","2号线","3号线","4号线","5号线","6号线"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    
    // UITableViewDelegate 方法，处理列表项的选中事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionData = lines[indexPath.row]
        
        print(sectionData)
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
