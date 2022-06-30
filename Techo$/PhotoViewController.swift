//
//  PhotoViewController.swift
//  Techo$
//
//  Created by Yue Yan on 4/5/2022.
//

import UIKit
import CoreData

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageView: UIImageView?
    var scrollView: UIScrollView?
    weak var databaseController: DatabaseProtocol?
    var indicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Add a loading indicator view
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)

        NSLayoutConstraint.activate([ indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor), indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)])
        
        // remove titlefor back button
        setupNavigationBar()
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue, let scrollView = scrollView else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let imageView = imageView else{return}
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func takePhoto(){
        let controller = UIImagePickerController()
        controller.allowsEditing = false
        controller.delegate = self
        
        let actionSheet = UIAlertController(title: nil, message: "Select Option:", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
            controller.sourceType = .camera
            self.present(controller, animated: true, completion: nil)
        }
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
            controller.sourceType = .photoLibrary
            self.present(controller, animated: true, completion: nil)
        }
        
        let albumAction = UIAlertAction(title: "Photo Album", style: .default) { action in
            controller.sourceType = .savedPhotosAlbum
            self.present(controller, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) { actionSheet.addAction(cameraAction)
        }
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(albumAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func savePhoto() async -> ImageMetaData? {
        guard let imageView = imageView, let image = imageView.image else {
            return nil
        }
        let filename = "\(UUID()).jpg"
        
        guard let data = image.jpegData(compressionQuality: 0.8) else { displayMessage(title: "Error", message: "Image data could not be compressed")
            return nil
        }
        let pathsList = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = pathsList[0]
        let imageFile = documentDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: imageFile)
            print(filename)
            let result = await databaseController?.uploadImages(filename: filename)
            return result
        } catch {
            displayMessage(title: "Error", message: "\(error)")
            return nil
        }
    }
    

}
