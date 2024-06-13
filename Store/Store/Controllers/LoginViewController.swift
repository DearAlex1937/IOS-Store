//
//  LoginViewController.swift
//  Store
//
//  Created by edy on 2024/5/29.
//

import Foundation
import UIKit
import SQLite3

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var regButton: UIButton!
    
    var db: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置数据库
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("UsersDatabase.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK {
            print("无法打开数据库")
            return
        }
        
        let createTableQuery = "CREATE TABLE IF NOT EXISTS Users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT)"
        
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("无法创建表")
            return
        }
        
        // 测试数据（删除之前添加的用户，防止重复）
        let deleteQuery = "DELETE FROM Users"
        if sqlite3_exec(db, deleteQuery, nil, nil, nil) != SQLITE_OK {
            print("无法删除测试数据")
            return
        }
        
        // 添加测试用户
        let insertQuery = "INSERT INTO Users (username, password) VALUES ('testUser', 'testPass')"
        
        if sqlite3_exec(db, insertQuery, nil, nil, nil) != SQLITE_OK {
            print("无法插入测试用户")
            return
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if username == "" || password == "" {
            showAlert(message: "请填写用户名和密码")
            return
        }
        
        var stmt: OpaquePointer?
        let queryString = "SELECT * FROM Users WHERE username = ? AND password = ?"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            print("查询准备失败")
            return
        }
        
        if sqlite3_bind_text(stmt, 1, username, -1, nil) != SQLITE_OK || sqlite3_bind_text(stmt, 2, password, -1, nil) != SQLITE_OK {
            print("绑定失败")
            return
        }
        
        if sqlite3_step(stmt) == SQLITE_ROW {
            // 登录成功，导航到主页
            let mainTabBarController = storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
            mainTabBarController.modalPresentationStyle = .fullScreen
            present(mainTabBarController, animated: true, completion: nil)
        } else {
            showAlert(message: "用户名或密码错误")
        }
        
        sqlite3_finalize(stmt)
    }
    
    @IBAction func regButtonTapped(_ sender: UIButton){
        let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if username == "" || password == ""{
            showAlert(message: "请填写用户名和密码")
            return
        }
        
        let insertQuery = "INSERT INTO Users (username, password) VALUES (?, ?)"
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, insertQuery, -1, &stmt, nil) != SQLITE_OK{
            print("插入准备失败")
            return
        }
        
        if sqlite3_bind_text(stmt, 1, username, -1, nil) != SQLITE_OK
            || sqlite3_bind_text(stmt, 2, password, -1, nil) != SQLITE_OK{
            print("绑定失败")
            return
        }
        
        if sqlite3_step(stmt) == SQLITE_DONE{
            print("用户注册成功")
            Profile.shared.changeName(name: username!)
            showAlert(message: "用户注册成功")
        }else{
            print("用户注册失败")
            showAlert(message: "用户注册失败")
        }
    
        sqlite3_finalize(stmt)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

