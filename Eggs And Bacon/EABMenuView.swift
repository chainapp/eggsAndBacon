//
//  EABMenuView.swift
//  Eggs And Bacon
//
//  Created by Werck Ayrton on 24/06/2015.
//  Copyright (c) 2015 Nyu Web Developpement. All rights reserved.
//

import UIKit

class EABMenuView: UIView {

    
    @IBOutlet weak var segmentedIndexType: UISegmentedControl!
    
    class func instanceFromNib() -> EABMenuView {
        return UINib(nibName: "EABMenuView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! EABMenuView
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
