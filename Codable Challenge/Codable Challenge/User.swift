//
//  User.swift
//  Codable Challenge
//
//  Created by klau5 on 19/08/19.
//  Copyright © 2019 klau5. All rights reserved.
//

import UIKit

class User: NSObject, Codable {
    var caption: String
    var image: String

    init(caption: String, image: String) {
        self.caption = caption
        self.image = image
    }

}

