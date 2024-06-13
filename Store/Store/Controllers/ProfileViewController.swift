//
//  ProfileViewController.swift
//  Store
//
//  Created by edy on 2024/5/31.
//

import UIKit
class BoughtCell: UITableViewCell{
    @IBOutlet weak var boughtName: UILabel!
    @IBOutlet weak var boughtPrice: UILabel!
    @IBOutlet weak var boughtDate: UILabel!
}

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var Boughts : [BoughtEntry] = []
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var boughts: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.text = "Hello!\(Profile.shared.getInfo())"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated)
        Boughts = BoughtsManager.shared.getBoughts()
        boughts.reloadData()
//        cart = CartManager.shared.getCart()
//        collectionView.reloadData()
//        total_Price = 0;
//        for entry in cart{
//            total_Price += entry.price
//            print(entry.price)
//            print(total_Price)
//        }
//        totalPrice.text = "TotalPrice: ¥\(total_Price)"
    }
    

//    func tableView(_ tableView: UITableView, numberOfItemsInSection section: Int) -> Int {
//        return Boughts.count
//    }
       
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Boughts.count
    }
       
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           
//        let cell = tableView.dequeueReusableCell(withIdentifier: "BoughtCell", for: indexPath)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BoughtCell", for: indexPath) as? BoughtCell else {
            fatalError("无法将 cell 转换为 BoughtCell")
        }
           
        let bought = Boughts[indexPath.row]
        cell.boughtName.text = bought.name
        cell.boughtPrice.text = "¥\(bought.price)"
        cell.boughtDate.text = "\(bought.date)"
        return cell
    }
       
//       override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//           return meals[section].name
//    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
