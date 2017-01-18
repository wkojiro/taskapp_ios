//
//  ViewController.swift
//  taskapp
//
//  Created by Kojiro Wakabayashi on 2017/01/17.
//  Copyright © 2017年 wkojiro. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications    // 追加


class ViewController: UIViewController,UITableViewDelegate, UISearchBarDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var searchBar: UISearchBar!
    
    //多分使うDBを規定している（デフォルトだからこのまま）
    let realm = try! Realm()
    
    //searchActiveかどうか
    var searchActive : Bool = false
    
    var filtered = try! Realm().objects(Task.self) // ここは本当は、単に配列を定義しておきたい、、。
    var taskArray = try! Realm().objects(Task.self).sorted(byProperty: "date", ascending: false)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        //検索ボタンを常に有効にする
        searchBar.enablesReturnKeyAutomatically = false

        //全データ削除
        //try! realm.write {
        //    self.realm.deleteAll()
        //}
        
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filtered = try! Realm().objects(Task.self).filter("category = %@",searchBar.text! )
        if(searchBar.text! == ""){
            searchActive = false;
        } else {
            searchActive = true;
        }
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // segue で画面遷移するに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            if(searchActive){
                inputViewController.task = filtered[indexPath!.row]
            } else {
                inputViewController.task = taskArray[indexPath!.row]
            }
            
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
   // 入力画面から戻ってきた時に TableView を更新させる    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive){
            return filtered.count
        } else {
            return taskArray.count
        }
        
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        
        // Cellに値を設定する.
        if(searchActive){
            let task = filtered[indexPath.row]
            cell.textLabel?.text = task.title
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let dateString:String = formatter.string(from: task.date as Date)
            cell.detailTextLabel?.text = dateString
            
            return cell
            
        }else{
            let task2 = taskArray[indexPath.row]
            cell.textLabel?.text = task2.title
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let dateString:String = formatter.string(from: task2.date as Date)
            cell.detailTextLabel?.text = dateString
            
            
            return cell
        }
        
    }
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle{
        return UITableViewCellEditingStyle.delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // 削除されたタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                if(searchActive){
                    self.realm.delete(self.filtered[indexPath.row])
                    tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
                    
                } else {
                    
                    self.realm.delete(self.taskArray[indexPath.row])
                    tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
                }
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }

//    func searchBarSeachButtonClicked(searchBar: UISearchBar){
//        searchBar.endEditing(true)
//    }

    

    
}

