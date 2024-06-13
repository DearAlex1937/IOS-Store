//
//  DetailViewController.swift
//  Store
//
//  Created by edy on 2024/6/7.
//

import Foundation
import UIKit



class DetailViewController: UIViewController{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var details: UITextField!
    
    var tcm: TCM?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(tcm)
        if let tcm = tcm{
            nameLabel.text = tcm.name
            details.text = tcm.category + tcm.description
            priceLabel.text = "¥\(tcm.price)/100g"
            imageView.image = UIImage(named: tcm.imageUrl)
        }
    }
    
}
