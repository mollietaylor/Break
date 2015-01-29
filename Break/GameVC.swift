//
//  GameVC.swift
//  Break
//
//  Created by Mollie on 1/28/15.
//  Copyright (c) 2015 Proximity Viz LLC. All rights reserved.
//

import UIKit

let SCREEN_WIDTH = UIScreen.mainScreen().bounds.width
let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.height

let BALL_COLOR = UIColor(red:0.29, green:0.23, blue:0.28, alpha:1)

class GameVC: UIViewController, UICollisionBehaviorDelegate {

    @IBOutlet weak var breakLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var livesView: LivesView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var score: Int = 0 {
        
        didSet {
        
            if score > GameData.mainData().topScore { GameData.mainData().topScore = score }
            GameData.mainData().currentGame?["totalScore"] = score
            
            scoreLabel.text = "\(score)"
            scoreLabel.textColor = BALL_COLOR
            
        }
        
    }
    
    var animator: UIDynamicAnimator?
    
    var gravityBehavior = UIGravityBehavior()
    var collisionBehavior = UICollisionBehavior()
    var ballBehavior = UIDynamicItemBehavior()
    var brickBehavior = UIDynamicItemBehavior()
    var paddleBehavior = UIDynamicItemBehavior()
    
    var paddle = UIView(frame: CGRectMake(0, 0, 100, 10))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        animator = UIDynamicAnimator(referenceView: gameView)
        
        animator?.addBehavior(gravityBehavior)
        animator?.addBehavior(collisionBehavior)
        animator?.addBehavior(ballBehavior)
        animator?.addBehavior(brickBehavior)
        animator?.addBehavior(paddleBehavior)
        
//        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionDelegate = self
        
        collisionBehavior.addBoundaryWithIdentifier("lava", fromPoint: CGPointMake(0, SCREEN_HEIGHT - 35), toPoint: CGPointMake(SCREEN_WIDTH, SCREEN_HEIGHT - 35))
        collisionBehavior.addBoundaryWithIdentifier("top", fromPoint: CGPointMake(0, 0), toPoint: CGPointMake(SCREEN_WIDTH, 0))
        collisionBehavior.addBoundaryWithIdentifier("bottom", fromPoint: CGPointMake(0, SCREEN_HEIGHT), toPoint: CGPointMake(SCREEN_WIDTH, SCREEN_HEIGHT))
        collisionBehavior.addBoundaryWithIdentifier("left", fromPoint: CGPointMake(0, 0), toPoint: CGPointMake(0, SCREEN_HEIGHT))
        collisionBehavior.addBoundaryWithIdentifier("right", fromPoint: CGPointMake(SCREEN_WIDTH, 0), toPoint: CGPointMake(SCREEN_WIDTH, SCREEN_HEIGHT))
        
        ballBehavior.friction = 0
        ballBehavior.elasticity = 1
        ballBehavior.resistance = 0
        ballBehavior.allowsRotation = false
        
        brickBehavior.density = 1000000
        paddleBehavior.density = 1000000
        
        playGame()
        
    }
    
    @IBAction func playGame() {
        
        GameData.mainData().startGame()
        
        breakLabel.hidden = true
        playButton.hidden = true
        
        createPaddle()
        createBall()
        createBricks()
        score = 0
        livesView.livesLeft = 2
        
    }
    
    func endGame(gameOver: Bool) {

        
        GameData.mainData().currentLevel = gameOver ? 0 : ++GameData.mainData().currentLevel
        
        println(GameData.mainData().gamesPlayed)
        println(GameData.mainData().topScore)
        
        breakLabel.hidden = false
        playButton.hidden = false
        
        paddle.removeFromSuperview()
        collisionBehavior.removeItem(paddle)
        paddleBehavior.removeItem(paddle)
        
        for ball in ballBehavior.items as [UIView] {
            ball.removeFromSuperview()
            collisionBehavior.removeItem(ball)
            ballBehavior.removeItem(ball)
        }
        
        for brick in brickBehavior.items as [UIView] {
            brick.removeFromSuperview()
            collisionBehavior.removeItem(brick)
            brickBehavior.removeItem(brick)
        }
        
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        
        for ball in ballBehavior.items as [UIView] {
            
            if ball.isEqual(item) && identifier as String == "lava" {
                
                var ball = item as UIView
                ball.removeFromSuperview()
                ballBehavior.removeItem(ball)
                collisionBehavior.removeItem(ball)
                
                if livesView.livesLeft == 0 { endGame(true); return }
                
                livesView.livesLeft--
                
                GameData.mainData().adjustValue(1, forKey: "livesLost")
                
                createBall()
                
            }
            
        }
        
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem) {
        
        ballBehavior.items
        brickBehavior.items
        
        for brick in brickBehavior.items as [UIView] {
            
            if brick.isEqual(item1) || brick.isEqual(item2) {
                
                brick.removeFromSuperview()
                collisionBehavior.removeItem(brick)
                brickBehavior.removeItem(brick)
                
                GameData.mainData().adjustValue(1, forKey: "bricksBusted")
                
                // scoring
                score += 100
                
                var pointsLabel = UILabel(frame: brick.frame)
                pointsLabel.text = "+100"
                pointsLabel.textAlignment = .Center
                
                gameView.addSubview(pointsLabel)
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    pointsLabel.alpha = 0
                    
                }, completion: { (succeeded) -> Void in
                    
                    pointsLabel.removeFromSuperview()
                    
                })
                
            }
            
        }
        
        if brickBehavior.items.count == 0 {
            
            endGame(false)
            
        }
        
    }
    
    func createBall() {
        
//        var ball = UIView(frame: CGRectMake(0, 0, 20, 20))
        var ball = UIImageView(frame: CGRectMake(0, 0, 20, 20))
        ball.image = UIImage(named: "ball")
        ball.center.x = paddle.center.x
        ball.center.y = paddle.center.y - 40
        ball.backgroundColor = BALL_COLOR
        ball.layer.cornerRadius = ball.frame.width / 2
        
        gameView.addSubview(ball)
        
        collisionBehavior.addItem(ball)
        ballBehavior.addItem(ball)
        
        var pushBehavior = UIPushBehavior(items: [ball], mode: .Instantaneous)
        
        pushBehavior.pushDirection = CGVectorMake(0.06, -0.06)
        
        animator?.addBehavior(pushBehavior)
        
    }
    
    func createBricks() {
        
        let grid = GameData.mainData().allLevels[GameData.mainData().currentLevel]
        
        let gap: CGFloat = 6
        let brickWidth = (SCREEN_WIDTH - (gap * CGFloat(grid.0 + 1))) / CGFloat(grid.0)
        let brickHeight: CGFloat = 20
        
        for c in 0..<grid.0 {
            
            for r in 0..<grid.1 {
                
                let x = CGFloat(c) * (brickWidth + gap) + gap
                let y = CGFloat(r) * (brickHeight + gap) + 65
                
//                var brick = UIView(frame:CGRectMake(x, y, brickWidth, brickHeight))
                var brick = UIImageView(frame: CGRectMake(x, y, brickWidth, brickHeight))
                brick.image = UIImage(named: "brick")
                brick.backgroundColor = BALL_COLOR
                
                gameView.addSubview(brick)
                
                collisionBehavior.addItem(brick)
                brickBehavior.addItem(brick)
                
            }
            
        }
        
    }
    
    var attachmentBehavior: UIAttachmentBehavior?
    
    func createPaddle() {
        
        paddle.center.x = view.center.x
        paddle.center.y = SCREEN_HEIGHT - 40
        paddle.backgroundColor = BALL_COLOR
        
        gameView.addSubview(paddle)
        
        collisionBehavior.addItem(paddle)
        paddleBehavior.addItem(paddle)
        
        if attachmentBehavior == nil {
            attachmentBehavior = UIAttachmentBehavior(item: paddle, attachedToAnchor: paddle.center)
            animator?.addBehavior(attachmentBehavior)
        }
        
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        if let touch = touches.allObjects.first as? UITouch {
            
            let location = touch.locationInView(gameView)
            
//            paddle.center.x = location.x
            attachmentBehavior?.anchorPoint.x = location.x
            
        }
        
    }

}
