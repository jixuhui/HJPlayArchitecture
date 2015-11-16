//
//  Service.swift
//  HJDemo
//
//  Created by Hubbert on 15/11/14.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

import Foundation

class SDURLService : AFHTTPRequestOperationManager{
    
    private var taskContainer:[SDURLTask]?

    class var shareService:SDURLService {
        return Inner.instance
    }
    
    struct Inner {
        static let instance = SDURLService()
    }
}