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
        
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 44
//        tableView.reloadData()
        
        // add camera icon to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addNewImage))
        
        loadData()
    }
    
    // save user data with Codable (JSON)
    func saveData() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(users) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "users")
        } else {
            let failedSaveAlert = UIAlertController(title: "Warning!", message: "Failed to save Data", preferredStyle: UIAlertController.Style.alert)
            present(failedSaveAlert, animated: true)
        }
    }
    
    // retrieve user data
    func loadData() {
        let defaults = UserDefaults.standard
        if let savedUsers = defaults.object(forKey: "users") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                users = try jsonDecoder.decode([User].self, from: savedUsers)
            } catch {
                let failedDataRetrieval = UIAlertController(title: "Warning!", message: "Failed to Load Data", preferredStyle: UIAlertController.Style.alert)
                present(failedDataRetrieval, animated: true)
            }
        }
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
    
        guard let photo = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = photo.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        // stores image name in User object and gives default name Unknown
        let user = User(caption: "rename", image: imageName)
        users.append(user)
        tableView.reloadData()
        
        dismiss(animated: true)
        saveData() // save image
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
    
    // allow user to change image caption fron "Unknown"
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        let alertController = UIAlertController(title: "Rename", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak alertController] _ in
            guard let newCaption = alertController?.textFields?[0].text else {return}
            user.caption = newCaption
            
            self?.tableView.reloadData()
            self?.saveData()
        })
        present(alertController, animated: true)
    }
    
    // Verify and request Authorisation for camera capture
    func accessCamera() {
        let cameraAuthorisation = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorisation {
            
        case .notDetermined:
            requestCameraPermission()
        case .restricted, .denied:
            permissionsAlert()
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
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        
        let alert = UIAlertController(title: "Codable Challenge Would Like to Access the Camera", message: "This app needs access to the camera to take photos.", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Don't Allow", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) -> Void in UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }


}

