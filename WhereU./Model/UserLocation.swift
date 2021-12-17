//
//  UserLocation.swift
//  WhereU.
//
//  Created by be RUPU on 17/12/21.
//

import Foundation

struct UserLocation {
    
    let uid: String?
    let username: String?
    let profileImageUrl: String?
    let latitude : Double?
    let longitude : Double?
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.latitude = dictionary["latitude"]  as? Double ?? 0.0
        self.longitude = dictionary["longitude"] as? Double ?? 0.0
    }
}
