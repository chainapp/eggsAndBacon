//
//  MangedPFObject.swift
//  Eggs And Bacon
//
//  Created by Werck Ayrton on 25/06/2015.
//  Copyright (c) 2015 Nyu Web Developpement. All rights reserved.
//

import UIKit

class ManagedPFObject: NSObject {
    
    //class func getDailyPictures(completionBlock:(results:Array<Dictionary<String, AnyObject>>?, error: NSError?) -> ())
    
    class func minMaxDate() -> (dateMin:NSDate, dateMax:NSDate)
    {
        let calendar:NSCalendar = NSCalendar.currentCalendar()
        let dateComponents:NSDateComponents = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour], fromDate: NSDate())
        dateComponents.setValue(6, forComponent: NSCalendarUnit.Hour)
        
        let morning:NSDate = calendar.dateFromComponents(dateComponents)!
        
        dateComponents.day = dateComponents.day + 1
        let last:NSDate = calendar.dateFromComponents(dateComponents)!
        
        return (morning, last)
    }
    
    
    class func getDailyPictures(completionBlock:(results:Array<PFObject>?, images:Array<UIImage>?, error: NSError?) -> ())
    {
        let dateBounds = ManagedPFObject.minMaxDate()
        
        let query:PFQuery = PFQuery(className: "Pictures")
        query.whereKey("dateToReveal", greaterThanOrEqualTo: dateBounds.dateMin)
        query.whereKey("dateToReveal", lessThan: dateBounds.dateMax)
        
        query.findObjectsInBackgroundWithBlock { (results:[AnyObject]?, error:NSError?) -> Void in
            print(results)
            
            if results != nil && results?.count > 0
            {
                var pfobjs:Array<PFObject> = Array<PFObject>()
                var imgs:Array<UIImage> = Array<UIImage>()
                var i:Int = 0
                
                
                for object:PFObject in results as! Array<PFObject>
                {
                    if let file:PFFile = object.objectForKey("pictureFile") as? PFFile
                    {
                        file.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
                            
                            if (data != nil)
                            {
                                pfobjs.append(object)
                                imgs.append(UIImage(data: data!)!)
                            }
                            else
                            {
                                print(error)
                            }
                            if i == (results!.count - 1)
                            {
                                if pfobjs.count == results!.count && imgs.count == results!.count
                                {
                                    PFObject.pinAllInBackground(pfobjs, block: { (success:Bool, error:NSError?) -> Void in
                                        if success == true
                                        {
                                            print("All obj have been pinned")
                                        }
                                        else
                                        {
                                            print("Error when pin object")
                                            print(error)
                                        }
                                    })
                                    completionBlock(results: pfobjs, images:imgs, error: nil)
                                }
                                else
                                {
                                    completionBlock(results: nil, images: nil, error: nil)
                                }
                            }
                            i = i + 1
                        })
                    }
                    else
                    {
                        i = i + 1
                    }
                }
            }
            else
            {
                completionBlock(results:nil, images:nil, error:nil)
            }
        }
    }
    
    class func getLocalDailyPictures(completionBlock:(results:Array<PFObject>?, images:Array<UIImage>?, error: NSError?) -> ())
    {
        let dateBounds = ManagedPFObject.minMaxDate()
        
        let query:PFQuery = PFQuery(className: "Pictures")
        query.whereKey("dateToReveal", greaterThanOrEqualTo: dateBounds.dateMin)
        query.whereKey("dateToReveal", lessThan: dateBounds.dateMax)
        //query.fromLocalDatastore()
        
        query.findObjectsInBackgroundWithBlock { (results:[AnyObject]?, error:NSError?) -> Void in
            print(results)
            
            if results != nil && results?.count > 0
            {
                var pfobjs:Array<PFObject> = Array<PFObject>()
                var imgs:Array<UIImage> = Array<UIImage>()
                var i:Int = 0
                
                for object:PFObject in results as! Array<PFObject>
                {
                    if let file:PFFile = object.objectForKey("pictureFile") as? PFFile
                    {
                        file.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
                            
                            if (data != nil)
                            {
                                pfobjs.append(object)
                                imgs.append(UIImage(data: data!)!)
                            }
                            else
                            {
                                print(error)
                            }
                            if i == (results!.count - 1)
                            {
                                print(results!.count);
                                print(imgs.count);
                                print(pfobjs.count)
                                if pfobjs.count == results!.count && imgs.count == results!.count
                                {
                                    PFObject.pinAllInBackground(pfobjs, block: { (success:Bool, error:NSError?) -> Void in
                                        if success == true
                                        {
                                            print("All obj have been pinned")
                                        }
                                        else
                                        {
                                            print("Error when pin object")
                                            print(error)
                                        }
                                    })
                                    completionBlock(results: pfobjs, images:imgs, error: nil)
                                }
                                else
                                {
                                    completionBlock(results: nil, images: nil, error: nil)
                                }
                            }
                            i = i + 1
                        })
                    }
                    else
                    {
                        i = i + 1
                    }
                }
            }
            else
            {
                completionBlock(results:nil, images:nil, error:nil)
            }
        }
    }
}
