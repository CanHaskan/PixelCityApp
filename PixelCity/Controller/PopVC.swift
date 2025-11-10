//
//  PopVC.swift
//  PixelCity
//
//  Created by Can Haskan on 10.11.2025.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    
    var passedImage: UIImage!
    var passedAuthorName: String!
    var passedDescription: String!
    var authorLabel: UILabel!
    var descriptionLabel: UILabel!
    
    func initData(forImage image: UIImage, authorName: String, description: String) {
        self.passedImage = image
        self.passedAuthorName = authorName
        self.passedDescription = description
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
        setupLabels()
        addDoubleTap()
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    func setupLabels() {
        
        authorLabel = UILabel()
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        authorLabel.textColor = .white
        authorLabel.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        authorLabel.textAlignment = .left
        authorLabel.text = "👤 Author: \(passedAuthorName!)"
        view.addSubview(authorLabel)
        
        descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        descriptionLabel.textColor = .white
        descriptionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0 // Çoklu satır desteği
        descriptionLabel.text = "Description: \(passedDescription!)"
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            authorLabel.leadingAnchor.constraint(equalTo: popImageView.leadingAnchor, constant: 10),
            authorLabel.trailingAnchor.constraint(equalTo: popImageView.trailingAnchor, constant: -10),
            authorLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            authorLabel.heightAnchor.constraint(equalToConstant: 25),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: popImageView.leadingAnchor, constant: 10),
            descriptionLabel.topAnchor.constraint(equalTo: popImageView.topAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: popImageView.trailingAnchor, constant: -10),
            descriptionLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 50) // Maksimum yükseklik
        ])
    }
    
    @objc func screenWasDoubleTapped() {
        dismiss(animated: true, completion: nil)
    }

}
