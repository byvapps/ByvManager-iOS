//
//	ByvImage.swift
//
//	Create by Koldo Ruiz on 5/6/2017
//	Copyright © 2017. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import UIKit
import SwiftyJSON
import BvImages

public struct ByvImageMeta {
    
    var json: JSON
    
    lazy var channels: Int = {
        return self.json["channels"].intValue
    }()
    lazy var density: Int = {
        return self.json["density"].intValue
    }()
    lazy var depth : String = {
        return self.json["depth"].stringValue
    }()
    lazy var format : String = {
        return self.json["format"].stringValue
    }()
    lazy var hasAlpha : Bool = {
        return self.json["hasAlpha"].boolValue
    }()
    lazy var hasProfile : Bool = {
        return self.json["format"].boolValue
    }()
    lazy var height : Int = {
        return self.json["height"].intValue
    }()
    lazy var space : String  = {
        return self.json["space"].stringValue
    }()
    lazy var width : Int = {
        return self.json["width"].intValue
    }()
    
    init(from json: JSON){
        self.json = json
    }
}


public class ByvImage : NSObject, NSCoding {
    
    var json: JSON
    
    lazy var createdAt: String = {
        return self.json["createdAt"].stringValue
    }()
    lazy var id: Int = {
        return self.json["id"].intValue
    }()
    lazy var meta: ByvImageMeta = {
        return ByvImageMeta(from: self.json["meta"])
    }()
    lazy var name: String = {
        return self.json["name"].stringValue
    }()
    lazy var updatedAt: String = {
        return self.json["updatedAt"].stringValue
    }()
    lazy var defaultUrl: String = {
        return self.json["url"].stringValue
    }()
    lazy var sizes: JSON = {
        return self.json["urls"]
    }()

    var base64: String? {
        get {
            return sizes["base64"]["url"].string
        }
    }
    
    var urlStr: String {
        get {
            return self.optimalSize()["url"].stringValue
        }
    }
    
    var url: URL? {
        get {
            return URL(string: self.optimalSize()["url"].stringValue)
        }
    }
    
    var size: CGSize {
        get {
            return CGSize(width:self.meta.width, height:self.meta.height)
        }
    }

	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(from json: JSON) {
        self.json = json
	}
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required public init(coder aDecoder: NSCoder)
    {
        self.json = JSON((aDecoder.decodeObject(forKey: "jsonStr") as? String) ?? "")
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
    
    func optimalSize() -> JSON {
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
}

extension BvWebImageView {
    
    public func setBvImage(_ bvImage:ByvImage, blur:UIBlurEffectStyle? = .light, showProgressbar:Bool = false, autoload:Bool = true) {
        var image:UIImage? = nil
        if let base64Str = bvImage.base64, let data = Data(base64Encoded: base64Str) {
            image = UIImage(data: data)
        }
        var mask:BvProgressMask!
        if showProgressbar {
            mask = BarProgressMask(placeholder:image, blur:blur)
        } else {
            mask = BlurMask(placeholder: image, blur:blur)
        }
        self.setProgressMask(mask)
        self.urlStr = Environment.absoluteUrl(bvImage.urlStr)
        if autoload {
            self.loadImage()
        }
    }
    
}
