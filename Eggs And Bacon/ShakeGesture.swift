//
//  ShakeGesture.swift
//  Eggs And Bacon
//
//  Created by Werck Ayrton on 30/06/2015.
//  Copyright (c) 2015 Nyu Web Developpement. All rights reserved.
//

import UIKit
import CoreMotion

let     updateTimeInterval = 0.1


protocol ShakeGestureProtocol
{
    func didFindAShake()
}


class ShakeGesture: NSObject {
   
    var     motionMngr:CMMotionManager = CMMotionManager()
    var     currentY = 0.0
    var     delegate:ShakeGestureProtocol?
    
    func loadCoreMotion()
    {
        if motionMngr.gyroAvailable == true && motionMngr.accelerometerAvailable == true
        {
            motionMngr.gyroUpdateInterval = updateTimeInterval
            motionMngr.accelerometerUpdateInterval = 0.1
            motionMngr.startAccelerometerUpdates()
            motionMngr.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (data: CMAccelerometerData!, error: NSError!) in
                
                let yy = data.acceleration.y
                let v = abs(yy - (self?.currentY ?? 0)) / updateTimeInterval
                if v > 20
                {
                    self?.delegate?.didFindAShake()
                }
                println("Vitesse: \(v)")
            }
        }
    }
    
}
