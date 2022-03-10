//
//  GameOverScene.swift
//  Orchardman
//
//  Created by Mateusz Jeżewski on 01.10.2016.
//  Copyright © 2016 MateuszJeżewski. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class GameOverScene: SKScene{
    
    
    override func didMove(to view: SKView) {
        let Backround = SKSpriteNode(imageNamed: "Background #1")
        let Button = SKSpriteNode(imageNamed: "sign")
        let Sign = SKSpriteNode(imageNamed: "sign")
        let Sign2 = SKSpriteNode(imageNamed: "sign")
        let Tree = SKSpriteNode(imageNamed: "Tree #1")

        let arrayOfBackgrounds = [
            SKTexture(imageNamed: "Background #1"),
            SKTexture(imageNamed: "Background #2"),
            SKTexture(imageNamed: "Background #3")
            
        ]
        
        let arrayOfTrees = [
            SKTexture(imageNamed: "Tree #1"),
            SKTexture(imageNamed: "Tree #2"),
            SKTexture(imageNamed: "Tree #3")
        ]

        let textInButton = SKLabelNode(text: "PLAY")
        let Pi = CGFloat(Double.pi)
        let DegreesToRadians = Pi / 180
        
        Backround.position = CGPoint(x: size.width/2, y: size.height/2)
        Backround.setScale(1.8)
        Backround.texture! = arrayOfBackgrounds[Rnumber]
        Backround.texture!.filteringMode = .nearest
        addChild(Backround)
        
        Tree.position = CGPoint(x: size.width - 120, y: size.height - size.height * 0.4)
        Tree.setScale(1.3)
        Tree.texture! = arrayOfTrees[Rnumber]
        Tree.texture!.filteringMode = .nearest
        addChild(Tree)
        
        Sign.position = CGPoint(x: size.width/2 - 0.3 * size.width, y: -self.size.height / 3.2)
        Sign.xScale = 6.0
        Sign.yScale = 5.0
        Sign.texture!.filteringMode = .nearest
        addChild(Sign)
        
        Sign2.position = CGPoint(x: size.width/2 + 0.3 * size.width, y: -self.size.height / 3.2)
        Sign2.xScale = 6.0
        Sign2.yScale = 5.0
        Sign2.texture!.filteringMode = .nearest
        addChild(Sign2)
        
        Button.position = CGPoint(x: size.width/2, y: self.size.height * 1.4)
        Button.xScale = 9.0
        Button.yScale = 5.0
        Button.zRotation = 180 * DegreesToRadians
        Button.texture!.filteringMode = .nearest
        Button.name = "Button"
        addChild(Button)
        
        textInButton.position = CGPoint(x: Button.position.x, y: Button.position.y - 30)
        textInButton.name = "Button"
        textInButton.fontName = "04b30"
        textInButton.fontSize = 40
        textInButton.fontColor = SKColor.white
        textInButton.verticalAlignmentMode = .top
        
        addChild(textInButton)
        
        let defaults = UserDefaults.standard
        let hightScore = defaults.integer(forKey: "highscore")
        
        let message = "GAME OVER"
        let message2 = "BEST"
        let message25 = String(hightScore)
        let message3 = "SCORE"
        let message35 = String(score)

        let label = SKLabelNode(fontNamed: "04b30")
        label.text = message
        label.fontSize = 30
        label.fontColor = SKColor.white
        label.position = CGPoint(x: Button.position.x, y: Button.position.y)
        label.verticalAlignmentMode = .center
        addChild(label)

        let label2 = SKLabelNode(fontNamed: "04b30")
        label2.text = message2
        label2.fontSize = 28
        label2.fontColor = SKColor.white
        label2.position = CGPoint(x: Sign.position.x, y: Sign.position.y + 50)
        label2.verticalAlignmentMode = .center
        addChild(label2)
        
        let label25 = SKLabelNode(fontNamed: "04b30")
        label25.text = message25
        label25.fontSize = 40
        label25.fontColor = SKColor.white
        label25.position = CGPoint(x: Sign.position.x, y: Sign.position.y + 10)
        label25.verticalAlignmentMode = .center
        addChild(label25)
        
        
        let label3 = SKLabelNode(fontNamed: "04b30")
        label3.text = message3
        label3.fontSize = 28
        label3.fontColor = SKColor.white
        label3.position = CGPoint(x: Sign2.position.x, y: Sign2.position.y + 50)
        label3.verticalAlignmentMode = .center
        addChild(label3)
        
        let label35 = SKLabelNode(fontNamed: "04b30")
        label35.text = message35
        label35.fontSize = 40
        label35.fontColor = SKColor.white
        label35.position = CGPoint(x: Sign2.position.x, y: Sign2.position.y + 10)
        label35.verticalAlignmentMode = .center
        addChild(label35)
        
        run(SKAction.playSoundFileNamed("Hero_Death_00", waitForCompletion: false))
        
        let vector = CGVector(dx: 0, dy: Sign.size.height * 0.8)
        let acction = SKAction.move(by: vector, duration: 0.5)
        
        Sign.run(acction)
        label2.run(acction)
        label25.run(acction)
        
        Sign2.run(acction)
        label3.run(acction)
        label35.run(acction)
        
        let vector2 = CGVector(dx: 0, dy: -Button.size.height)
        let acction2 = SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.move(by: vector2, duration: 0.5)
            ])
        
        Button.run(acction2)
        label.run(acction2)
        textInButton.run(acction2)
        
        if hightScore == score {
            let medal = SKSpriteNode(imageNamed: "Medal (1)")
            
            medal.position = CGPoint(x: label2.position.x + 60, y: label2.position.y - 70)
            medal.setScale(0.6)
            addChild(medal)
            medal.run(acction)
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: self) {
            let touchedNode = self.atPoint(location)
            
            if touchedNode.name == "Button" {
                
                let Scene = GameScene(size: self.scene!.size)
                Scene.scaleMode = SKSceneScaleMode.aspectFill
                
                scene?.view!.presentScene(Scene, transition: SKTransition.fade(withDuration: 1))
                
                removeAllActions()
                removeAllChildren()
            }
        }
    }
}
