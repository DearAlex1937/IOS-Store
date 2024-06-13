//
//  CartManager.swift
//  Store
//
//  Created by edy on 2024/6/6.
//

import Foundation
class CartManager{
    static let shared = CartManager()
    private init(){
        
    }
    var cart:[CartEntry] = []
    func addToCart(entry:CartEntry){
        cart.append(entry)
    }
    func getCart() -> [CartEntry]{
        return cart
    }
    func clearCart(){
        cart = []
    }
}
