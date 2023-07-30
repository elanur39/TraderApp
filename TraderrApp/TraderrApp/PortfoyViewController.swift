//
//  PortfoyViewController.swift
//  TraderrApp
//
//  Created by ELANUR KIZILAY on 29.07.2023.
//

import UIKit

class PortfoyViewController: UIViewController {
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    var stock: [Stock] = [] // Bu Hesap özeti için hisse senedi
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.separatorInset = .zero
        
        navigationItem.titleView?.tintColor = UIColor.white
        
        getPortfoyData()
    }
    
    func getPortfoyData() {
        if let userName = APPDELEGATE?.userName, let password = APPDELEGATE?.password, let defaultAccount = APPDELEGATE?.defaultAccount {
            // APPDELEGATE değişkenine erişiyoruz. Bu değişkenin içinde userName, password ve defaultAccount gibi verilere erişiyoruz.
            let urlString = "https://tbpilot.matriksdata.com/9999/Integration.aspx?MsgType=AN&CustomerNo=0&Username=\(userName)&Password=\(password)&AccountID=\(defaultAccount)&ExchangeID=4&OutputType=2"
            if let url = URL(string: urlString) {
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                // İsteğin sonucunda bir hata oluşup oluşmadığını kontrol ediyoruz
                    if let error = error {
                        print("Error : \(error)")
                        return
                    }
                    guard let data = data else { // Burada verinin boş olup olmadığını kontrol ediyoruz
                        print("Data boş")
                        return
                    }
                    
                    do {
                        // Burada veriyi JSON olarak pars etmeye çalışıyourz. Daha okunabilir bir hale getiriyoruz aslında
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        
                        if let jsonData = json as? [String:Any],  // JSON, bir [String: Any] şeklinde parçalandı ve jsonData değişkenine atanıyor.
                           let result = jsonData["Result"] as? NSDictionary {  // JSON verisinde "Result" anahtarının altındaki değerler result değişkenine atanıyor.
                            if let state = result["State"] as? Bool
                            {
                            // "Result" altındaki "State" değeri bir Bool olarak çıkarılarak state değişkenine atanıyor.
                                if state {
                                    // Eğer state true ise, oturum açma başarılı demektir.
                                    // "Item" anahtarının altındaki veriler items değişkenine atanıyor.
                                    if let items = jsonData["Item"] as? [[String: Any]] {
                                        self.processStockData(items)
                                    }
                                } else {
                                    // Eğer state false ise, oturum açma başarısız demektir.
                                    // "Description" altındaki hata mesajı errorMessage değişkenine atanıyor.
                                    if let errorMessage = result["Description"] as? String {
                                        // Oturum açma başarısız, hata mesajını gösterin.
                                        DispatchQueue.main.async { //Thread hatasini gidermek icin ekledim. Uyariyi gosterebilmek icin.
                                            self.alert(title: "Hata", message: errorMessage)
                                        }
                                    }
                                }
                            }
                        }
                    } catch {
                        // JSON parsing hatası durumunda burası çalışacak ve hata mesajı yazdırılacak.
                        print("JSON parsing error: \(error)")
                        
                    }
                }
                task.resume()
            }
        }
    }
    
    func processStockData(_ items: [[String: Any]]) {
        // Stok verilerini işliyoruz burda
        
        var portfolioItems: [Stock] = []
        
        for item in items { // "items" dizisindeki her bir öğeyi döngüyle kontrol ediyoruz.
          //  Symbol, quantity ve price değerleri kontrol edilerek doğru türde veri almaya çalışıyoruz
            if let symbol = item["Symbol"] as? String,
               let quantity = item["Qty_T2"] as? Double,
               let price = item["LastPx"] as? Double {
                
                // Oluşturduğumuz stok öğesini "portfolioItems" dizisine ekliyoruz.
            let stockItem = Stock(symbol: symbol, quantity: quantity, price: price)
                portfolioItems.append(stockItem)
            }
        }
        self.stock = portfolioItems // Diziye verileri ekledik
        
        DispatchQueue.main.async {
            // Burada portfolioItems dizisini kullanarak verileri görsel olarak ekranda gösteriyoruz.
            // Ayrıca, Toplam Tutar hesaplamasını yapıp  ekrana yazdırırız
            self.calculateAndDisplayTotalAmount(portfolioItems: portfolioItems)
            self.myTableView.reloadData() // Tabloyu güncelliyoruz
        }
    }
    func formatNumber(_ number: Double) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = "."
        numberFormatter.decimalSeparator = ","
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: number))
    }
    
    
    func calculateAndDisplayTotalAmount(portfolioItems: [Stock]) {
        //Hesapla veToplam Tutarı Görüntüle
        var totalAmount: Double = 0.0
        
        for item in portfolioItems {
            totalAmount += item.amount
        }
        
        if let formatTotalAmount = formatNumber(totalAmount) {
            totalLabel.text = "Toplam Tutar: \(formatTotalAmount)"
        }
    }
    
    func alert(title: String, message: String) {
        let uyariMesaji = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default) { (UIAlertAction) in
            print("ok button tıklandı")
        }
        uyariMesaji.addAction(okButton)
        self.present(uyariMesaji, animated: true)
    }
}

extension PortfoyViewController:
    UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stock.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        headerView.backgroundColor = UIColor(red: 254.0 / 255.0, green: 187.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
        
        let titleLabel1 = UILabel(frame: CGRect(x: 15, y: 5, width: tableView.frame.width / 4, height: 20))
        titleLabel1.text = "Menkul"
        titleLabel1.textColor = UIColor.white
        titleLabel1.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        headerView.addSubview(titleLabel1)
        
        let titleLabel2 = UILabel(frame: CGRect(x: titleLabel1.frame.maxX, y: 5, width: tableView.frame.width / 4, height: 20))
        titleLabel2.text = "Miktar T2"
        titleLabel2.textColor = UIColor.white
        titleLabel2.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        headerView.addSubview(titleLabel2)
        
        let titleLabel3 = UILabel(frame: CGRect(x: titleLabel2.frame.maxX, y: 5, width: tableView.frame.width / 4, height: 20))
        titleLabel3.text = "Fiyat"
        titleLabel3.textColor = UIColor.white
        titleLabel3.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        headerView.addSubview(titleLabel3)
        
        let titleLabel4 = UILabel(frame: CGRect(x: titleLabel3.frame.maxX, y: 5, width: tableView.frame.width / 4, height: 20))
        titleLabel4.text = "Tutar"
        titleLabel4.textColor = UIColor.white
        titleLabel4.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        headerView.addSubview(titleLabel4)
        
        
        return headerView
    }
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PortfoyTableViewCell", for: indexPath) as! PortfoyTableViewCell
        let stockItem = stock[indexPath.row]
        cell.symbolLabel.text = stockItem.symbol
        cell.quantityLabel.text = "\(stockItem.quantity)"
        cell.quantityLabel.text = formatNumber(stockItem.quantity)
        cell.priceLabel.text = "\(stockItem.price)"
        cell.priceLabel.text = formatNumber(stockItem.price)
        cell.amountLabel.text = "\(stockItem.amount)"
        cell.amountLabel.text = formatNumber(stockItem.amount)
        return cell
    }
}
