//
//  ImageUploader.swift
//  Pods
//
//  Created by Adrian Apodaca on 17/1/17.
//
//

import Foundation
import Alamofire
import SwiftyJSON

public struct Uploader {
    public static func uploadFile(_ data:Data,
                           name:String,
                           ext:String,
                           mimeType:String,
                           path:String? = nil,
                           progress:((_ progress:Progress) -> Void)?,
                           completion:((_ json:JSON?) -> Void)?) {
        let fileName = "\(name).\(ext)"
        
        let parameters = [
            "file": fileName
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(data, withName: name, fileName: fileName, mimeType: mimeType)
            for (key, value) in parameters {
                if let data = value.data(using: String.Encoding.utf8) {
                    multipartFormData.append(data, withName: key)
                }
            }
        }, to:"\(Environment.baseUrl())/\(path ?? url_upload())")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progressVal) in
                    progress?(progressVal)
                })
                
                upload.responseData { responseData in
                    if let data = responseData.data {
                        completion?(JSON(data: data))
                    } else {
                        completion?(nil)
                    }
                }
                
            case .failure(let encodingError):
                print("Error uploading file: \(encodingError)")
                completion?(nil)
            }
        }
    }
    
    public static func uploadJpg(_ image:UIImage,
                                 name:String = "file",
                                 path:String? = nil,
                                 quality:CGFloat = 0.8,
                                 progress:((_ progress:Progress) -> Void)? = nil,
                                 completion:((_ json:JSON?) -> Void)?) {
        if let data = UIImageJPEGRepresentation(image, quality) {
            uploadFile(data, name: name, ext: ".jpeg", mimeType: "image/jpeg", path: path, progress: progress, completion: completion)
        } else {
            completion?(nil)
        }
    }
    
    public static func uploadPng(_ image:UIImage,
                                 name:String = "file",
                                 path:String? = nil,
                                 progress:((_ progress:Progress) -> Void)? = nil,
                                 completion:((_ json:JSON?) -> Void)?) {
        if let data = UIImagePNGRepresentation(image) {
            uploadFile(data, name: name, ext: ".png", mimeType: "image/png", path: path, progress: progress, completion: completion)
        } else {
            completion?(nil)
        }
    }
}

public extension UIImage {
    public func uploadAsJpg(name:String = "file",
                                 path:String? = nil,
                                 quality:CGFloat = 0.8,
                                 progress:((_ progress:Progress) -> Void)? = nil,
                                 completion:((_ json:JSON?) -> Void)?) {
        if let data = UIImageJPEGRepresentation(self, quality) {
            Uploader.uploadFile(data, name: name, ext: ".jpeg", mimeType: "image/jpeg", path: path, progress: progress, completion: completion)
        } else {
            completion?(nil)
        }
    }
    
    public func uploadAsPng(name:String = "file",
                                 path:String? = nil,
                                 progress:((_ progress:Progress) -> Void)? = nil,
                                 completion:((_ json:JSON?) -> Void)?) {
        if let data = UIImagePNGRepresentation(self) {
            Uploader.uploadFile(data, name: name, ext: ".png", mimeType: "image/png", path: path, progress: progress, completion: completion)
        } else {
            completion?(nil)
        }
    }
}

