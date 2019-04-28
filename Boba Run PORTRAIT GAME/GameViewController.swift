//
//  GameViewController.swift
//  Boba Run PORTRAIT GAME
//
//  Created by Tegan Chin on 3/28/19.
//  Copyright © 2019 Cyberdev. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVKit

extension SKNode {
    class func unarchiveFromFile(_ file : String) -> SKNode? {
        
        let path = Bundle.main.path(forResource: file, ofType: "sks")
        
        let sceneData: Data?
        do {
            sceneData = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        } catch _ {
            sceneData = nil
        }
        let archiver = NSKeyedUnarchiver(forReadingWith: sceneData!)
        
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
        archiver.finishDecoding()
        return scene
    }
}

class GameViewController: UIViewController {
    
    var buttonOnOff = 0
    @IBOutlet weak var audioButton: UIButton!
    
    // turns audio on/off
    @IBAction func audioButton(_ sender: Any) {
        buttonOnOff += 1
        
        if buttonOnOff == 1 {
            //mute audio
            audioButton.setImage(UIImage(named: "mute"), for: .normal)
            music.stop()
            
        } else if buttonOnOff == 2 {
            //unmute audio
            audioButton.setImage(UIImage(named: "unmute"), for: .normal)
            music.play()
            
            buttonOnOff = 0
        }
    }
    
    
    var music:AVAudioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //plays background music
        let bgmusic = Bundle.main.path(forResource: "265549__vikuserro__cheap-flash-game-tune", ofType: ".mp3")
        do {
            try music = AVAudioPlayer(contentsOf:URL(fileURLWithPath: bgmusic!))
        }
        catch {
            print(error)
        }
        
        
        if let view = self.view as! SKView? {
            
            // loops background music
            music.numberOfLoops = -1
            music.play()
            
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            //view.showsFPS = true
            //view.showsNodeCount = true
        }
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
