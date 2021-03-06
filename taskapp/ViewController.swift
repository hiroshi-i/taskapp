//
//  ViewController.swift
//  taskapp
//
//  Created by Apple on 2017/08/05.
//  Copyright © 2017年 hiroshi.inoue. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //Realmインスタンスを取得する
    let realm = try! Realm()
    
    //DB内のタスクが格納されるリスト
    //日付近い順\順でソート：降順
    //以降内容をアッップデートするとリスト内は自動的に更新される
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath:"date", ascending:false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self  //追加 デリゲート先を自分に設定
        
        //追加 何も入力されていなくてもリターンキーを押せるようにする
        searchBar.enablesReturnKeyAutomatically = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITableViewDataSourceプロトコルのメソッド
    //データ型の数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return taskArray.count
    }
    
    //各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexpath: IndexPath) -> UITableViewCell{
        //再利用可能なcellを作る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexpath)
        
        
        //cellに値を設定する
        let task = taskArray[indexpath.row]
        cell.textLabel?.text = "\(task.title)(\(task.category))"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date as Date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    
    //検索ボタン押した時のメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        tableView.reloadData()
    }
    
    
    //テキストが変更される毎に呼ばれる
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == ""{
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath:"date", ascending:false)
        }else{
            let searchCategory = realm.objects(Task.self).filter("category = '\(searchText)'")
            // Realmに保存されているすべてのTaskオブジェクトを取得
            
            taskArray = searchCategory
        }
        
        tableView.reloadData()
    }
    
    
    //検索をキャンセルした時のメソッド
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath:"date", ascending:false)
        tableView.reloadData()
        
    }
    
    //MARK: UITableViewDelegateプロトコルのメソッド
    //各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    //セルが削除可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle{
        return UITableViewCellEditingStyle.delete
    }
    
    
    
    
    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == UITableViewCellEditingStyle.delete{
            
            //削除されたタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            //ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //データベースから削除する
            try! realm.write{
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
            }
            
            //未通知のローカル出力一覧をログ出力
            center.getPendingNotificationRequests{(requests: [UNNotificationRequest]) in
                for request in requests{
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
    
    //Segueで画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }else{
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0{
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }
    
    
    //入力画面から戻ってきた時にtableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
}




