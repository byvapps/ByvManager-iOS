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
                           progress:((_ progress:Progress) -> Void)?,
                           completion:((_ url:String?) -> Void)?) {
        let fileName = "\(name).\(ext)"
        
        let parameters = [
            "file": fileName
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(data, withName: name, fileName: fileName, mimeType: mimeType)
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to:"\(Environment.baseUrl())/\(url_upload())")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progressVal) in
                    progress?(progressVal)
                })
                
                upload.responseData { responseData in
                    if let data = responseData.data {
                        let json = JSON(data: data)
                        completion?(json["url"].stringValue)
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
                                 quality:CGFloat = 0.8,
                                 progress:((_ progress:Progress) -> Void)? = nil,
                                 completion:((_ url:String?) -> Void)?) {
        uploadFile(UIImageJPEGRepresentation(image, quality)!, name: name, ext: ".jpeg", mimeType: "image/jpeg", progress: progress, completion: completion)
    }
    
    public static func uploadPng(_ image:UIImage,
                                 name:String = "file",
                                 progress:((_ progress:Progress) -> Void)? = nil,
                                 completion:((_ url:String?) -> Void)?) {
        uploadFile(UIImagePNGRepresentation(image)!, name: name, ext: ".png", mimeType: "image/png", progress: progress, completion: completion)
    }
}

