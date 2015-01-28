//
//  LivesView.swift
//  Break
//
//  Created by Mollie on 1/28/15.
//  Copyright (c) 2015 Proximity Viz LLC. All rights reserved.
//

import UIKit

@IBDesignable class LivesView: UIView {
    
    let BALL_COLOR = UIColor(red:0.29, green:0.23, blue:0.28, alpha:1)

    @IBInspectable var livesLeft: Int = 3 {
        
        didSet {
            
            setNeedsDisplay()
            
        }
        
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        for view in subviews {
            view.removeFromSuperview()
        }
        
        var context = UIGraphicsGetCurrentContext()
        
        let ballSize: CGFloat = 10.0
        
        let topPadding: CGFloat = 15.0
        
        let totalBallWidth = ballSize * CGFloat(livesLeft + livesLeft - 1)
        let leftPadding = (rect.width - CGFloat(totalBallWidth)) / 2.0
        
        for i in 0..<livesLeft {
            
            let x = CGFloat(i * 2) * ballSize + leftPadding
            
            let lifeRect = CGRectMake(x, topPadding, ballSize, ballSize)
            
            BALL_COLOR.set()
//            CGContextFillEllipseInRect(context, lifeRect)
            
            var ball = UIImageView(frame: lifeRect)
            ball.image = UIImage(named: "ball")
            addSubview(ball)
            
        }
        
    }

}
