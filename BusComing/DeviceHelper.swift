//
//  NetworkHelper.swift
//  BusComing
//
//  Created by liupeng on 2016/10/31.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

import Foundation
import AdSupport


class DeviceHelper: NSObject {
    
    class func deviceIdfa() -> String? {
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        return idfa
    }
}
