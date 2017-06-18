//
//  CircleView.swift
//  devslopes-social
//
//  Created by Hung Nguyen on 6/16/17.
//  Copyright © 2017 Luvdub Nation. All rights reserved.
//

import UIKit

class CircleView: UIImageView {
    
    override func layoutSubviews() {
        layer.cornerRadius = self.frame.width / 2
    }

    
    
}
