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

enum messageStatus: String {
    case notShaked = "Your daily breakfast has arrived!\nShake to eat it ..."
    case Shaked = "Et voilà !\nSee you tomorrow at breakfast time ..."
}

class ViewController: UIViewController {
    
    @IBOutlet weak var viewTest: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    var       i:CGFloat = 19
    let       imageOriginal:UIImage = UIImage(named: "model")!
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
        var img:UIImage = self.takeSnapshotOfView(self.photoImageView)
        self.photoImageView.image = self.blurWithGPUImageGaussian(img, pixelRadius: 20)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            let img = blurWithGPUImageGaussian(self.imageOriginal, pixelRadius: self.i)
            self.photoImageView.image = nil
            self.photoImageView.image = img
            if self.i > 0
            {
                self.i = self.i - 3
            }
        }
    }
    
    @IBAction func shareButtonAction(sender: UIButton) {
    }
    
    @IBAction func menuButtonAction(sender: UIButton) {
    }
}

