//
//  CartViewController.swift
//  Store
//
//  Created by edy on 2024/5/31.
//

import UIKit

class CartCell: UICollectionViewCell{
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var deleteEntryAction: (() -> Void)?
    @IBAction func deleteEntry(_ sender: UIButton){
        deleteEntryAction?()
    }
}

struct CartEntry{
    var id: Int
    var name: String
    var price: Double
//    var time: String
    var count: Int
    var imageUrl: String
}

struct BoughtEntry{
    var name: String
    var price: Double
    var date: Date
}


class CartViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var payBtn: UIButton!
    
    //消息弹窗
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {
            _ in self.paid()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func paid(){
        for entry in cart{
            
            
            let boughtToAdd = BoughtEntry(name: entry.name, price: entry.price, date: Date())
            BoughtsManager.shared.addToBoughts(entry: boughtToAdd)
        }
        cart.removeAll()
        CartManager.shared.clearCart()
        collectionView.reloadData()
        total_Price = 0
        totalPrice.text = "TotalPrice: ¥\(total_Price)"
    }
    @IBAction func payForAll(_ sender:UIButton){
        showAlert(message: "确认支付？")
    }
    var bought: BoughtEntry?
    var cart : [CartEntry] = []
    var Boughts: [BoughtEntry] = []
    var total_Price: Double = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated)
        cart = CartManager.shared.getCart()
        collectionView.reloadData()
        total_Price = 0;
        for entry in cart{
            total_Price += entry.price
            print(entry.price)
            print(total_Price)
        }
        totalPrice.text = "TotalPrice: ¥\(total_Price)"
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(cart.count)
        print(cart)
        return cart.count
    }
    

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CartCell", for: indexPath) as? CartCell else {
            fatalError("无法将 cell 转换为 CartCell")
        }
        let entry = cart[indexPath.row]
        cell.nameLabel.text = entry.name
        cell.priceLabel.text = "¥\(entry.price)"
        cell.countLabel.text = String(entry.count)
        cell.imageView.image = UIImage(named: entry.imageUrl)

        
        cell.deleteEntryAction = {
            print("1111111111")
            self.cart.remove(at: indexPath.item)
            collectionView.deleteItems(at: [indexPath])

            if let priceString = cell.priceLabel.text,
               let cleanedPriceString = String?(String(priceString.dropFirst())),
               let price = Double(cleanedPriceString) {
                self.total_Price -= price
                self.totalPrice.text = "TotalPrice: ¥\(self.total_Price)"
            } else {
                // 处理转换失败的情况，比如打印错误或者设置一个默认值
                print("无法将价格标签的文本转换为Double。")
                // 或者你可以设置一个默认值，比如0.0
                // total_Price -= 0.0
            }

            collectionView.reloadData()
        }
        
        // 调整子视图的布局
        let padding: CGFloat = 1.0
        let imageHeight = cell.bounds.height - 2 * padding - cell.nameLabel.bounds.height - cell.priceLabel.bounds.height
        cell.imageView.frame = CGRect(x: padding, y: padding, width: cell.bounds.width - 2 * padding, height: imageHeight)
        cell.nameLabel.frame = CGRect(x: padding, y: padding + imageHeight, width: cell.bounds.width - 2 * padding, height: cell.nameLabel.bounds.height)
        cell.priceLabel.frame = CGRect(x: padding, y: padding + imageHeight + 25, width: cell.bounds.width/2 , height: cell.priceLabel.bounds.height)
        cell.countLabel.frame = CGRect(x: cell.bounds.width-10 , y:padding + imageHeight + cell.nameLabel.bounds.height-10, width: 10.0, height: 10.0)
        cell.deleteBtn.frame = CGRect(x: cell.bounds.width-10 , y:padding + imageHeight + cell.nameLabel.bounds.height+10, width: 10.0, height: 10.0)
        
        
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension CartViewController: UICollectionViewDelegateFlowLayout {
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
}
