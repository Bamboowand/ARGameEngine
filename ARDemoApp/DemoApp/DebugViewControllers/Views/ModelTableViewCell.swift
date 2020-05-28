//
//  ModelTableViewCell.swift
//  DemoApp
//
//  Created by ChenWei on 2020/5/26.
//  Copyright © 2020 Jacob. All rights reserved.
//

import UIKit

class ModelTableViewCell: UITableViewCell {

    var modelWidth: Float = -1.0
    var modelDepth: Float = -1.0

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    public func getImage(name: String) {
        if let image = LocalLoader.shared.models.filter({ $0.modelName == name }).first?.model?.photo {
            self.imageView?.image = image
            return
        } else {
            self.imageView?.image = UIImage(systemName: "circle")
        }
    }
}
