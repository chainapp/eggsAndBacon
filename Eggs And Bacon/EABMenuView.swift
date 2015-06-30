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
    var       isShow:Bool = false
    var       constraintTop:NSLayoutConstraint?
    @IBOutlet weak var buttonSendFeedBack: UIButton!
    @IBOutlet weak var buttonShareApp: UIButton!
    
    class func instanceFromNib() -> EABMenuView {
        return UINib(nibName: "EABMenuView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! EABMenuView
    }
    
    func setConstraintTopMenu(constraint:NSLayoutConstraint!)
    {
        self.constraintTop = constraint
        self.superview?.layoutIfNeeded()
    }
    
    func hideMenu()
    {
        self.isShow = false
        self.constraintTop?.constant = -self.bounds.size.height
    }
    
    func showMenu()
    {
        self.isShow = true
        self.constraintTop?.constant = 0
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
