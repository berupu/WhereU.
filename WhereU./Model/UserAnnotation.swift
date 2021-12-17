//
//  UserAnnotation.swift
//  WhereU.
//
//  Created by be RUPU on 17/12/21.
//

import MapKit

struct UserAnnotation {
    
    let annotationTitle: String?
    let distance: Int?
    
    
    init(anno : String, dis: Int) {
        annotationTitle = anno
            distance  = dis
    }
}

