//
//  MeViewController.swift
//  BusComing
//
//  Created by liupeng on 2016/11/4.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

import UIKit
import Foundation

class MeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{

    var pickerView:UIPickerView!
    var areaArray:Array<AnyObject>?
    var label:UILabel?
    var lines = ["","1号线","2号线","3号线","4号线","5号线","6号线","7号线","8号线","9号线"]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        initLinePicker()
        
//        self.label! = UILabel(frame: CGRect.init(x: 0, y: 0, width:view.bounds.width, height:30))
//        self.view.addSubview(self.label!)
//        self.label!.backgroundColor = UIColor.yellow
//        self.label!.textColor = UIColor.red
//        self.label!.autoresizingMask = UIViewAutoresizing.flexibleTopMargin
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initLinePicker() {
        
        pickerView = UIPickerView()
        //将dataSource设置成自己
        pickerView.dataSource = self
        //将delegate设置成自己
        pickerView.delegate = self
        //设置选择框的默认值
        //pickerView.selectRow(1,inComponent:0,animated:true)
        self.view.addSubview(pickerView)
        
        //建立一个按钮，触摸按钮时获得选择框被选择的索引
        let button = UIButton(frame:CGRect(x:0, y:0, width:view.bounds.width, height:30))
        button.center = self.view.center
        button.backgroundColor = UIColor.blue
        button.setTitle("获取信息",for:.normal)
        button.addTarget(self, action:#selector(MeViewController.getPickerViewValue),
                         for: .touchUpInside)
        self.view.addSubview(button)

    }
    
    //设置选择框的列数,继承于UIPickerViewDataSource协议
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //设置选择框的行数，继承于UIPickerViewDataSource协议
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return lines.count
    }
    
    //设置选择框各选项的内容，继承于UIPickerViewDelegate协议
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return lines[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let text = String("你选择了：\(lines[row])")
        self.label!.text = text
    }
    
    //触摸按钮时，获得被选中的索引
    func getPickerViewValue(){
        let message = String(pickerView.selectedRow(inComponent: 0))
        let alertController = UIAlertController(title: "被选中的索引为",
                                                message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}
