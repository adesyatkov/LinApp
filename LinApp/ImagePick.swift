//
//  ImagePick.swift
//  LinApp
//
//  Created by Anton on 09.04.18.
//  Copyright © 2018 Anton. All rights reserved.
//

import UIKit

extension ViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleSelectProfileImageView(){
        
       let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
       
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
            print(editedImage.size)
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
            print(originalImage.size)
        }
        
        if let selectedImage = selectedImageFromPicker{
            
            ProfileImage.image = selectedImage
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
   
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print ("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
}
