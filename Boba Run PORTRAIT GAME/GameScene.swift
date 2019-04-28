//
//  GameScene.swift
//  Flappybo
//
//  Created by Nate Murray on 6/2/14.
//  Copyright (c) 2014 Fullstack.io. All rights reserved.
//
//  Source Code Taken From https://github.com/fullstackio/FlappySwift and http://sweettutos.com/2017/03/09/build-your-own-flappy-bird-game-with-swift-3-and-spritekit/
//
//  Music from freesound by user vikuserro ( https://freesound.org/people/vikuserro/sounds/265549/ )
//  Sound Effect from freesound https://freesound.org/people/greenvwbeetle/sounds/244657/ , https://freesound.org/people/Julien%20Matthey/sounds/167080/
//
//
//


import SpriteKit
import GameKit



class GameScene: SKScene, SKPhysicsContactDelegate{
    let verticalStrawGap = 250.0
    let popSound = SKAction.playSoundFileNamed("244657_greenvwbeetle_pop-5.mp3", waitForCompletion: false)
    let splatSound = SKAction.playSoundFileNamed("167080_julien-matthey_jm-impact-01c-snow-on-cement.mp3", waitForCompletion: false)

    
    var bo:SKSpriteNode!
    var skyColor:SKColor!
    var strawTextureUp:SKTexture!
    var strawTextureDown:SKTexture!
    var bobaTexture:SKTexture!
    var moveStrawsAndRemove:SKAction!
    var moveBobasAndRemove:SKAction!
    var moving:SKNode!
    var straws:SKNode!
    var bobas:SKNode!
    var canRestart = Bool()
    var scoreLabelNode:SKLabelNode!
    var score = NSInteger()
    var highscoreLabelNode:SKLabelNode!
    
    var pauseButton: UIButton!
    
    
    let boCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let strawCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    let highscoreCategory: UInt32 = 1 << 4
    let bobaCategory: UInt32 = 1 << 5
    
    
    
    override func didMove(to view: SKView) {
        
        canRestart = true
        
        // setup physics
        self.physicsWorld.gravity = CGVector( dx: 0.0, dy: -5.0 )
        self.physicsWorld.contactDelegate = self
        
        // setup background color
        skyColor = SKColor(red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0)
        self.backgroundColor = skyColor
        
        
        moving = SKNode()
        self.addChild(moving)
        straws = SKNode()
        moving.addChild(straws)
        bobas = SKNode()
        moving.addChild(bobas)
        
        
        // ground
        let groundTexture = SKTexture(imageNamed: "sidewalk")
        groundTexture.filteringMode = .nearest
        
        let moveGroundSprite = SKAction.moveBy(x: -groundTexture.size().width * 2.0, y: 0, duration: TimeInterval(0.02 * groundTexture.size().width * 2.0))
        let resetGroundSprite = SKAction.moveBy(x: groundTexture.size().width * 2.0, y: 0, duration: 0.0)
        let moveGroundSpritesForever = SKAction.repeatForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
        
        for i in 0 ..< 2 + Int(self.frame.size.width / ( groundTexture.size().width * 1 )) {
            let i = CGFloat(i)
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.setScale(2.0)
            sprite.position = CGPoint(x: i * sprite.size.width, y: -502)
            sprite.run(moveGroundSpritesForever)
            moving.addChild(sprite)
            
        }
        
        // skyline
        let skyTexture = SKTexture(imageNamed: "bg")
        skyTexture.filteringMode = .nearest
        
        
        let moveSkySprite = SKAction.moveBy(x: -skyTexture.size().width * 2.0, y: 0, duration: TimeInterval(0.1 * skyTexture.size().width * 2.0))
        let resetSkySprite = SKAction.moveBy(x: skyTexture.size().width * 2.0, y: 0, duration: 0.0)
        let moveSkySpritesForever = SKAction.repeatForever(SKAction.sequence([moveSkySprite,resetSkySprite]))
        
        for i in 0 ..< 2 + Int(self.frame.size.width / (skyTexture.size().width * 2)) {
            let i = CGFloat(i)
            let sprite = SKSpriteNode(texture: skyTexture)
            sprite.setScale(0.90)
            sprite.zPosition = -20
            sprite.position = CGPoint(x: i * sprite.size.width, y: 155 )
            sprite.run(moveSkySpritesForever)
            moving.addChild(sprite)
            
        }
        
        
        // create the straws textures
        strawTextureUp = SKTexture(imageNamed: "straw_GREEN_up")
        strawTextureUp.filteringMode = .nearest
        strawTextureDown = SKTexture(imageNamed: "straw_GREEN")
        strawTextureDown.filteringMode = .nearest
        
        // create the straws movement actions
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * strawTextureUp.size().width)
        let moveStraws = SKAction.moveBy(x: -distanceToMove, y:0.0, duration:TimeInterval(0.01 * distanceToMove))
        let removeStraws = SKAction.removeFromParent()
        moveStrawsAndRemove = SKAction.sequence([moveStraws, removeStraws])
        
        // spawn the straws
        let spawn = SKAction.run(spawnStraws)
        let delay = SKAction.wait(forDuration: TimeInterval(3.0))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatForever(spawnThenDelay)
        self.run(spawnThenDelayForever)
        
        
        
        // create bobas texture
        bobaTexture = SKTexture(imageNamed: "bobaball")
        bobaTexture.filteringMode = .nearest
        
        // create boba movement action
        let moveBobas = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(0.01 * distanceToMove))
        let removeBobas = SKAction.removeFromParent()
        moveBobasAndRemove = SKAction.sequence([moveBobas, removeBobas])
        
        // spawn bobas
        let spawnBoba = SKAction.run(spawnBobas)
        let delayBoba = SKAction.wait(forDuration: TimeInterval(3.75))
        let spawnThenDelayBoba = SKAction.sequence([spawnBoba, delayBoba])
        let spawnThenDelayBobaForever = SKAction.repeatForever(spawnThenDelayBoba)
        self.run(spawnThenDelayBobaForever)
        
        
        // setup bo
        let boTexture = SKTexture(imageNamed: "Boba")
        boTexture.filteringMode = .nearest

        
        
        bo = SKSpriteNode(texture: boTexture)
        bo.setScale(0.20)
        bo.position = CGPoint(x: -100, y: 600)
        bo.zPosition = 10
        
        
        bo.physicsBody = SKPhysicsBody(circleOfRadius: bo.size.height / 2.0)
        bo.physicsBody?.isDynamic = true
        bo.physicsBody?.allowsRotation = false
        
        bo.physicsBody?.categoryBitMask = boCategory
        bo.physicsBody?.collisionBitMask = worldCategory | strawCategory
        bo.physicsBody?.contactTestBitMask = worldCategory | strawCategory | bobaCategory
        
        self.addChild(bo)
        
        
        
        // create the ground
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: -502)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: groundTexture.size().height * 2.0))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = worldCategory
        self.addChild(ground)
        
        
        // Initialize label and create a label which holds the score
        score = 0
        scoreLabelNode = SKLabelNode(fontNamed:"Noteworthy-Bold")
        scoreLabelNode.position = CGPoint( x: 0, y: 175 )
        scoreLabelNode.zPosition = 100
        scoreLabelNode.fontSize = 65
        scoreLabelNode.text = String(score)
        self.addChild(scoreLabelNode)
        
        
        
        // Initialized label and create a lable for high score
        highscoreLabelNode = SKLabelNode(fontNamed:"Noteworthy-Bold")
        highscoreLabelNode.position = CGPoint( x: -185, y: 520 )
        highscoreLabelNode.zPosition = 100
        highscoreLabelNode.fontSize = 45
        highscoreLabelNode.fontColor = SKColor.black
        
        
        if let scoreValue = UserDefaults.standard.object(forKey: "scoreValue") {
            print("highscore found when started")
            highscoreLabelNode.text = "Best: \(scoreValue)"
        } else {
            print("highscore not found when started")
            highscoreLabelNode.text = "Best: \(0)"
        }
        
        self.addChild(highscoreLabelNode)

    }
    
    
    
    func spawnStraws() {
        let strawPair = SKNode()
        strawPair.position = CGPoint( x: self.frame.size.width + strawTextureUp.size().width * 2, y: 0 )
        strawPair.zPosition = -10
        
        let height = UInt32( self.frame.size.height / 4)
        let y = Double(arc4random_uniform(height) + height)
        
        let strawDown = SKSpriteNode(texture: strawTextureDown)
        strawDown.setScale(1.0)
        strawDown.position = CGPoint(x: -100, y: y + 35)
        
        
        strawDown.physicsBody = SKPhysicsBody(rectangleOf: strawDown.size)
        strawDown.physicsBody?.isDynamic = false
        strawDown.physicsBody?.categoryBitMask = strawCategory
        strawDown.physicsBody?.contactTestBitMask = boCategory
        strawPair.addChild(strawDown)
        
        let strawUp = SKSpriteNode(texture: strawTextureUp)
        strawUp.setScale(1.0)
        strawUp.position = CGPoint(x: -100, y:  y - Double(strawUp.size.height) - 290 )
        
        strawUp.physicsBody = SKPhysicsBody(rectangleOf: strawUp.size)
        strawUp.physicsBody?.isDynamic = false
        strawUp.physicsBody?.categoryBitMask = strawCategory
        strawUp.physicsBody?.contactTestBitMask = boCategory
        strawPair.addChild(strawUp)
        
        let contactNode = SKNode()
        contactNode.position = CGPoint( x: -100 / 2, y: self.frame.midY )
        contactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize( width: strawUp.size.width, height: self.frame.size.height ))
        contactNode.physicsBody?.isDynamic = false
        contactNode.physicsBody?.categoryBitMask = scoreCategory
        contactNode.physicsBody?.contactTestBitMask = boCategory
        strawPair.addChild(contactNode)
        
        strawPair.run(moveStrawsAndRemove)
        straws.addChild(strawPair)
        
    }
    
    
    
    func spawnBobas(){
        
        let bobaPair = SKNode()
        bobaPair.position = CGPoint(x: self.frame.size.width + bobaTexture.size().width * 2, y: 250)
       
        
        let height = UInt32( self.frame.size.height / 4)
        let y = Double(arc4random_uniform(height) + height)
     
        
        let boba2 = SKSpriteNode(texture: bobaTexture)
        boba2.setScale(0.50)
        boba2.position = CGPoint(x: -100, y: y - Double(boba2.size.height) - 600)
        
        boba2.physicsBody = SKPhysicsBody(circleOfRadius: boba2.size.height / 2)
        boba2.physicsBody?.isDynamic = false
        boba2.physicsBody?.categoryBitMask = bobaCategory
        boba2.physicsBody?.collisionBitMask = 0
        boba2.physicsBody?.contactTestBitMask = boCategory
        
        // only spawn boba if it's not in the same position as the straws
        if bobaPair.position != straws.position {
            bobaPair.addChild(boba2)
        }
        
        let contactNode = SKNode()
        contactNode.position = CGPoint(x: -100 / 2, y: self.frame.midY)
        contactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize( width: boba2.size.width, height: self.frame.size.height ))
        contactNode.physicsBody?.isDynamic = false
        contactNode.physicsBody?.categoryBitMask = bobaCategory
        contactNode.physicsBody?.contactTestBitMask = boCategory
        bobaPair.addChild(contactNode)
        
        bobaPair.run(moveBobasAndRemove)
        bobas.addChild(bobaPair)
        
    }

    
    
    func resetScene (){
        
        // Move bo to original position and reset velocity
        bo.zPosition = 10
        bo.position = CGPoint(x: -100, y: 125)
        bo.physicsBody?.velocity = CGVector( dx: 0, dy: 0 )
        bo.physicsBody?.categoryBitMask = boCategory
        bo.physicsBody?.contactTestBitMask = worldCategory | strawCategory | bobaCategory
        bo.physicsBody?.collisionBitMask = worldCategory | strawCategory
        bo.speed = 1.0
        bo.zRotation = 0.0
        
        // HEAL BO
        let boHealedTexture = SKTexture(imageNamed: "Boba")
        boHealedTexture.filteringMode = .nearest
        let healed = SKAction.setTexture(boHealedTexture, resize: true)
        bo.run(healed)
        
        // Remove all existing straws
        straws.removeAllChildren()
        
        // Remove all existing bobas
        bobas.removeAllChildren()
        
        // Reset _canRestart
        canRestart = false
        
        // Reset score
        score = 0
        scoreLabelNode.text = String(score)
        
        // Pulls highscore
        if let scoreValue = UserDefaults.standard.object(forKey: "scoreValue") {
            print("highscore found after dying")
            highscoreLabelNode.text = "Best: \(scoreValue)"
        } else {
            print("highscore not found after dying")
            highscoreLabelNode.text = "Best: \(0)"
        }
        
        // Restart animation
        moving.speed = 1
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if moving.speed > 0  {
            for _ in touches {
                bo.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                bo.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 275))
            }
        } else if canRestart {
            self.resetScene()
        }
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Hides current score until a point is made
        scoreLabelNode.isHidden = true
        
        
        if moving.speed > 0 {
            if ( contact.bodyA.categoryBitMask & scoreCategory ) == scoreCategory || ( contact.bodyB.categoryBitMask & scoreCategory ) == scoreCategory {
                
                
                // show score label until score is updated
                scoreLabelNode.isHidden = false
                
                // bo has contact with score entity
                score += 1
                scoreLabelNode.text = String(score)
                
                // Add a little visual feedback for the score increment
                scoreLabelNode.run(SKAction.sequence([SKAction.scale(to: 1.5, duration:TimeInterval(0.1)), SKAction.scale(to: 1.0, duration:TimeInterval(0.1))]))
                
                
            } else if (contact.bodyA.categoryBitMask & boCategory) == boCategory &&
                (contact.bodyB.categoryBitMask & bobaCategory) == bobaCategory {
            

                // show score label until score is updated
                scoreLabelNode.isHidden = false
                
                // Boba Popping Sound
                run(popSound)
                
                // bo has contact with score entity
                score += 1
                scoreLabelNode.text = String(score)
                
                // Add a little visual feedback for the score increment
                scoreLabelNode.run(SKAction.sequence([SKAction.scale(to: 1.5, duration:TimeInterval(0.1)), SKAction.scale(to: 1.0, duration:TimeInterval(0.1))]))
                
                contact.bodyB.node?.removeFromParent()
                
                
            } else if (contact.bodyA.categoryBitMask & bobaCategory) == bobaCategory &&
                (contact.bodyB.categoryBitMask & boCategory) == boCategory {
           
                // show score label until score is updated
                scoreLabelNode.isHidden = false
                
                // Boba Popping Sound
                run(popSound)
                
                // bo has contact with score entity
                score += 1
                scoreLabelNode.text = String(score)
                
                // Add a little visual feedback for the score increment
                scoreLabelNode.run(SKAction.sequence([SKAction.scale(to: 1.5, duration:TimeInterval(0.1)), SKAction.scale(to: 1.0, duration:TimeInterval(0.1))]))
                
                contact.bodyA.node?.removeFromParent()
                
                
            } else {
                
                moving.speed = 0
                
                // When Bo collides into the sidewalk
                bo.physicsBody?.collisionBitMask = worldCategory
                
                // Bo punctured sound
                run(splatSound)
                
                scoreLabelNode.isHidden = false
                
                // BO STABBED
                let boStabbedTexture = SKTexture(imageNamed: "Boba_Straw")
                boStabbedTexture.filteringMode = .nearest
                let stabbed = SKAction.setTexture(boStabbedTexture, resize: true)
                bo.run(stabbed)

                
                // saves and updates highscore
                // compares current highscore to the score and if the current score is high it will update the highscore
                print("trying to save highscore")
                let hscore = UserDefaults.standard.integer(forKey: "scoreValue")
                if hscore < score {
                    UserDefaults.standard.set(scoreLabelNode.text, forKey: "scoreValue")
                    print("highscore is saved after dying")
                }
                
                
                self.run(SKAction.run {
                    self.canRestart = true
                })
                
                
            }
        }
    }
}
