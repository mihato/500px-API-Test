//
//  PhotoCollectionViewCell.swift
//  500px API Test
//
//  Created by Michail Grebionkin on 10.02.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel?
    
    @IBOutlet var subtitleLabel: UILabel?
    
    @IBOutlet var imageView: UIImageView?

    fileprivate var shadowLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.clear.cgColor, UIColor(white: 0, alpha: 0.7).cgColor]
        layer.locations = [0, 0.5]
        return layer
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.insertSublayer(self.shadowLayer, above: self.imageView?.layer)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView?.image = nil
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        let y = self.titleLabel?.frame.origin.y ?? self.bounds.height
        self.shadowLayer.frame = CGRect(x: 0, y: y, width: self.bounds.width, height: self.bounds.height - y)
    }

}
