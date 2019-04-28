//
//  LaunchScreen.swift
//  Boba Run PORTRAIT GAME
//
//  Created by Tegan Chin on 4/18/19.
//  Copyright © 2019 Cyberdev. All rights reserved.
//
//  Code Referenced from https://guides.codepath.com/ios/Animating-A-Sequence-of-Images

import UIKit
import SpriteKit

class LaunchScreenVC: UIViewController {
    
    var bo: UIImage!
    var boBlink: UIImage!
    var boTongue: UIImage!
    var boKiss: UIImage!
    var images: [UIImage]!
    var imageShuffled: [UIImage]!
    var animatedBo: UIImage!
    
    
    @IBOutlet weak var boImage: UIImageView!
    
    @IBAction func toGameVC(_ sender: Any) {
        performSegue(withIdentifier: "toGameVC", sender: self)
    }
    
    @IBOutlet weak var HintLabel: UILabel!
    
    @IBOutlet weak var gameTitleLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        
        // animates Bo
        bo = UIImage(named: "Boba")
        boBlink = UIImage(named: "Bo_Blink")
        boTongue = UIImage(named: "Bo_Tongue")
        boKiss = UIImage(named: "Bo_Kiss")
        
        images = [boTongue, boKiss]

        imageShuffled = images.shuffled()
        
        // bo normal for first image
        imageShuffled.insert(bo, at: 0)
        // add Bo blinking at every other in array
        imageShuffled.insert(boBlink, at: 1)
        imageShuffled.insert(boBlink, at: 3)
      
        
        animatedBo = UIImage.animatedImage(with: imageShuffled, duration: 3.65)
   
        boImage.image = animatedBo
        
        
        hintLoop()
        
        // loops hintLoop() every 10 seconds
        Timer.scheduledTimer(timeInterval: 24, target: self, selector: #selector(hintLoop), userInfo: nil, repeats: true)
        

    }
    
    
    // Changes hints every 6 seconds
    @objc func hintLoop() {
        
        //Hint1
        HintLabel.text = "Hint: Avoid the straws"
        
        //Hint2
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6)) {
            self.HintLabel.text = "Hint: Get boba for extra points"
        }
        
        //Hint3
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(12)) {
            self.HintLabel.text = "Hint: Don't stop tapping!"
        }
        
        //Hint4
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(18)) {
            self.HintLabel.text = "Hint: Don't let Bo touch the sidewalk"
        }
    }
    
    
}
