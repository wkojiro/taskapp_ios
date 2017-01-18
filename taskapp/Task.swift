//
//  Task.swift
//  taskapp
//
//  Created by Kojiro Wakabayashi on 2017/01/17.
//  Copyright © 2017年 wkojiro. All rights reserved.
//


import RealmSwift

class Task: Object {
    
    //管理用ID　プライマリキー
    dynamic var id = 0
    
    //タイトル
    dynamic var title = ""
    
    // カテゴリ
    dynamic var category = ""
    
    //内容
    dynamic var contents = ""
    
    
    
    //日時
    dynamic var date = NSDate()
    
    //　IDをプライマリキーとして設定
    override static func primaryKey() -> String?{
        return "id"
    }
    
}

