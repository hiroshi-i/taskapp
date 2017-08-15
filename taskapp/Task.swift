//
//  Task.swift
//  taskapp
//
//  Created by Apple on 2017/08/06.
//  Copyright © 2017年 hiroshi.inoue. All rights reserved.
//

import RealmSwift

class Task: Object{
    //管理用ID。プライマリーキー
    dynamic var id = 0
    
    //タイトル
    dynamic var title = ""
    
    //内容
    dynamic var contents = ""
    
    //カテゴリー
    dynamic var category = ""
    
    //日時
    dynamic var date = NSDate()
    
    /**
    IDをプライマリーキーとして設定する
    */
    override static func primaryKey() -> String?{
        return "id"
    }
}
