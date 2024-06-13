//
//  HomeViewController.swift
//  Store
//
//  Created by edy on 2024/5/31.
//

import UIKit
import SQLite3
import Foundation

class TCMCell: UICollectionViewCell{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var AddToCart: UIButton!

    
    var addToCartAction:(() -> Void)?
    
    @IBAction func addToCartTapped(_ sender: UIButton){
        addToCartAction?()
    }
    
}

struct TCM{
    var id: Int
    var name: String
    var description: String
    var price: Double
    var imageUrl: String
    var category: String
}


class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    var entryList: [CartEntry] = []
    var tcmList: [TCM] = []
    var filteredTCMList: [TCM] = []
    var selectedTCM: TCM?
    var shouldPerformSegue: Bool = false
    var db: OpaquePointer?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var selectMothod: UISegmentedControl!
    
    //消息弹窗
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        // 设置 Collection View
        collectionView.dataSource = self
        collectionView.delegate = self
        
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.showsSearchResultsButton = true
        searchBar.placeholder = "搜索药品"
        super.viewDidLoad()
        // 从 AppDelegate 中获取数据库连接
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let database = appDelegate.db{
            db = database
        }else{
            fatalError("数据库连接失败")
        }
        
        // 读取数据
        tcmList = fetchTCMData()
        filteredTCMList = tcmList

    }
    
    func fetchTCMData() -> [TCM] {
        var tcmList: [TCM] = []
        let query = "SELECT * FROM TCMS"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let name = String(cString: sqlite3_column_text(stmt, 1))
                let description = String(cString: sqlite3_column_text(stmt, 2))
                let price = sqlite3_column_double(stmt, 3)
                let imageUrl = String(cString: sqlite3_column_text(stmt, 4))
                let category = String(cString: sqlite3_column_text(stmt, 5))

                print("id: \(id), name: \(name), description: \(description), price: \(price), imageUrl: \(imageUrl), category: \(category)")

                tcmList.append(TCM(id: id, name: name, description: description, price: price, imageUrl: imageUrl, category: category))
            }
        } else {
            print("查询准备失败")
        }

        sqlite3_finalize(stmt)
        return tcmList
    }
    
    // UICollectionView DataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTCMList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        selectedTCM = tcmList[indexPath.row]
        shouldPerformSegue = true
        performSegue(withIdentifier: "showDetailSegue", sender: self)


    }
    
    override func prepare(for segue:UIStoryboardSegue, sender:Any?){
        if segue.identifier == "showDetailSegue"{
            if shouldPerformSegue,
               let detailViewController = segue.destination as? DetailViewController{
                detailViewController.tcm = selectedTCM
                shouldPerformSegue = false
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchText.isEmpty{
            filteredTCMList = tcmList
        }else{
            if selectMothod.selectedSegmentIndex == 0{
                filteredTCMList = tcmList.filter{
                    $0.name.lowercased().contains(searchText.lowercased())}
            }
            else{
                filteredTCMList = tcmList.filter{
                    $0.category.lowercased().contains(searchText.lowercased())
                }
            }

        }
        collectionView.reloadData()
        print(filteredTCMList)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }


}
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 3.0
        let width = (collectionView.bounds.width - 3 * padding) / 2 // 每行显示两个 Cell，中间间隔为 padding
        let height = width + 40.0 // 假设图片高度和文字高度加起来是 40.0

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0 // 设置每行之间的间距
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0 // 设置每列之间的间距
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TCMCell", for: indexPath) as? TCMCell else {
            fatalError("无法将 cell 转换为 TCMCell")
        }
        
        let tcm = filteredTCMList[indexPath.row]
        cell.nameLabel.text = tcm.name
        cell.priceLabel.text = "¥\(tcm.price)"
        
        // 设置图片（假设图片已添加到项目中）
        cell.imageView.image = UIImage(named: tcm.imageUrl)
        cell.addToCartAction = {
            [weak self] in
            let cartEntry = CartEntry(id:tcm.id, name:tcm.name,price:tcm.price,count:1, imageUrl:tcm.imageUrl)
            CartManager.shared.addToCart(entry: cartEntry)
            self?.showAlert(message: "已加入购物车！")
            print(self?.entryList)
        }
        
        // 调整子视图的布局
        let padding: CGFloat = 1.0
        let imageHeight = cell.bounds.height - 2 * padding - cell.nameLabel.bounds.height - cell.priceLabel.bounds.height
        cell.imageView.frame = CGRect(x: padding, y: padding, width: cell.bounds.width - 2 * padding, height: imageHeight)
        cell.nameLabel.frame = CGRect(x: padding, y: padding + imageHeight, width: cell.bounds.width - 2 * padding, height: cell.nameLabel.bounds.height)
        cell.priceLabel.frame = CGRect(x: padding, y: padding + imageHeight + 25, width: cell.bounds.width/2 , height: cell.priceLabel.bounds.height)
        cell.AddToCart.frame = CGRect(x: cell.bounds.width-10 , y:padding + imageHeight + cell.nameLabel.bounds.height+5, width: 10.0, height: 10.0)

        return cell
}
}

