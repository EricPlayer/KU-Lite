//
//  Toast.swift
//  martondeal
//
//  Created by Imbibe User on 03/03/17.
//  Copyright © 2017 Imbibe User. All rights reserved.
//

import Foundation
import UIKit

class Toast: NSObject
{
    // MARK:- --------- variable declaration ----------//
    var toastView: UILabel!
    var timer: Timer!
    
    // MARK:- --------- view functionality ----------//
    func showToast(message: String, duration: TimeInterval)
    {
        toastView = createToast(message: message)
        
        let window = UIApplication.shared.keyWindow!
        window.addSubview(toastView)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
            
            self.toastView.alpha = 1
            
        }, completion: { (true) in
            self.timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.dismissToast(userInfo:)), userInfo: nil, repeats: true);
        })
    }
    
    func createToast(message: String)->UILabel
    {
        let toast = UILabel()
        toast.numberOfLines = 10
        toast.text = message
        toast.backgroundColor = UIColor(red: 102.0/255, green: 102.0/255, blue: 102.0/255, alpha: 1.0)
        toast.textColor = UIColor.white
        toast.textAlignment = .center
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        toast.frame = CGRect(x: 0, y: 0, width: screenWidth*0.70, height: 30)
        
        toast.frame.size.width = toast.sizeThatFits(toast.bounds.size).width + 50
        toast.frame.size.height = toast.sizeThatFits(toast.bounds.size).height + 50
        toast.frame.origin.x = (screenWidth - toast.frame.size.width)/2
        toast.frame.origin.y = screenHeight - toast.frame.size.height - 49 - (0.10*screenHeight)
        
        toast.layer.cornerRadius = toast.frame.size.height/2
        toast.layer.masksToBounds = true
        
        toast.alpha = 0
        
        return toast
    }
    
    @objc func dismissToast(userInfo: AnyObject)
    {
        timer.invalidate()
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
            
            self.toastView.alpha = 0
            
        }, completion: { (true) in
            self.toastView.removeFromSuperview()
        })
    }
    
}
