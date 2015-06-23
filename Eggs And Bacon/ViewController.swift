//
//  ViewController.swift
//  Eggs And Bacon
//
//  Created by Romain Arsac on 23/06/2015.
//  Copyright (c) 2015 Nyu Web Developpement. All rights reserved.
//

import UIKit

enum messageStatus: String {
    case notShaked = "Your daily breakfast has arrived!\nShake to eat it ..."
    case Shaked = "Et voilà !\nSee you tomorrow at breakfast time ..."
}

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // titleLabel
        self.titleLabel.font = UIFont(name: "Satisfy", size: 35)
        
        // messageLabel
        self.messageLabel.text = messageStatus.notShaked.rawValue
        self.messageLabel.font = UIFont(name: "Satisfy", size: 23)
        
        // shareButton
        self.shareButton.titleLabel?.font = UIFont(name: "Satisfy", size: 13)
        self.shareButton.layer.cornerRadius = 6
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func shareButtonAction(sender: UIButton) {
    }

    @IBAction func menuButtonAction(sender: UIButton) {
    }
}

