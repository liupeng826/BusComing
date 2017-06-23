//
//  MeViewController.swift
//  BusComing
//
//  Created by liupeng on 2016/11/4.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

import UIKit

let kWindowHeight: CGFloat = 205.0
let tableRowCount = 10
class MeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView?
    var headerView: CoolNavi?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        tableView = UITableView()
        tableView!.backgroundColor = UIColor.clear
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height);
        self.view.addSubview(tableView!)
        
        headerView = CoolNavi()
        headerView!.myInit(CGRect(x: 0,y: 0,width: self.view.frame.size.width,height: kWindowHeight), backImageName: "background", headerImageURL: "http://d.hiphotos.baidu.com/image/pic/item/0ff41bd5ad6eddc4f263b0fc3adbb6fd52663334.jpg", title: "姓名", subTitle: "个性签名, 啦啦啦!")
        headerView?.scrollView = tableView
        headerView?.initWithClosure({ () -> Void in
            print("headerImageAction")
        })
        self.view.addSubview(headerView!)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableRowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel!.text = String(format: "%i", indexPath.row + 1)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
