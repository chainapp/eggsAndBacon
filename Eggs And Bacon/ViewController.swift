//
//  ViewController.swift
//  Eggs And Bacon
//
//  Created by Romain Arsac on 23/06/2015.
//  Copyright (c) 2015 Nyu Web Developpement. All rights reserved.
//

import UIKit
import DynamicBlurView
import GPUImage

let    MAXSHAKES:Int = 5
let    BLURRADIUSPIX:CGFloat = 20
let    MENUHEIGHT:CGFloat = 180.0
enum messageStatus: String {
    case notShaked = "Your daily breakfast has arrived!\nShake to eat it ..."
    case Shaked = "Et voilà !\nSee you tomorrow at breakfast time ..."
}

class ViewController: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    var       i:Int = 0
    let       imageOriginal:UIImage = UIImage(named: "model")!
    var       imagesBlurred:Array<UIImage> = Array<UIImage>()
    var       constraintHMenu:NSLayoutConstraint?
    var       menuView:EABMenuView?
    var       menuIsShow:Bool? = false
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // titleLabel
        // self.titleLabel.font = UIFont(name: "Satisfy", size: 35)
        
        // messageLabel
        self.messageLabel.text = messageStatus.notShaked.rawValue
        self.messageLabel.font = UIFont(name: "Satisfy", size: 23)
        // shareButton
        self.shareButton.titleLabel?.font = UIFont(name: "Satisfy", size: 13)
        self.shareButton.layer.cornerRadius = 6
        self.prepareImages()
        }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var menu:EABMenuView = EABMenuView.instanceFromNib()
        var constraintHMenu:NSLayoutConstraint = NSLayoutConstraint(item: menu, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: MENUHEIGHT)
        let constraintWMenu:NSLayoutConstraint = NSLayoutConstraint(item: menu, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self.view.bounds.size.width)
        self.constraintHMenu = constraintHMenu
        menu.setTranslatesAutoresizingMaskIntoConstraints(false)
        menu.addConstraint(constraintHMenu)
        menu.addConstraint(constraintWMenu)
        
        var height:CGFloat = self.navigationController!.navigationBar.bounds.height + UIApplication.sharedApplication().statusBarFrame.height
        
        let constraintTopMargin:NSLayoutConstraint = NSLayoutConstraint(item: menu, attribute: NSLayoutAttribute.Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant:(height - MENUHEIGHT))
        
        let constraintXMenu:NSLayoutConstraint = NSLayoutConstraint(item: menu, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        self.view.addSubview(menu)
        self.view.addConstraint(constraintTopMargin)
        self.view.addConstraint(constraintXMenu)
        
        
        self.menuView = menu
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
        var img:UIImage = self.takeSnapshotOfView(self.photoImageView)
        self.photoImageView.image = self.blurWithGPUImageGaussian(img, pixelRadius: 20)
        var menuFrame:CGRect = self.menuView!.frame
        menuFrame.origin.y -= menuFrame.size.height
        self.menuView!.frame = menuFrame
        self.menuView!.hidden = false

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Prepare Images
    
    func prepareImages()
    {
        var i:Int = 0
        var decrease:CGFloat = 0
        
        while (i < MAXSHAKES)
        {
            self.imagesBlurred.append(self.blurWithGPUImageGaussian(self.photoImageView.image!, pixelRadius: BLURRADIUSPIX - decrease))
            decrease = CGFloat(Float(decrease) + (Float(BLURRADIUSPIX) / Float(MAXSHAKES)))
            i = i + 1
        }
        self.imagesBlurred.append(self.photoImageView.image!)
    }
    
    func takeSnapshotOfView(view: UIView) -> UIImage
    {
        UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width, view.frame.size.height))
        view.drawViewHierarchyInRect(CGRectMake(0, 0, view.frame.size.width, view.frame.size.height), afterScreenUpdates: true)
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image
    }
    
    func blurWithGPUImageGaussian(image: UIImage, pixelRadius:CGFloat) -> UIImage
    {
        var  gpuBlurGaussianFilter:GPUImageGaussianBlurFilter = GPUImageGaussianBlurFilter()
        gpuBlurGaussianFilter.blurRadiusInPixels = pixelRadius
        return gpuBlurGaussianFilter.imageByFilteringImage(image)
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
        
        if motion == UIEventSubtype.MotionShake
        {
            if self.i < (self.imagesBlurred.count - 1)
            {
                println(self.i)
                self.photoImageView.image = nil
                self.photoImageView.image = self.imagesBlurred[self.i]
                self.i = self.i + 1
            }
            else
            {
                self.photoImageView.image = self.imagesBlurred.last
            }
        }
    }
    
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        
        if motion == UIEventSubtype.MotionShake
        {
            if self.i < (self.imagesBlurred.count - 1)
            {
                println(self.i)
                self.photoImageView.image = nil
                self.photoImageView.image = self.imagesBlurred[self.i]
                self.i = self.i + 1
            }
            else
            {
                self.photoImageView.image = self.imagesBlurred.last
            }
        }
    }
    
    @IBAction func shareButtonAction(sender: UIButton) {
    }
    
    @IBAction func showMenu(sender: AnyObject)
    {
        var viewMask:UIView = UIView(frame:self.menuView!.frame)
        var menuFrame:CGRect = self.menuView!.frame

        if self.menuIsShow == true
        {
            menuFrame.origin.y -= menuFrame.size.height
            self.menuIsShow = false
        }
        else
        {
            menuFrame.origin.y += menuFrame.size.height
            self.menuIsShow = true
        }
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.menuView?.frame = menuFrame
            self.view.layoutIfNeeded()
            
        })
        
        
    }
    
    @IBAction func menuButtonAction(sender: UIButton) {
    }
}

