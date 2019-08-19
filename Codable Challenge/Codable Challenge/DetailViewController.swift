//
//  DetailViewController.swift
//  Codable Challenge
//
//  Created by klau5 on 20/08/19.
//  Copyright © 2019 klau5. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    var selectedPhoto: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let photoToLoad = selectedPhoto {
            imageView.image = UIImage(named: photoToLoad)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
