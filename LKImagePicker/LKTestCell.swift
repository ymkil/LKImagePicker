//
//  LKTestCell.swift
//  LKImagePicker
//
//  Created by Mkil on 11/01/2017.
//  Copyright © 2017 黎宁康. All rights reserved.
//

import UIKit

class LKTestCell: UICollectionViewCell {
    
    
    lazy var imageView: UIImageView = { [unowned self] in
        let imageView = UIImageView()
        imageView.frame = self.bounds
        imageView.backgroundColor = UIColor.init(white: 1.000, alpha: 0.500)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var deleteBtn: UIButton = { [unowned self] in
        let deleteBtn = UIButton(type: .custom)
        deleteBtn.frame = CGRect(x: self.lk_width - 36, y: 0, width: 36, height: 36)
        deleteBtn.imageEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, -10)
        deleteBtn.setImage(UIImage(named: "photo_delete"), for: .normal)
        deleteBtn.alpha = 0.6
        return deleteBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [imageView,deleteBtn].forEach {
            addSubview($0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
