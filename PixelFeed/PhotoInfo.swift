//
//  PhotoInfo.swift
//  PixelFeed
//
//  Created by Tejaswini Shastry on 6/17/17.
//  Copyright © 2017 Tejaswini Shastry. All rights reserved.
//

import Foundation
import Alamofire

class PhotoInfo: NSObject {
    var id: String
    var sourceImageURL: URL
    var request: Alamofire.Request?
    var userHasLiked: Bool
    
    init(sourceImageURL: URL, id: String, userHasLiked:Bool ) {
        self.sourceImageURL = sourceImageURL
        self.id = id
        self.userHasLiked = userHasLiked
        super.init()
    }
    
    func sourceImageURL(withFormatName formatName: String!) -> URL! {
        return sourceImageURL
    }
    
    
    
}
