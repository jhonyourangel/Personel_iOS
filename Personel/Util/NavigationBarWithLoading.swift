//
//  NavigationBarWithLoading.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import UIKit

class NavigationBarWithLoading: UINavigationBar {
    
    weak var shapeLayer: CAShapeLayer?
    
    
    func startLoading( _ color: UIColor) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        self.shapeLayer?.removeFromSuperlayer()
        
        // create whatever path you want
        
        let path = UIBezierPath()
        let y = Int(self.frame.size.height)
        let offset = 100
        path.move(to: CGPoint(x: -offset, y: y))
        path.addLine(to: CGPoint(x: Int(self.frame.size.width) + (offset / 2), y: y))
        path.addLine(to: CGPoint(x: -offset, y: y))
        
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.path = path.cgPath
        shapeLayer.strokeStart = 0
        
        let startAnimation = CABasicAnimation(keyPath: "strokeStart")
        startAnimation.fromValue = 0
        startAnimation.toValue = 0.9
        
        let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endAnimation.fromValue = 0.1
        endAnimation.toValue = 1
        
        let animation = CAAnimationGroup()
        animation.animations = [startAnimation, endAnimation]
        animation.duration = 3
        animation.repeatCount = 999
        shapeLayer.add(animation, forKey: "MyAnimation")
        
        self.layer.addSublayer(shapeLayer)
        self.shapeLayer = shapeLayer
    }
    
    
    func stopLoading() {
        self.shapeLayer?.removeFromSuperlayer()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

