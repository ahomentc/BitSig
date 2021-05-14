////
////  CustomImageView.swift
////  BitSigApp
////
////  Created by Andrei Homentcovschi on 5/11/21.
////  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
////
//
//import UIKit
//import SGImageCache
//
//var imageCache = [String: UIImage]()
//var colorCache = [String: UIColor]()
//
//class CustomImageView: UIImageView {
//
//    private var lastURLUsedToLoadImage: String?
//
//    func loadImage(urlString: String) {
//        if let image = SGImageCache.image(forURL: urlString) {
//            DispatchQueue.main.async {
//                self.image = image   // image loaded immediately from cache
//            }
//        } else {
//            SGImageCache.slowGetImage(url: urlString) { [weak self] image in
//                DispatchQueue.main.async {
//                    self?.image = image   // image loaded immediately from cache
//                }
//            }
//        }
//    }
//
//    // use this to load images on screen (fast)
//    func loadImageWithCompletion(urlString: String, completion: @escaping () -> ()) {
//        if let image = SGImageCache.image(forURL: urlString) {
//            self.image = image   // image loaded immediately from cache
//            completion()
//        } else {
//            SGImageCache.getImage(url: urlString) { [weak self] image in
//                self?.image = image   // image loaded async
//                completion()
//            }
//        }
//    }
//
//    // use this to load image that are off screen
//    func loadImageWithCompletionSlow(urlString: String, completion: @escaping () -> ()) {
//        if let image = SGImageCache.image(forURL: urlString) {
//            self.image = image   // image loaded immediately from cache
//            completion()
//        } else {
//            SGImageCache.slowGetImage(url: urlString) { [weak self] image in
//                self?.image = image   // image loaded async
//                completion()
//            }
//        }
//    }
//
//// --- could use this somewhere if getting image fails
////    let promise = SGImageCache.getImageForURL(url)
////    promise.swiftThen({object in
////      if let image = object as? UIImage {
////          self.imageView.image = image
////      }
////      return nil
////    })
////    promise.onRetry = {
////      self.showLoadingSpinner()
////    }
////    promise.onFail = { (error: NSError?, wasFatal: Bool) -> () in
////      self.displayError(error)
////    }
//}
//
//extension CustomImageView {
//
//    class func imageWithColor(color: UIColor) -> UIImage {
//        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
//        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
//        color.setFill()
//        UIRectFill(rect)
//        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
//        UIGraphicsEndImageContext()
//        return image
//    }
//}
