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
    
    var myTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nvItem.title = myTitle
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backToPrev(_ sender: Any) {
        self.dismiss(animated: true)    }
}
