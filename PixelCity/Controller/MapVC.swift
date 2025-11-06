//
//  MapVC.swift
//  PixelCity
//
//  Created by Can Haskan on 29.10.2025.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    
    var locationManager = CLLocationManager()
    let authorationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    var screenSize = UIScreen.main.bounds
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    
    var collectionView: UICollectionView?
    var flowLayout = UICollectionViewFlowLayout()
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        pullUpView.addSubview(collectionView!)
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp() {
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown() {
        cancelAllSessions()
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.style = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLbl() {
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width / 2) - 120, y: 175, width: 240, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 18)
        progressLbl?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLbl?.textAlignment = .center
        collectionView?.addSubview(progressLbl!)
        
    }
    
    func removeProgressLbl() {
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
    }
    
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authorationStatus == .authorizedAlways || authorationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9647058824, green: 0.6509803922, blue: 0.137254902, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2.0 , longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()
        removeSpinner()
        removeProgressLbl()
        cancelAllSessions()
        
        imageUrlArray = []
        imageArray = []
        
        collectionView?.reloadData()
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLbl()
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        unsplashSearchUrl(withAnnotation: annotation, andNumberOfPhotos: 40) { (finalApiUrl) in
                print("Final Unsplash API URL'si: \(finalApiUrl)")
            }
        
        let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        // 🚨 YENİ TEST AKIŞI: retrieveUrls başarılı olursa retrieveImages'ı başlat
        retrieveUrls(forAnnotation: annotation) { (urlsFinished) in
            if urlsFinished {
                print("DEBUG AKIŞI: URL'ler çekildi, şimdi görseller indirilmeye başlıyor...")
                
                self.retrieveImages(handler: { (imagesFinished) in
                    if imagesFinished {
                        self.removeSpinner()
                        self.removeProgressLbl()
                        self.collectionView?.reloadData()
                        print("DEBUG AKIŞI: Tüm görseller başarıyla indirildi. Collection View yenilenecek.")
                    }
                })
            } else {
                self.removeSpinner()
                self.removeProgressLbl()
                print("HATA: URL çekme işlemi başarısız oldu, indirme başlatılamadı.")
            }
        }

    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool) -> ()) {
        unsplashSearchUrl(withAnnotation: annotation, andNumberOfPhotos: 40) { (finalApiUrl) in
            
            print("DEBUG: Oluşturulan API URL'si: \(finalApiUrl)") // 💡 DEBUG EKLENDİ: URL kontrolü
            
            AF.request(finalApiUrl).responseJSON { (response) in
                
                guard case let .success(jsonValue) = response.result,
                      let json = jsonValue as? Dictionary<String, AnyObject>,
                      let photoArray = json["results"] as? [Dictionary<String, AnyObject>] else {
                    print("HATA: API isteği başarısız oldu veya JSON yapısı hatalı.")
                    handler(false)
                    return
                }
                
                self.imageUrlArray = [] // Önceki URL'leri temizle
                
                for photo in photoArray {
                    if let urls = photo["urls"] as? Dictionary<String, AnyObject>,
                       let regularUrl = urls["regular"] as? String {
                        self.imageUrlArray.append(regularUrl)
                        // print("DEBUG: Çekilen URL: \(regularUrl)") // Çok fazla çıktı olmaması için bunu şimdilik kapalı tutalım
                    }
                }
                
                print("DEBUG: Toplam \(self.imageUrlArray.count) adet fotoğraf URL'si başarıyla çekildi.") // 💡 DEBUG EKLENDİ: Sayı kontrolü
                handler(true) // URL'leri çekme işlemi bitti
            }
        }
    }

    func retrieveImages(handler: @escaping (_ status: Bool) -> ()) {
        // Dizideki her URL için indirme işlemini başlat
        for url in imageUrlArray {
            
            // AF.request kullanarak URL'den görseli indir
            AF.request(url).responseImage(completionHandler: { (response) in
                
                // Başarılı indirme durumunda görseli al
                guard let image = response.value else {
                    print("HATA: Görsel URL'sinden resim indirilemedi: \(url)")
                    
                    // İndirilemeyen URL'ye rağmen kontrolü tamamlamamız gerekiyor
                    if self.imageArray.count == self.imageUrlArray.count {
                        handler(true)
                    }
                    return
                }
                
                self.imageArray.append(image)
                // 💡 TEST AMAÇLI print
                print("İNDİRİLİYOR: \(self.imageArray.count). görsel indirildi. Toplam \(self.imageUrlArray.count) görsel bekleniyor.")
                            
                self.progressLbl?.text = "\(self.imageArray.count)/\(self.imageUrlArray.count) GÖRSEL İNDİRİLDİ"
                
                // İlerleme etiketini güncelle
                self.progressLbl?.text = "\(self.imageArray.count)/\(self.imageUrlArray.count) GÖRSEL İNDİRİLDİ"
                
                // Görsel indirildikçe Collection View'ı anlık yenile (Bir sonraki adımda etkinleşecek)
                self.collectionView?.reloadData()
                
                // Tüm görseller indirildiğinde (indirme başarılı/başarısız fark etmeksizin) handler'ı çağır
                if self.imageArray.count == self.imageUrlArray.count {
                    handler(true)
                }
            })
        }
    }
    
    func cancelAllSessions() {
        AF.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
        }
    }
    

}

extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        if authorationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {return UICollectionViewCell()}
        let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        return cell
    }
}

