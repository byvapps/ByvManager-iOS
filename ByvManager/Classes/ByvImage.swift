//
//	ByvImage.swift
//
//	Create by Koldo Ruiz on 5/6/2017
//	Copyright © 2017. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import UIKit
import SwiftyJSON
import AlamofireImage
import BvImages

public struct ByvImageMeta {
    
    public var json: JSON
    
    public lazy var channels: Int = {
        return self.json["channels"].intValue
    }()
    public lazy var density: Int = {
        return self.json["density"].intValue
    }()
    public lazy var depth : String = {
        return self.json["depth"].stringValue
    }()
    public lazy var format : String = {
        return self.json["format"].stringValue
    }()
    public lazy var hasAlpha : Bool = {
        return self.json["hasAlpha"].boolValue
    }()
    public lazy var hasProfile : Bool = {
        return self.json["format"].boolValue
    }()
    public lazy var height : Int = {
        return self.json["height"].intValue
    }()
    public lazy var space : String  = {
        return self.json["space"].stringValue
    }()
    public lazy var width : Int = {
        return self.json["width"].intValue
    }()
    
    public init(from json: JSON){
        self.json = json
    }
}


public class ByvImage : NSObject, NSCoding {
    
    public var json: JSON
    
    public lazy var createdAt: String = {
        return self.json["createdAt"].stringValue
    }()
    public lazy var id: Int = {
        return self.json["id"].intValue
    }()
    public lazy var meta: ByvImageMeta = {
        return ByvImageMeta(from: self.json["meta"])
    }()
    public lazy var isSecure : Bool = {
        return self.json["secure"].boolValue
    }()
    public lazy var name: String = {
        return self.json["name"].stringValue
    }()
    public lazy var updatedAt: String = {
        return self.json["updatedAt"].stringValue
    }()
    public lazy var defaultUrl: String = {
        return self.json["url"].stringValue
    }()
    public lazy var sizes: JSON = {
        return self.json["urls"]
    }()
    
    public var base64: String? {
        get {
            if let url = sizes["base64"]["url"].string {
                return self.secureUrl(url)
            }
            return nil
        }
    }
    
    public var urlStr: String {
        get {
            return self.secureUrl(self.optimalSize()["url"].stringValue)
        }
    }
    
    public var url: URL? {
        get {
            return URL(string: self.urlStr)
        }
    }
    
    public var size: CGSize {
        get {
            return CGSize(width:self.meta.width, height:self.meta.height)
        }
    }
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    public init(from json: JSON) {
        self.json = json
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required public init(coder aDecoder: NSCoder)
    {
        if let rawJsonString = aDecoder.decodeObject(forKey: "jsonStr") as? String {
            self.json = JSON(parseJSON: rawJsonString)
        } else {
            self.json = [:]
        }
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    public func encode(with aCoder: NSCoder)
    {
        if let jsonStr = json.rawString() {
            aCoder.encode(jsonStr, forKey: "jsonStr")
        }
    }
    
    public func optimalSize() -> JSON {
        var response = JSON(["url":self.defaultUrl,
                             "w": self.meta.width,
                             "h": self.meta.height])
        
        if UIScreen.main.scale <= 2 && !self.sizes["200X"].isEmpty {
            response = self.sizes["200X"]
        } else if !self.sizes["300X"].isEmpty {
            response = self.sizes["300X"]
        }
        
        return response
    }
    
    public func secureUrl(_ url:String) -> String {
        if self.isSecure, let at = Credentials.current()?.access_token {
            return "\(url)?access_token=\(at)"
        }
        return url
    }
}

extension BvWebImageView {
    
    public func setBvImage(_ bvImage:ByvImage, blur:UIBlurEffectStyle? = .light, showProgressbar:Bool = false, autoload:Bool = true) {
        self.urlStr = Environment.absoluteUrl(bvImage.urlStr)
        let imageDownloader = af_imageDownloader ?? UIImageView.af_sharedImageDownloader
        let imageCache = imageDownloader.imageCache
        if let urlStr = self.urlStr, let url = URL(string: urlStr), let cachedImage = imageCache?.image(for: URLRequest(url: url), withIdentifier: nil) {
            self.image = cachedImage
            return
        }
        
        var blurImage:UIImage? = nil
        if let base64Str = bvImage.base64, let data = Data(base64Encoded: base64Str) {
            blurImage = UIImage(data: data)
        }
        var mask:BvProgressMask!
        if showProgressbar {
            mask = BarProgressMask(placeholder:image, blur:blur)
        } else {
            mask = BlurMask(placeholder: blurImage, blur:blur)
        }
        
        self.setProgressMask(mask)
        if autoload {
            self.loadImage()
        }
    }
    
}
