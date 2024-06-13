//
//  Profile.swift
//  Store
//
//  Created by edy on 2024/6/7.
//

import Foundation
class Profile{
    static let shared = Profile()
    private init(){
        
    }
    var userName: String = "User1937"
    func changeName(name: String){
        userName = name
    }
    func getInfo() -> String{
        return userName
    }
}
