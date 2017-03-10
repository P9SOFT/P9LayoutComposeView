//
//  ViewController.swift
//  Sample
//
//  Created by Tae Hyun Na on 2017. 3. 9.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit

class ViewController: UIViewController, P9LayoutComposeViewProtocol {

    @IBOutlet var composeView: P9LayoutComposeView!
    @IBOutlet var kingghidorahImageView: UIImageView!
    @IBOutlet var godzillaImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.composeView.delegate = self
        
        let param = [P9ViewDraggerLockRotateKey:true, P9ViewDraggerLockScaleKey:true];
        
        P9ViewDragger.defaultTracker().trackingDecoyView(self.kingghidorahImageView, stageView: self.view, parameters: param, ready: { (trackingView:UIView?) in
            self.kingghidorahImageView.alpha = 0.3
        }, trackingHandler: { (trackingView:UIView?) in
            self.hitTestAndUpdateIfNeed(trackingView!)
        }) { (trackingView:UIView?) in
            self.kingghidorahImageView.alpha = 1.0
            if( self.composeView.layer.borderWidth > 0.0 ) {
                self.composeView.layer.borderWidth = 0.0
                self.composeView.addDecoyComponent(from: self.kingghidorahImageView, parameters: nil)
            }
        }
        
        P9ViewDragger.defaultTracker().trackingDecoyView(self.godzillaImageView, stageView: self.view, parameters: param, ready: { (trackingView:UIView?) in
            self.godzillaImageView.alpha = 0.3
        }, trackingHandler: { (trackingView:UIView?) in
            self.hitTestAndUpdateIfNeed(trackingView!)
        }) { (trackingView:UIView?) in
            self.godzillaImageView.alpha = 1.0
            if( self.composeView.layer.borderWidth > 0.0 ) {
                self.composeView.layer.borderWidth = 0.0
                self.composeView.addDecoyComponent(from: self.godzillaImageView, parameters: nil)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hitTestAndUpdateIfNeed(_ trackingView:UIView) {
        
        let frame = trackingView.frame;
        let middle = CGPoint(x:frame.midX, y:frame.midY)
        if self.composeView.frame.contains(middle) == true {
            self.composeView.layer.borderWidth = 2.0
        } else {
            self.composeView.layer.borderWidth = 0.0
        }
    }
    
    func p9LayoutComposeView(_ layoutComposeView: P9LayoutComposeView!, willStartTracking anObject: Any!, forKey key: String!) {
        
        print(key+" will start tracking.")
    }
    
    func p9LayoutComposeView(_ layoutComposeView: P9LayoutComposeView!, didTracking anObject: Any!, forKey key: String!) {
        
        print(key+" did tracking.")
    }
    
    func p9LayoutComposeView(_ layoutComposeView: P9LayoutComposeView!, didEndTracking anObject: Any!, forKey key: String!) {
        
        print(key+" did end tracking.")
    }

}

