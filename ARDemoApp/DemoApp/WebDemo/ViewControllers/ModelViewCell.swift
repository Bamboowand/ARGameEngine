//
//  ModelViewCell.swift
//  DemoApp
//
//  Created by ChenWei on 2020/5/18.
//  Copyright © 2020 Jacob. All rights reserved.
//

import UIKit

class ModelViewCell: UICollectionViewCell {
    @IBOutlet weak var modelView: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    private(set) var isDownload: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
    }
    
    func getWebImage(name: String) {
        if let image = APIManager.ModelDictionary[name]?.photo {
            DispatchQueue.main.async { [weak self] in
                self?.modelView.image = image
                self?.activityView.stopAnimating()
                self?.activityView.isHidden = true
            }
            return
        }
        
        let download = APIManager.ServerURL.appendingPathComponent(name + ".usdz")
        
        if isDownload {
            return
        }
        
        isDownload = true
        DispatchQueue.global(qos: .utility).async {
            APIManager.DownloadUSDZFromURL(download) { virtualObject in
                DispatchQueue.main.async { [weak self] in
                    APIManager.ModelDictionary.updateValue(virtualObject, forKey: virtualObject.modelName)
                    self?.modelView.image = virtualObject.photo!
                    self?.activityView.stopAnimating()
                    self?.activityView.isHidden = true
                }
            }
        }

    }
}
