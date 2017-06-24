//
//  LinePickerView.swift
//  BusComing
//
//  Created by liupeng on 2016/11/4.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

import UIKit
typealias dateBlock = (_ busLine:Int)->()
class LinePickerView: UIView,UIPickerViewDataSource,UIPickerViewDelegate {
    
    fileprivate static let _shareInstance = LinePickerView()
    class func getShareInstance()-> LinePickerView{
        return _shareInstance;
    }
    
    var block:dateBlock?
    var textColor:UIColor = UIColor.black; //字体颜色 默认为黑色
    var buColor:UIColor = UIColor.white; //按钮栏背景颜色 默认为白色
    var pickerColor:UIColor = UIColor.white; //选择器背景色 默认为白色
    var alphas:CGFloat = 0.6;         //背景透明度默认为0.6
    fileprivate var linePicker:UIPickerView?
    fileprivate var selectedLine:Int = 0
    let lines = ["","1号线","2号线","3号线","4号线","5号线","6号线"]

    fileprivate init()
    {
        super.init(frame: (UIApplication.shared.keyWindow?.bounds)!)
        initUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func showWithDate()
    {
        UIApplication.shared.keyWindow?.addSubview(self)
        linePicker?.reloadAllComponents();
    }
    
    func initUI()
    {
        self.backgroundColor = UIColor.clear
        let colorView:UIView = UIView(frame: self.bounds)
        colorView.backgroundColor = UIColor.black
        colorView.alpha = alphas;
        self.addSubview(colorView)
        let buttonView:UIView = UIView(frame: CGRect( x: 0, y: self.frame.size.height/2.0, width: self.frame.size.width, height: 45))
        self.addSubview(buttonView)
        buttonView.backgroundColor = buColor
        for i in 0 ..< 2
        {
            let btn:UIButton = UIButton(type: UIButtonType.custom)
            btn.setTitleColor(textColor, for: UIControlState())
            buttonView.addSubview(btn)
            if (i==0)
            {
                btn.frame = CGRect(x: 10, y: 0, width: 60, height: buttonView.frame.size.height);
                btn.setTitle("取消", for: UIControlState())
                btn.addTarget(self, action: #selector(LinePickerView.cancelClick(_:)), for: UIControlEvents.touchUpInside)
            }else{
                btn.frame = CGRect(x: buttonView.frame.size.width-70, y: 0, width: 60, height: buttonView.frame.size.height);
                btn.setTitle("确定", for: UIControlState())
                btn.addTarget(self, action: #selector(LinePickerView.doneClick(_:)), for: UIControlEvents.touchUpInside)
            }
        }
        
        linePicker = UIPickerView(frame: CGRect(x: 0, y: self.frame.size.height/2.0+45, width: self.frame.size.width, height: self.frame.size.height/2.0-45))
        linePicker?.backgroundColor = pickerColor;
        linePicker?.delegate = self
        linePicker?.dataSource = self
        self.addSubview(linePicker!)
        linePicker?.showsSelectionIndicator =  true;
        
    }
    
    func cancelClick(_ sender:UIButton) //取消事件
    {
        self.removeFromSuperview()
    }
    
    func doneClick(_ sender:UIButton) //完成事件
    {
        block!(selectedLine)
        self.removeFromSuperview()
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50;
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        return self.frame.size.width/3.0;
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedLine = row
//        self.selectedLine = String(row)
//        if 0 == row {
//            self.selectedLine = ""
//        }
        pickerView.reloadAllComponents()
    }
    
    //设置选择框的列数,继承于UIPickerViewDataSource协议
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //设置选择框的行数，继承于UIPickerViewDataSource协议
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return lines.count
    }
    
    //设置选择框各选项的内容，继承于UIPickerViewDelegate协议（titleForRow 和 viewForRow 二者实现其一即可）
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return lines[row]
    }
    
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width/3.0, height: 50))
//        label.textColor = textColor
//        label.textAlignment = NSTextAlignment.center
//        label.text = lines[row]
//        return label
//    }
    

}
