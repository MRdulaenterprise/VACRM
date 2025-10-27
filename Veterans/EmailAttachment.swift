//
//  EmailAttachment.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import Foundation

struct EmailAttachment {
    let fileName: String
    let contentType: String
    let data: Data
    
    var base64Content: String {
        return data.base64EncodedString()
    }
}
