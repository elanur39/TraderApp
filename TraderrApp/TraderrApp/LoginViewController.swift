//
//  LoginViewController.swift
//  TraderrApp
//
//  Created by ELANUR KIZILAY on 29.07.2023.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var myImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Iamge
        myImage.layer.cornerRadius = myImage.bounds.height / 5 // UIImageView'in şeklini yuvarlatma (dairesel yapma)
        myImage.layer.borderWidth = 2.0// UIImageView'e kenarlık (border) eklemek
        myImage.layer.borderColor = UIColor.purple.cgColor
        myImage.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        //Button
        loginButton.setTitleColor(UIColor.white, for: .normal) // UIButton'un metin rengini değiştirmepr
        loginButton.layer.cornerRadius = loginButton.bounds.height / 2 // UIButton'un şeklini yuvarlatma (dairesel yapma)
        loginButton.layer.cornerRadius = 10 // Köşeleri yuvarlatma
        loginButton.layer.borderWidth = 1 // Kenarlık kalınlığı
        loginButton.layer.borderColor = UIColor.purple.cgColor // Kenarlık rengi
        
        //Klavye
        let gesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(gesture)
        
    }
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
    // 1 Uyarı Mesajı Fonksiyonu Oluşturalım
    func alert(title: String, message: String) {
        let uyariMesaji = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default) { (UIAlertAction) in
            print("ok button tıklandı")
        }
        uyariMesaji.addAction(okButton)
        self.present(uyariMesaji, animated: true)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        // 2 Oluşturduğumuz uyarı fonksiyonunu burada işleme sokalım
        guard let girilenKullaniciAdi = usernameText.text, !girilenKullaniciAdi.isEmpty, let girilenSifre = passwordText.text, !girilenSifre.isEmpty else {
            alert(title: "Hata", message: "Lütfen Kullanıcı adı ve şifre giriniz")
            return
        }
        login(username: girilenKullaniciAdi, password: girilenSifre)
    }
    // 3 API işlemleri için bir login fonksiyonu oluşturalım
    
    func login(username: String, password: String) {
        // API işlemleri
        let apiURLString = "https://tbpilot.matriksdata.com/9999/Integration.aspx?MsgType=A&CustomerNo=0&Username=\(username)&Password=\(password)&AccountID=0&ExchangeID=4&OutputType=2"
        
        
        guard let apiURL = URL(string: apiURLString) else {
            return // Burada apiURLString adlı nesneyi ULR ye dönüştürerek apiURL adınde bir url  elde etmeye çalışıyoruz. Başarılı olursa apiURL değişkeni kullanılır.Eğer işlem başarısız olursa işlem devam etmez
        }
        var urlRequest = URLRequest(url: apiURL)
        urlRequest.httpMethod = "GET"
        
        // URLSession ile API çağrısını yapıyoruz.
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard let self = self else { return }
            // Burada closure içinde kullanılan self referansı [weak self] şeklinde zayıf hale getirerek bu referansın nil olup olmadığı kontrol ediliyor
            // Hata kontrolü yapalım.
            if let error = error {
                self.alert(title: "Hata", message: error.localizedDescription)
                return
            }
            
            // Veri dönüşümü ve işleme işlemlerini gerçekleştirelim.
            if let data = data {
                if let apiResponse = self.parseApiResponse(data: data) {
                    // API cevabını işleyelim.
                    self.handleApiResponse(responseData: apiResponse)
                } else {
                    self.alert(title: "Hata", message: "API cevabı işlenemedi.")
                }
            } else {
                self.alert(title: "Hata", message: "Boş API cevabı.")
            }
        }
        
        // API çağrısını başlatıyoruz.
        task.resume()
    }
    
    func parseApiResponse(data: Data) -> [String: Any]? {
        do {
            // JSON verisini çözümle.
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return json
            }
        } catch {
            print("JSON çözümleme hatası: \(error)")
        }
        return nil
    }
    
    func handleApiResponse(responseData: [String: Any]) {
        // API cevabını işleme işlemlerini burada yapabiliriz
        if let result = responseData["Result"] as? NSDictionary {
            if let state = result["State"] as? Bool {
                if state {
                    if let accountNumber = responseData["DefaultAccount"] as? String {
                        // Oturum açma başarılı, hesap numarasını saklayabilir veya işlem yapabiliriz
                        DispatchQueue.main.async { //Thread hatasini gidermek icin ekledim.
                            // Örneğin, porföy ekranına geçiş yapabilirsiniz.
                            APPDELEGATE?.defaultAccount = accountNumber
                            APPDELEGATE?.userName = self.usernameText.text
                            APPDELEGATE?.password = self.passwordText.text
                            self.performSegue(withIdentifier: "PortfoyVC", sender: nil)
                        }
                        
                        print("Oturum açma başarılı, hesap numarası: \(accountNumber)")
                    }
                } else {
                    if let errorMessage = result["Description"] as? String {
                        // Oturum açma başarısız, hata mesajını gösterin.
                        DispatchQueue.main.async { //Thread hatasini gidermek icin ekledim. Uyariyi gosterebilmek icin.
                            self.alert(title: "Giriş başarısız.", message: errorMessage)
                        }
                    }
                }
            }
        }
    }
    

}
