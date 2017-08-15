//
//  InputViewController.swift
//  taskapp
//
//  Created by Apple on 2017/08/05.
//  Copyright © 2017年 hiroshi.inoue. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {

    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    
        let realm = try! Realm()
        var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //背景をタップしたらdissmissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        category.text = task.category  //追加
        datePicker.date = task.date as Date
     
        }
    
        //遷移する際に、画面が非表示になるとき呼ばれるメソッド
        override func viewWillDisappear(_ animated: Bool) {
        try! realm.write{
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text!
            self.task.category = self.category.text! 
            self.task.date = self.datePicker.date as NSDate
            self.realm.add(self.task, update: true)
        }
        setNotification(task: task)
        
        super .viewWillDisappear(animated)
    }
    
    //タスクのローカル通知を登録する
    func setNotification(task: Task){
        let content = UNMutableNotificationContent()
        content.title = task.title
        content.body = task.contents              //bodyが空だと音しか出ない
        content.sound = UNNotificationSound.default()
        
        //ローカル通知が発動するtrigger(日付マッチ)を作成
        let calendar = NSCalendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date as Date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        //identifier,content,triggerからローカル通知を作成(identifierが同じだとローカル通知を上書き保存)
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        //ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request){(error) in
            print(error ?? "ローカル通知登録 OK")  //errorがnilならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
        
        //未来のローカル通知一覧をログ出力
            center.getPendingNotificationRequests{(requests: [UNNotificationRequest]) in
                for request in requests{
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    
    func dismissKeyboard(){
        //キーボードを閉じる
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
