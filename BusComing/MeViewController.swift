//
//  MeViewController.swift
//  BusComing
//
//  Created by liupeng on 2016/11/4.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

import UIKit
import Foundation

class MeViewController: UIViewController {
    
    var picker:LinePickerView?
    var areaArray:Array<AnyObject>?
    var busLineLabel:UILabel?
    var mvc: MapViewController?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let btn:UIButton = UIButton(type: UIButtonType.custom)
        btn.frame = CGRect(x: 20, y: 100, width: self.view.bounds.size.width - 20, height: 150);
        btn.setTitle("选择班车线路", for: UIControlState())
        btn.addTarget(self, action: #selector(MeViewController.click(_:)), for: UIControlEvents.touchUpInside)
        btn.setTitleColor(UIColor.black, for: UIControlState())
        btn.contentHorizontalAlignment = .left
        self.view.addSubview(btn)
        
        let gobtn:UIButton = UIButton(type: UIButtonType.custom)
        gobtn.frame = CGRect(x: self.view.bounds.size.width - 20, y: 100, width: 10, height: 150);
        gobtn.setTitle(">", for: UIControlState())
        gobtn.contentHorizontalAlignment = .right
        gobtn.setTitleColor(UIColor.gray, for: UIControlState())
        self.view.addSubview(gobtn)
        
        busLineLabel = UILabel(frame: CGRect(x: 270, y: 100, width: 200, height: 150))
        busLineLabel?.textColor = UIColor.black
        self.view.addSubview(busLineLabel!)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func click(_ sender: UIButton)
    {
        picker = LinePickerView.getShareInstance()
        picker!.textColor = UIColor.red
        picker!.showWithDate()
        picker?.block = {
            (busLine:String)->() in
            self.busLineLabel?.text = busLine
            self.mvc?.selectedBusLine = busLine
        }
    }
    
}
