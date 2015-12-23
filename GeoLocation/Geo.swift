//
//  Geo.swift
//  GeoLocation
//
//  Created by 加藤 雄大 on 2015/12/19.
//  Copyright © 2015年 grandbig.github.io. All rights reserved.
//

import RealmSwift

class Geo:Object {
    dynamic var lat:Double = 0
    dynamic var lng:Double = 0
    dynamic var acc:Double = 0
    dynamic var type:String = ""
    dynamic var date:NSDate = NSDate()
    
    /*
    override static func primaryKey() -> String? {
        return "id"
    }
*/
}
