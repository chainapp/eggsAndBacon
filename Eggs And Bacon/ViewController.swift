//
//  ViewController.swift
//  Eggs And Bacon
//
//  Created by Romain Arsac on 23/06/2015.
//  Copyright (c) 2015 Nyu Web Developpement. All rights reserved.
//

import UIKit
import GPUImage
import Parse
import MBProgressHUD
import AudioToolbox

let    MAXSHAKES:Int = 10
let    BLURRADIUSPIX:CGFloat = 20
let    MENUHEIGHT:CGFloat = 180.0

enum messageStatus: String {
    case notShaked = "Your daily breakfast has arrived!\nShake to eat it ..."
    case Shaked = "Et voilà !\nSee you tomorrow at breakfast time ..."
}

class ViewController: UIViewController, UIScrollViewDelegate, ShakeGestureProtocol {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var viewContainButton: UIView!
    @IBOutlet weak var buttonShowMenu: UIButton!
    
    var                shakeHelper:ShakeGesture?
    var                blurProgress:Int = 0
    var                imagesBlurred:Array<UIImage> = Array<UIImage>()
    var                imagesCateg:Array<Array<UIImage>> = Array<Array<UIImage>>(count: 3, repeatedValue: Array<UIImage>())
    var                 blurProgresses:[Int] = NSUserDefaults.standardUserDefaults().valueForKey("currentblurprogress") as? [Int] ?? [0, 0, 0]
    var                 alphaProgress:[CGFloat] = [0.0, 0.0, 0.0]
    var                 menuView:EABMenuView?
    var                 menuIsShow:Bool? = false
    
    //MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // titleLabel
        self.titleLabel.font = UIFont(name: "Satisfy", size: 25)
        
        // messageLabel
        self.messageLabel.text = messageStatus.notShaked.rawValue
        self.messageLabel.font = UIFont(name: "Satisfy", size: 23)
        // shareButton
        self.shareButton.titleLabel?.font = UIFont(name: "Satisfy", size: 13)
        self.shareButton.layer.cornerRadius = 6
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newData", name: "newDatas", object: nil)
        self.loadData()
        self.photoImageView.hidden = true
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    }
    
    func createMenu()
    {
        var menu:EABMenuView = EABMenuView.instanceFromNib()
        menu.buttonSendFeedBack.addTarget(self, action: "sendMailToStaff", forControlEvents: UIControlEvents.TouchUpInside)
        var constraintHMenu:NSLayoutConstraint = NSLayoutConstraint(item: menu, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: MENUHEIGHT)
        let constraintWMenu:NSLayoutConstraint = NSLayoutConstraint(item: menu, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self.view.bounds.size.width)
        menu.setTranslatesAutoresizingMaskIntoConstraints(false)
        menu.addConstraint(constraintHMenu)
        menu.addConstraint(constraintWMenu)
        
        let constraintTopMargin:NSLayoutConstraint = NSLayoutConstraint(item: menu, attribute: NSLayoutAttribute.Top, relatedBy: .Equal, toItem: self.viewContainButton, attribute: .Bottom, multiplier: 1, constant:0)
        let constraintXMenu:NSLayoutConstraint = NSLayoutConstraint(item: menu, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        self.view.addSubview(menu)
        self.view.addConstraint(constraintTopMargin)
        self.view.addConstraint(constraintXMenu)
        self.menuView = menu
        self.menuView?.constraintTop = constraintTopMargin
        self.menuView?.hideMenu()
        self.menuView?.segmentedIndexType.selectedSegmentIndex = 0
        self.menuView?.segmentedIndexType.addTarget(self, action: "valueSegmentedIndexChanged", forControlEvents: UIControlEvents.ValueChanged)
        self.view.bringSubviewToFront(self.viewContainButton)
        self.titleLabel.textColor = self.menuView?.backgroundColor
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.scrollView.delegate = self
        self.scrollView.maximumZoomScale = 10.0
        self.scrollView.contentSize = self.photoImageView.bounds.size
        self.photoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        //Create Menu
        self.createMenu()
        //Initiate shake gesture
        self.shakeHelper = ShakeGesture()
        self.shakeHelper?.delegate = self
        self.shakeHelper?.loadCoreMotion()
    }
    
    //MARK: ShakeGestureDelegate
    
    func didFindAShake() {
        var blurProg = self.blurProgresses[(self.menuView?.segmentedIndexType.selectedSegmentIndex ?? 0)]
        
        if blurProg < (self.imagesBlurred.count - 1)
        {
            println(blurProg)
            self.photoImageView.image = nil
            self.photoImageView.image = self.imagesBlurred[blurProg]
            let i:Float = 1.0/Float(MAXSHAKES)
            self.shareButton.alpha = self.shareButton.alpha + CGFloat(i)
            blurProg = blurProg + 1
            let index = (self.menuView?.segmentedIndexType.selectedSegmentIndex ?? 0)
            self.blurProgresses[index] = blurProg
            self.alphaProgress[index] = self.shareButton.alpha
           
            //Set the current blurprog and alpha to UserDefaults
            NSUserDefaults.standardUserDefaults().setValue(self.blurProgresses, forKey: "currentblurprogress")
            NSUserDefaults.standardUserDefaults().setValue(self.alphaProgress, forKey: "alphaprogress")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        else
        {
            self.photoImageView.image = self.imagesBlurred.last
            self.shareButton.alpha = 1
        }
    }
    
    //Mark: Func update UI
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.photoImageView
    }
    
    func updateUI()
    {
        self.valueSegmentedIndexChanged()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Load data
    
    func newData()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.loadData()
        })
    }
    
    func initDatasFromResults(results: Array<PFObject>?, images: Array<UIImage>?)
    {
        let arrPFO = results as Array<PFObject>!
        let imgs = images as Array<UIImage>!
        
        var i:Int = 0
        while (i < arrPFO.count)
        {
            let o:PFObject = arrPFO[i]
            if o.objectForKey("category") as? String == "Eggs"
            {
                self.imagesCateg[0] = self.prepareImages(imgs[i])
            }
            else if o.objectForKey("category") as? String == "Both"
            {
                self.imagesCateg[1] = self.prepareImages(imgs[i])
            }
            else
            {
                self.imagesCateg[2] = self.prepareImages(imgs[i])
            }
            i = i + 1
        }
        self.imagesBlurred = self.imagesCateg[0]
        self.updateUI()
    }
    
    func loadData()
    {
        ManagedPFObject.getLocalDailyPictures { (results, images, error) -> () in
            println(images)
            
            //Init Blur and Alpha progress to their saved value
            self.blurProgresses = NSUserDefaults.standardUserDefaults().valueForKey("currentblurprogress") as? [Int] ?? [0, 0, 0]
            self.alphaProgress =            NSUserDefaults.standardUserDefaults().valueForKey("alphaprogress") as? [CGFloat] ?? [0.0, 0.0, 0.0]
            if results != nil && images != nil
            {
                self.initDatasFromResults(results, images: images)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.photoImageView.hidden = false
            }
            else
            {
                ManagedPFObject.getDailyPictures { (results, images, error) -> () in
                    //Reset blur progress and alphaprogress
                    self.blurProgresses = [0, 0, 0]
                    self.alphaProgress = [0.0, 0.0, 0.0]
                    //println(results)
                    println(images)
                    if results != nil && images != nil
                    {
                        self.initDatasFromResults(results, images: images)
                    }
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.photoImageView.hidden = false
                }
            }
        }
    }
    
    //MARK: Process Images
    
    func prepareImages(baseImg:UIImage!) -> Array<UIImage>
    {
        var lRet:Array<UIImage> = Array<UIImage>()
        var i:Int = 0
        var decrease:CGFloat = 0
        
        while (i < MAXSHAKES)
        {
            lRet.append(self.blurWithGPUImageGaussian(baseImg!, pixelRadius: BLURRADIUSPIX - decrease))
            decrease = CGFloat(Float(decrease) + (Float(BLURRADIUSPIX) / Float(MAXSHAKES)))
            i = i + 1
        }
        lRet.append(baseImg)
        return lRet
    }
    
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
    
    func blurWithGPUImageGaussian(image: UIImage!, pixelRadius:CGFloat) -> UIImage
    {
        var  gpuBlurGaussianFilter:GPUImageGaussianBlurFilter = GPUImageGaussianBlurFilter()
        gpuBlurGaussianFilter.blurRadiusInPixels = pixelRadius
        return gpuBlurGaussianFilter.imageByFilteringImage(image)
    }
    
    //MARK: Action
    
    func reloadUImageView()
    {
        let index = self.menuView?.segmentedIndexType.selectedSegmentIndex ?? 0
        self.shareButton.alpha = self.alphaProgress[index]
        self.photoImageView.image = self.imagesBlurred[self.blurProgresses[index]]
    }
    
    func valueSegmentedIndexChanged()
    {
        if self.imagesCateg[0].count > 0
        {
            if self.menuView?.segmentedIndexType.selectedSegmentIndex == 0
            {
                self.imagesBlurred = self.imagesCateg[0]
            }
            else if self.menuView?.segmentedIndexType.selectedSegmentIndex == 1
            {
                self.imagesBlurred = self.imagesCateg[1]
            }
            else
            {
                self.imagesBlurred = self.imagesCateg[2]
            }
            self.reloadUImageView()
        }
    }
    
    func share() {
        let text = "Share your Eggs or your Bacon today!\n@werck_a"
        
        if let url = NSURL(string: "http://www.urlsurlesitedapple.com") // On pourra mettre l'image ?
        {
            let objectsToShare = [text, url]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint]
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func shareButtonAction(sender: UIButton) {
        self.share()
    }
    
    @IBAction func showMenu(sender: AnyObject)
    {
        var viewMask:UIView = UIView(frame:self.menuView!.frame)
        var color:UIColor?
        var oldColor:UIColor?
        
        if self.menuView?.isShow == true
        {
            color = self.view.backgroundColor
            oldColor = self.menuView?.backgroundColor
            self.menuView!.hideMenu()
        }
        else
        {
            color = self.menuView!.backgroundColor
            oldColor = self.view.backgroundColor
            self.menuView?.showMenu()
        }
        /*UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
        self.view.layoutIfNeeded()
        
        self.viewContainButton.backgroundColor = color!
        
        }) { (completed:Bool) -> Void in
        
        }*/
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.viewContainButton.backgroundColor = color!
            self.titleLabel.textColor = oldColor
        })
    }
    
    func sendMailToStaff()
    {
        let email = "ayrton@wim.fr"
        let url = NSURL(string: "mailto:\(email)")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func menuButtonAction(sender: UIButton) {
    }
    
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

