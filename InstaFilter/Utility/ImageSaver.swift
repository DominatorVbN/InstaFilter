//
//  ImageSaver.swift
//  InstaFilter
//
//  Created by dominator on 28/01/20.
//  Copyright © 2020 dominator. All rights reserved.
//

import UIKit

class ImageSaver: NSObject{
    enum ImageSavingResult{
        case success
        case error(error: Error)
    }
    private var onComplete: ((_ result: ImageSavingResult)->Void)? = nil
    func saveImageToLibrary(_ image: UIImage, completion: ((_ result: ImageSavingResult)->Void)? = nil){
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
        self.onComplete = completion
    }
    
    @objc func saveError(_ image: UIImage, didFinishWithError error: Error?, contexInfo: UnsafeRawPointer){
        //save complete
        if let action = onComplete{
            if let error = error{
                action(.error(error: error))
            }else{
                action(.success)
            }
        }
    }
    
}
