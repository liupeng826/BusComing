//
//  RouteDatilesViewControl.swift
//  BusComing
//
//  Created by liupeng on 2017/6/24.
//  Copyright © 2017年 AutoNavi. All rights reserved.
//

import UIKit

class RouteDatilesViewControl: UIViewController {
    
    @IBOutlet weak var nvItem: UINavigationItem!
    @IBOutlet weak var favoriteonBtn: UIBarButtonItem!
    
    var myTitle: String?
    var favStatus = false
    var index_substring : Int = 0
    var busline: String = ""
    var fav: String = ""
    let FAVORITE_KEY: String? = "FAVORITE_KEY"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nvItem.title = myTitle
        
        self.fav = self.getNormalDefult(key:self.FAVORITE_KEY!) as? String ?? ""
        index_substring = (myTitle?.characters.count)! - 2
        let index = myTitle?.index((myTitle?.startIndex)!, offsetBy: index_substring)
        busline = (myTitle?.substring(to: index!))!
        
        if self.busline == self.fav {
            favoriteonBtn.image = UIImage(named: "icon_StarFilled")
            favStatus = true
        }else{
            favoriteonBtn.image = UIImage(named: "icon_Star")
            favStatus = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backToPrev(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveFavoriteLine(_ sender: Any) {
        if !favStatus {
            favoriteonBtn.image = UIImage(named: "icon_StarFilled")
            
            self.setNormalDefault(key:self.FAVORITE_KEY!, value: busline as AnyObject)
        }else{
            favoriteonBtn.image = UIImage(named: "icon_Star")
            self.removeNormalUserDefault(key:self.FAVORITE_KEY!)
        }
        
        favStatus = !favStatus
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


}
