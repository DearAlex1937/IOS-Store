//
//  BoughtsManager.swift
//  Store
//
//  Created by edy on 2024/6/11.
//

import Foundation
class BoughtsManager{
    static let shared = BoughtsManager()
    private init(){
        
    }
    var boughts:[BoughtEntry] = []
    func addToBoughts(entry:BoughtEntry){
        boughts.append(entry)
    }
    func getBoughts() -> [BoughtEntry]{
        return boughts
    }
}
