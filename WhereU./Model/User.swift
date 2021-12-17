//
//  User.swift
//  WhereU.
//
//  Created by be RUPU on 17/12/21.
//

import Foundation

struct User {
    let uid: String?
    let username: String?
    let profileImageUrl: String?
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImgaeUrl"] as? String ?? ""
    }
}

