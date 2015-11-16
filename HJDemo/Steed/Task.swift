//
//  Task.swift
//  HJDemo
//
//  Created by Hubbert on 15/11/14.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

import Foundation

class  SDURLTask : NSObject{
    var ID:String
    var reqType:String
    var reqURLPath:String
    var reqParameters:Dictionary<String,String>
    var operation:AFHTTPRequestOperation?
    
    override init() {
        ID = ""
        reqType = ""
        reqURLPath = ""
        reqParameters = Dictionary<String,String>(minimumCapacity: 5)
        super.init()
    }
}

class SDURLPageTask : SDURLTask {
    var pageIndex:Int
    var pageSize:Int
    var hasMoreData:Bool
    var pageIndexKey:String
    var pageSizeKey:String
    
    override init() {
        pageIndex = 0
        pageSize = 20
        hasMoreData = false
        pageIndexKey = ""
        pageSizeKey = ""
        super.init()
    }
}
