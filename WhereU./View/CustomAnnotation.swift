//
//  CustomAnnotation.swift
//  WhereU.
//
//  Created by be RUPU on 17/12/21.
//

import UIKit

class CustomAnnotationView: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .cyan
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

