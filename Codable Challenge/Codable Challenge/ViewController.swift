//
//  ViewController.swift
//  Codable Challenge
//
//  Created by klau5 on 19/08/19.
//  Copyright © 2019 klau5. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add camera icon to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addNewImage))
    }
    
    // get new image from camera
    @objc func addNewImage() {
        let newImage = UIImagePickerController()
        newImage.sourceType = .camera
        newImage.allowsEditing = true
        newImage.delegate = self
        present(newImage, animated: true)
    }
    
    // access user Documents folder
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // write image from camera into the Documents folder as JPEG with unique UUID
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        accessCamera()
        
        guard let photo = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = photo.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        // stores image name in User object and gives default name Unknown
        let user = User(caption: "Unknown", image: imageName)
        users.append(user)
        tableView.reloadData()
        
        dismiss(animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? TableViewCell else {
                fatalError("Unable to dequeue TableViewCell")
        }
        
        let user = users[indexPath.row]
        
        cell.name.text = user.caption
        
        let path = getDocumentsDirectory().appendingPathComponent(user.image)
        cell.imageView?.image = UIImage(contentsOfFile: path.path)
        
        return cell
    }
    
    // Verify and request Authorisation for camera capture
    func accessCamera() {
        let cameraAuthorisation = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorisation {
            
        case .notDetermined:
            requestCameraPermission()
        case .restricted, .denied:
            return
        case .authorized:
            addNewImage()
        @unknown default:
            fatalError("Permission Denied")
        }
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                self.addNewImage()
            }
        }
    }
    
    func permissionsAlert() {
        let alert = UIAlertController(title: "Request Camera Access", message: "Camera access is required to make full use of the app.", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }


}

