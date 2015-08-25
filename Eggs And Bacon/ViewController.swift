//
//  ViewController.swift
//  Eggs And Bacon
//
//  Created by Romain Arsac on 23/06/2015.
//  Copyright (c) 2015 Nyu Web Developpement. All rights reserved.
//

import UIKit
import AudioToolbox

let    MAXSHAKES: Int = 10
let    BLURRADIUSPIX: CGFloat = 20
let    MENUHEIGHT: CGFloat = 180.0

class ViewController: UIViewController, UIScrollViewDelegate, ShakeGestureProtocol {
    
    
    @IBOutlet weak var constraintLabelHeartTop: NSLayoutConstraint!
    @IBOutlet weak var verticalHeartConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var constraintHeightMessageLabel: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var viewContainButton: UIView!
    @IBOutlet weak var buttonShowMenu: UIButton!
    @IBOutlet weak var labelUnlike: UILabel!
    @IBOutlet weak var labelLike: UILabel!
    @IBOutlet weak var tutoImageView: UIImageView!
    @IBOutlet weak var buttonUnlike: UIButton!
    @IBOutlet weak var buttonLike: UIButton!
    
    
    
    
    var                shakeHelper:ShakeGesture?
    var                blurProgress:Int = 0
    var                imagesBlurred:Array<UIImage> = Array<UIImage>()
    var                imagesCateg:Array<Array<UIImage>> = Array<Array<UIImage>>(count: 2, repeatedValue: Array<UIImage>())
    var                 blurProgresses:[Int] = NSUserDefaults.standardUserDefaults().valueForKey("currentblurprogress") as? [Int] ?? [0, 0, 0]
    var                 alphaProgress:[CGFloat] = [0.0, 0.0, 0.0]
    var                 menuView:EABMenuView?
    var                 menuIsShow:Bool? = false
    var                 currentCateg:Int = 0
    var                 applelink:String = String("")
    //MARK: View Lifecycle
    
    
    func handle4S()
    {
        
        self.view.removeConstraint(self.constraintLabelHeartTop)
        self.view.removeConstraint(self.verticalHeartConstraint)
        var constraint:NSLayoutConstraint = NSLayoutConstraint(item: self.messageLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.scrollView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 8)
        self.view.addConstraint(constraint)
        self.constraintHeightMessageLabel.constant = 20
        self.view.layoutIfNeeded()
        self.buttonLike.hidden = true
        self.buttonUnlike.hidden = true
        self.labelLike.hidden = true
        self.labelUnlike.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // titleLabel
        self.titleLabel.font = UIFont(name: "Satisfy", size: 25)
        
        // messageLabel
        self.messageLabel.text = NSLocalizedString("NOT_SHAKED", comment: "")
        self.messageLabel.font = UIFont(name: "Satisfy", size: 23)
        
        // shareButton
        self.shareButton.titleLabel?.font = UIFont(name: "Satisfy", size: 13)
        self.shareButton.layer.cornerRadius = 6
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newData", name: "newDatas", object: nil)
        self.loadData()
        self.photoImageView.hidden = true
        self.tutoImageView.hidden = true
        self.tutoImageView.image = UIImage(named: NSLocalizedString("TUTO_IMAGE", comment: ""))
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    
        var query:PFQuery = PFQuery(className: "Config")
        
        query.findObjectsInBackgroundWithBlock { (res:[AnyObject]?, error:NSError?) -> Void in
            
            if error == nil
            {
                if let finalResp = res?.first as? PFObject
                {
                    if let link = finalResp.objectForKey("applelink") as? String {
                        self.applelink = link
                    }
                }
            }
            else
            {
                
            }
        }
    }
    
    func createMenu()
    {
        var menu:EABMenuView = EABMenuView.instanceFromNib()
        menu.buttonSendFeedBack.addTarget(self, action: "sendMailToStaff", forControlEvents: UIControlEvents.TouchUpInside)
        menu.buttonShareApp.addTarget(self, action: "share", forControlEvents: UIControlEvents.TouchUpInside)
        
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
        self.menuView?.segmentNotif.addTarget(self, action: "valueNotifChanged", forControlEvents: UIControlEvents.ValueChanged)
        
        self.view.bringSubviewToFront(self.viewContainButton)
        self.titleLabel.textColor = self.menuView?.backgroundColor
        self.hideVotingElements()
        self.view.layoutIfNeeded()
        self.menuView?.buttonShareApp.titleLabel?.textAlignment = NSTextAlignment.Center
        self.menuView?.buttonSendFeedBack.titleLabel?.textAlignment = NSTextAlignment.Center
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.scrollView.delegate = self
        self.scrollView.maximumZoomScale = 10.0
        self.scrollView.contentSize = self.photoImageView.bounds.size
        self.photoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.photoImageView.clipsToBounds = true
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        //Create Menu
        self.createMenu()
        //Initiate shake gesture
        self.shakeHelper = ShakeGesture()
        self.shakeHelper?.delegate = self
        self.shakeHelper?.loadCoreMotion()
        var blurProg = self.blurProgresses[(self.menuView?.segmentedIndexType.selectedSegmentIndex ?? 0)]
        
        if blurProg < (self.imagesBlurred.count - 1)
        {
            self.hideVotingElements()
        }
        else
        {
            self.showVotingElements()
        }
        println(UIDevice.currentDevice().modelName)
        if UIDevice.currentDevice().modelName == "iPhone 4S"
        {
            self.handle4S()
        }
    }
    
    
    //MARK: ShakeGestureDelegate
    
    func didFindAShake() {
        var blurProg = self.blurProgresses[self.currentCateg]
        
        if blurProg < (self.imagesBlurred.count - 1)
        {
            println(blurProg)
            self.photoImageView.image = nil
            self.photoImageView.image = self.imagesBlurred[blurProg]
            let i:Float = 1.0/Float(MAXSHAKES)
            
            self.tutoImageView.hidden = true
            self.shareButton.alpha = self.shareButton.alpha + CGFloat(i)
            blurProg = blurProg + 1
            let index = self.currentCateg
            self.blurProgresses[index] = blurProg
            self.alphaProgress[index] = self.shareButton.alpha
            
            //Set the current blurprog and alpha to UserDefaults
            NSUserDefaults.standardUserDefaults().setValue(self.blurProgresses, forKey: "currentblurprogress")
            NSUserDefaults.standardUserDefaults().setValue(self.alphaProgress, forKey: "alphaprogress")
            NSUserDefaults.standardUserDefaults().setValue(false, forKey: "tutorial")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        else
        {
            self.showVotingElements()
            self.photoImageView.image = self.imagesBlurred.last
            self.shareButton.alpha = 1
        }
    }
    
    //Mark: Func update UI
    
    func resizeImage(image:UIImage, newSize:CGSize) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func showVotingElements()
    {
        if UIDevice.currentDevice().modelName != "iPhone 4S" &&  UIDevice.currentDevice().modelName != "Simulator"
        {
            self.labelLike.hidden = false
            self.labelUnlike.hidden = false
            self.buttonLike.hidden = false
            self.buttonUnlike.hidden = false
        }
    }
    
    func hideVotingElements()
    {
        self.labelLike.hidden = true
        self.labelUnlike.hidden = true
        self.buttonLike.hidden = true
        self.buttonUnlike.hidden = true
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.photoImageView
    }
    
    func updateUI()
    {
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let tuto: Bool = defaults.objectForKey("tutorial") as? Bool
        {
            if tuto == false
            {
                self.tutoImageView.hidden = true
            }
        }
        else
        {
            self.tutoImageView.hidden = false
        }
        self.valueSegmentedIndexChanged()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Load data
    
    func newData()
    {
        self.blurProgresses = [0, 0, 0]
        self.alphaProgress = [0.0, 0.0, 0.0]
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
                self.imagesCateg[0] = self.prepareImages(self.resizeImage(imgs[i], newSize: self.scrollView.bounds.size))
            }
            else if o.objectForKey("category") as? String == "Bacon"
            {
                self.imagesCateg[1] = self.prepareImages(self.resizeImage(imgs[i], newSize: self.photoImageView.frame.size))
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
            self.alphaProgress = NSUserDefaults.standardUserDefaults().valueForKey("alphaprogress") as? [CGFloat] ?? [0.0, 0.0, 0.0]
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
        let dateBounds = ManagedPFObject.minMaxDate()
        
        var query:PFQuery = PFQuery(className: "Pictures")
        query.whereKey("category", equalTo: self.menuView!.getCategoryName())
        query.whereKey("dateToReveal", greaterThanOrEqualTo: dateBounds.dateMin)
        query.whereKey("dateToReveal", lessThan: dateBounds.dateMax)
        query.fromLocalDatastore()
        
        query.findObjectsInBackgroundWithBlock { (results:[AnyObject]?, error:NSError?) -> Void in
            println(results)
            
            if let objects = results as? [PFObject] {
                if objects.count >= 1
                {
                    if let data = objects.first
                    {
                        if let unlike = data["unlike"] as? Int, let like = data["like"] as? Int {
                            self.labelUnlike.text = "\(unlike)"
                            self.labelLike.text = "\(like)"
                        }
                        
                    }
                }
            }
        }
        
        let index = self.currentCateg
        self.shareButton.alpha = self.alphaProgress[index]
        self.photoImageView.image = self.imagesBlurred[self.blurProgresses[index]]
        //self.photoImageView.image = self.imagesBlurred.last
        
    }
    
     func valueNotifChanged() {
        
        let segment = self.menuView!.segmentNotif
        
        if segment.selectedSegmentIndex == 0
        {
            var application = UIApplication.sharedApplication()
            let userNotificationTypes = (UIUserNotificationType.Alert |  UIUserNotificationType.Badge |  UIUserNotificationType.Sound);
            
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            
        }
        else
        {
            UIApplication.sharedApplication().unregisterForRemoteNotifications()
        }
        
        
    }

    
    func valueSegmentedIndexChanged()
    {
        if self.imagesCateg[0].count > 0
        {
            self.currentCateg = self.menuView?.segmentedIndexType?.selectedSegmentIndex ?? 0
            self.imagesBlurred = self.imagesCateg[currentCateg]
            var blurProg = self.blurProgresses[self.currentCateg]
            if blurProg < (self.imagesBlurred.count - 1)
            {
                self.hideVotingElements()
            }
            else
            {
                self.showVotingElements()
            }
            self.reloadUImageView()
        }
    }
    
    func share()
    {
        let dateBounds = ManagedPFObject.minMaxDate()
        
        var query:PFQuery = PFQuery(className: "Pictures")
        query.whereKey("category", equalTo: self.menuView!.getCategoryName())
        query.whereKey("dateToReveal", greaterThanOrEqualTo: dateBounds.dateMin)
        query.whereKey("dateToReveal", lessThan: dateBounds.dateMax)
        query.fromLocalDatastore()
        
        query.findObjectsInBackgroundWithBlock { (results:[AnyObject]?, error:NSError?) -> Void in
            println(results)
            
            var text = "Share your Eggs or your Bacon today!"
            
            if let objects = results as? [PFObject] {
                if objects.count >= 1 {
                    if let data = objects.first {
                        if let twitter = data["twitter"] as? String {
                            text = "\(twitter)" + NSLocalizedString("TWITTER", comment: "")
                        }
                    }
                }
            }
            // LinkMaker --> APPLE STORE
            if let url = NSURL(string: self.applelink)
            { // On pourra mettre l'image ?
                let objectsToShare = [text, url]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint]
                
                self.presentViewController(activityVC, animated: true, completion: nil)
            }
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
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.viewContainButton.backgroundColor = color!
            self.titleLabel.textColor = oldColor
        })
    }
    
    func sendMailToStaff()
    {
        let email = "contact@eggsandbacon.me"
        let url = NSURL(string: "mailto:\(email)")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func menuButtonAction(sender: UIButton) {
    }
    
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func unlikeButtonAction(sender: UIButton) {
        let dateBounds = ManagedPFObject.minMaxDate()
        
        var query:PFQuery = PFQuery(className: "Pictures")
        query.whereKey("category", equalTo: self.menuView!.getCategoryName())
        query.whereKey("dateToReveal", greaterThanOrEqualTo: dateBounds.dateMin)
        query.whereKey("dateToReveal", lessThan: dateBounds.dateMax)
        
        query.findObjectsInBackgroundWithBlock { (results:[AnyObject]?, error:NSError?) -> Void in
            println(results)
            
            if let objects = results as? [PFObject] {
                if objects.count >= 1
                {
                    if let data = objects.first
                    {
                        if var unlike = data["unlike"] as? Int {
                            unlike = unlike + 1
                            data["unlike"] = unlike
                            self.labelUnlike.text = "\(unlike)"
                            
                            data.saveInBackgroundWithBlock({ (results: Bool, error: NSError?) -> Void in
                                println("Error ? = \(error)")
                            })
                        }
                        
                    }
                }
            }
        }
        
    }
    
    @IBAction func likeButtonAction(sender: AnyObject) {
        let dateBounds = ManagedPFObject.minMaxDate()
        
        var query:PFQuery = PFQuery(className: "Pictures")
        query.whereKey("category", equalTo: self.menuView!.getCategoryName())
        query.whereKey("dateToReveal", greaterThanOrEqualTo: dateBounds.dateMin)
        query.whereKey("dateToReveal", lessThan: dateBounds.dateMax)
        query.fromLocalDatastore()
        query.findObjectsInBackgroundWithBlock { (results:[AnyObject]?, error:NSError?) -> Void in
            println(results)
            
            if let objects = results as? [PFObject] {
                if objects.count >= 1
                {
                    if let data = objects.first
                    {
                        if var like = data["like"] as? Int {
                            like = like + 1
                            data["like"] = like
                            self.labelLike.text = "\(like)"
                            
                            data.saveInBackgroundWithBlock({ (results: Bool, error: NSError?) -> Void in
                                println("Error ? = \(error)")
                            })
                        }
                        
                    }
                }
            }
            
        }
    }
    
}

