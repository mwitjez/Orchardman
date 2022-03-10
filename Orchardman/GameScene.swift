//
//  GameScene.swift
//  Orchardman
//
//  Created by Mateusz Jeżewski on 01.10.2016.
//  Copyright © 2016 MateuszJeżewski. All rights reserved.
//

import SpriteKit
import CoreMotion
import SceneKit
import AVFoundation

let MaxBarAcceleration: CGFloat = 3
var score: Int = 0
let ScoreLabel = SKLabelNode(fontNamed: "04b30")
let ScoreLabelShadow = SKLabelNode(fontNamed: "04b30")
let Pi = CGFloat(Double.pi)
let DegreesToRadians = Pi / 180
let RadiansToDegrees = 180 / Pi
let screenSize: CGRect = UIScreen.main.bounds

var Rnumber = 0


class GameScene: SKScene, SKPhysicsContactDelegate {
    let BallCategory: UInt32 = 0x1 << 0
    let EdgesCategory: UInt32 = 0x1 << 1
    let TargetCategory: UInt32 = 0x1 << 2

    var motionManager = CMMotionManager()
    var accelerometerX: UIAccelerationValue = 0
    var accelerometerY: UIAccelerationValue = 0
    var BarAcceleration = CGVector(dx: 0, dy: 0)

    var previousAngle: CGFloat = 0
    var BarAngle: CGFloat = 0

    var backgroundMusic: AVAudioPlayer?

    var Bar = SKSpriteNode(imageNamed: "Player #1")
    let Ball = SKSpriteNode(imageNamed: "Apple #1")
    let Target = SKSpriteNode(imageNamed: "Target")
    let Backround = SKSpriteNode(imageNamed: "Background #1")
    let Tree = SKSpriteNode(imageNamed: "Tree #1")
    let label = SKLabelNode(fontNamed: "04b30")
    let Title = SKSpriteNode(imageNamed: "Title")
    let Settings = SKSpriteNode(imageNamed: "Settings")
    let SettingsLabel = SKLabelNode(fontNamed: "04b30")
    let BackLabel = SKLabelNode(fontNamed: "04b30")
    let Back = SKSpriteNode(imageNamed: "Settings")
    let arrowL = SKSpriteNode(imageNamed: "ArrowLeft")
    let arrowR = SKSpriteNode(imageNamed: "ArrowRight")
    let Authors = SKSpriteNode(imageNamed: "Settings")
    let AuthorsLabel = SKLabelNode(fontNamed: "04b30")
    let AuthorsGlory = SKSpriteNode(imageNamed: "Authors")
    let framePicture = SKSpriteNode(imageNamed: "Frame")
    let blour = SKShapeNode(rect: screenSize)


    var Tapped = false
    var SkinNumber = 0

    let arrayOfSkins = [
        SKTexture(imageNamed: "Player #1"),
        SKTexture(imageNamed: "Player #2"),
        SKTexture(imageNamed: "Player #3"),
        SKTexture(imageNamed: "Player #4"),
        SKTexture(imageNamed: "Player #5"),
    ]

    let arrayOfBackgrounds = [
        SKTexture(imageNamed: "Background #1"),
        SKTexture(imageNamed: "Background #2"),
        SKTexture(imageNamed: "Background #3"),
    ]

    let arrayOfTrees = [
        SKTexture(imageNamed: "Tree #1"),
        SKTexture(imageNamed: "Tree #2"),
        SKTexture(imageNamed: "Tree #3"),
    ]


    func setupAudioPlayerWithFile(_ file: NSString, type: NSString) -> AVAudioPlayer? {
        let path = Bundle.main.path(forResource: file as String, ofType: type as String)
        let url = URL(fileURLWithPath: path!)

        var audioPlayer: AVAudioPlayer?

        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url)
        } catch {
            print("Player not available")
        }

        return audioPlayer
    }


    override func didMove(to view: SKView) {
        if let backgroundMusic = self.setupAudioPlayerWithFile("The Show Must Be Go", type: "mp3") {
            self.backgroundMusic = backgroundMusic
        }

        backgroundMusic?.volume = 0.3
        backgroundMusic?.play()

        score = 0

        UIApplication.shared.isIdleTimerDisabled = true

        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0);
        physicsWorld.contactDelegate = self

        size = view.bounds.size

        /* Random background*/
        let HowManyBg = arrayOfBackgrounds.count
        let BackgroundDiceRoll = Int(arc4random_uniform(UInt32(HowManyBg)))

        Rnumber = BackgroundDiceRoll
        Backround.position = CGPoint(x: size.width / 2, y: size.height / 2)
        Backround.name = "Playable"
        Backround.setScale(1.8)
        Backround.zPosition = -2
        Backround.texture!.filteringMode = .nearest
        Backround.texture! = arrayOfBackgrounds[BackgroundDiceRoll]
        addChild(Backround)

        Tree.position = CGPoint(x: size.width - 120, y: size.height - size.height * 0.4)
        Tree.setScale(1.3)
        Tree.texture! = arrayOfTrees[BackgroundDiceRoll]
        Tree.texture!.filteringMode = .nearest
        Tree.name = "Playable"
        addChild(Tree)

        let action = SKAction.run(moveClouds)
        let action2 = SKAction.wait(forDuration: 4)
        let sequence = SKAction.sequence([action, action2])
        let actionRepeat = SKAction.repeatForever(sequence)
        run(actionRepeat)

        Target.physicsBody = SKPhysicsBody(rectangleOf: Target.size)
        Target.physicsBody!.affectedByGravity = false
        Target.physicsBody!.allowsRotation = false
        Target.physicsBody!.isDynamic = false
        Target.physicsBody!.friction = 0
        Target.physicsBody!.restitution = 0
        Target.physicsBody!.linearDamping = 0
        Target.physicsBody!.angularDamping = 0

        Ball.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        Ball.physicsBody!.allowsRotation = true
        Ball.physicsBody!.friction = 0
        Ball.physicsBody!.restitution = 1
        Ball.physicsBody!.linearDamping = 0
        Ball.physicsBody!.angularDamping = 0

        let edge1 = SKNode()
        edge1.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 0), to: CGPoint(x: size.width, y: 0))
        let edge2 = SKNode()
        edge2.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: size.height * 2))
        let edge3 = SKNode()
        edge3.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: size.width, y: -size.height), to: CGPoint(x: size.width, y: size.height * 2))
        let edge4 = SKNode()
        edge4.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: size.height * 1.2), to: CGPoint(x: size.width, y: size.height * 2))

        addChild(edge1)
        addChild(edge2)
        addChild(edge3)
        addChild(edge4)

        edge1.physicsBody!.categoryBitMask = EdgesCategory
        edge2.physicsBody!.categoryBitMask = EdgesCategory
        edge3.physicsBody!.categoryBitMask = EdgesCategory
        edge4.physicsBody!.categoryBitMask = EdgesCategory

        Target.physicsBody!.categoryBitMask = TargetCategory
        Ball.physicsBody!.categoryBitMask = BallCategory
        Ball.physicsBody!.contactTestBitMask = EdgesCategory | TargetCategory

        label.text = "TAP TO PLAY"
        label.name = "Playable"
        label.fontSize = 30
        label.fontColor = SKColor.white
        label.position = CGPoint(x: 0.5 * size.width, y: 0.3 * size.height)
        addChild(label)

        let zoomIn = SKAction.scale(to: 1.25, duration: 0.7)
        let zoomOut = SKAction.scale(to: 1.0, duration: 0.7)
        let zoom = SKAction.sequence([zoomIn, zoomOut])
        let ZoomRepeat = SKAction.repeatForever(zoom)
        label.run(ZoomRepeat)

        Title.position = CGPoint(x: size.width / 2, y: size.height - 100)
        Title.name = "Playable"
        Title.setScale(0.7)
        Title.texture!.filteringMode = .linear
        addChild(Title)

        Settings.position = CGPoint(x: 0.2 * size.width, y: 0.15 * size.height)
        Settings.setScale(0.65)
        Settings.name = "Settings"
        addChild(Settings)

        SettingsLabel.text = "Settings"
        SettingsLabel.name = "Settings"
        SettingsLabel.fontSize = 20
        SettingsLabel.fontColor = SKColor.white
        SettingsLabel.position = Settings.position
        addChild(SettingsLabel)

        Authors.position = CGPoint(x: 0.8 * size.width, y: 0.15 * size.height)
        Authors.setScale(0.65)
        Authors.name = "Authors"
        addChild(Authors)

        AuthorsLabel.text = "Authors"
        AuthorsLabel.name = "Authors"
        AuthorsLabel.fontSize = 20
        AuthorsLabel.fontColor = SKColor.white
        AuthorsLabel.position = Authors.position
        addChild(AuthorsLabel)
    }


    func moveClouds() {
        let Cloud = SKSpriteNode(imageNamed: "Cloud #1")

        if Rnumber == 2 {
            Cloud.texture! = SKTexture(imageNamed: "Cloud #2")
        }

        Cloud.position = CGPoint(x: size.width - 1.2 * size.width, y: size.height * CGFloat.random(in: 0.6 ..< 0.9))
        Cloud.setScale(1.8)
        Cloud.texture!.filteringMode = .nearest
        Cloud.zPosition = -1
        Cloud.isHidden = false
        Cloud.name = "Playable"
        addChild(Cloud)

        let actionMove = SKAction.moveTo(x: size.width, duration: 10)
        let actionRemove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([actionMove, actionRemove])
        Cloud.run(sequence)
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        if let location = touches.first?.location(in: self) {
            let touchedNode = self.atPoint(location)

            if touchedNode.name == "Playable" && Tapped == false {
                label.removeFromParent()
                Title.removeFromParent()
                Settings.removeFromParent()
                SettingsLabel.removeFromParent()
                Back.removeFromParent()
                BackLabel.removeFromParent()
                arrowR.removeFromParent()
                arrowL.removeFromParent()
                Authors.removeFromParent()
                AuthorsLabel.removeFromParent()
                AuthorsGlory.removeFromParent()

                Bar.position = CGPoint(x: size.width - 50, y: 60)
                Bar.setScale(1.6)
                Bar.physicsBody = SKPhysicsBody(rectangleOf: Bar.size)
                Bar.physicsBody!.affectedByGravity = false
                Bar.physicsBody!.allowsRotation = false
                Bar.physicsBody!.isDynamic = false
                Bar.physicsBody!.friction = 0
                Bar.physicsBody!.restitution = 2.2
                Bar.physicsBody!.linearDamping = 0
                Bar.physicsBody!.angularDamping = 0
                Bar.texture = arrayOfSkins[UserDefaults.standard.integer(forKey: "Skin")]
                Bar.texture!.filteringMode = .nearest

                startMonitoringAcceleration()

                let action = SKAction.repeatForever(SKAction.sequence([
                    SKAction.run(addTarget),
                    SKAction.wait(forDuration: 0.6),
                    SKAction.run(addBall),
                    SKAction.wait(forDuration: 2.3)
                ]))

                addChild(Bar)
                run(action)

                Tapped = true
            }

            if touchedNode.name == "Settings" {
                run(SKAction.playSoundFileNamed("Menu_Navigate_00.mp3", waitForCompletion: false))

                Back.removeFromParent()
                BackLabel.removeFromParent()
                AuthorsGlory.removeFromParent()

                blour.fillColor = SKColor.black
                blour.alpha = 0.7
                blour.lineWidth = 0
                blour.miterLimit = 10

                addChild(blour)

                Back.position = CGPoint(x: 0.2 * size.width, y: 0.15 * size.height)
                Back.setScale(0.65)
                Back.name = "Back"
                addChild(Back)

                BackLabel.text = "Back"
                BackLabel.name = "Back"
                BackLabel.fontSize = 20
                BackLabel.fontColor = SKColor.white
                BackLabel.position = Settings.position
                addChild(BackLabel)

                arrowL.position = CGPoint(x: 0.2 * size.width, y: 0.55 * size.height)
                arrowR.position = CGPoint(x: 0.8 * size.width, y: 0.55 * size.height)

                arrowL.setScale(5)
                arrowR.setScale(5)

                arrowL.name = "arrowL"
                arrowR.name = "arrowR"

                arrowL.texture?.filteringMode = .nearest
                arrowR.texture?.filteringMode = .nearest

                addChild(arrowL)
                addChild(arrowR)

                framePicture.position = CGPoint(x: 0.5 * size.width, y: 0.57 * size.height)
                framePicture.texture!.filteringMode = .nearest
                framePicture.setScale(1.8)
                addChild(framePicture)

                Bar.position = CGPoint(x: 0.5 * size.width, y: 0.424 * size.height)
                Bar.texture!.filteringMode = .nearest
                Bar.setScale(1.6)
                addChild(Bar)
            }

            if touchedNode.name == "arrowL" {
                if SkinNumber > 0 {
                    run(SKAction.playSoundFileNamed("Menu_Navigate_00.mp3", waitForCompletion: false))
                    SkinNumber -= 1
                    UserDefaults.standard.set(SkinNumber, forKey: "Skin")
                    Bar.texture = arrayOfSkins[UserDefaults.standard.integer(forKey: "Skin")]
                    Bar.texture!.filteringMode = .nearest
                    UserDefaults.standard.synchronize()
                }
            }

            if touchedNode.name == "arrowR" {
                if SkinNumber < arrayOfSkins.count - 1 {
                    run(SKAction.playSoundFileNamed("Menu_Navigate_00.mp3", waitForCompletion: false))
                    SkinNumber += 1
                    UserDefaults.standard.set(SkinNumber, forKey: "Skin")
                    Bar.texture = arrayOfSkins[UserDefaults.standard.integer(forKey: "Skin")]
                    Bar.texture!.filteringMode = .nearest
                    UserDefaults.standard.synchronize()
                }
            }

            if touchedNode.name == "Back" {
                run(SKAction.playSoundFileNamed("Menu_Navigate_00.mp3", waitForCompletion: false))
                AuthorsGlory.position = CGPoint(x: 0.5 * size.width, y: -0.5 * size.height)
                Back.removeFromParent()
                BackLabel.removeFromParent()
                arrowR.removeFromParent()
                arrowL.removeFromParent()
                Bar.removeFromParent()
                AuthorsGlory.removeFromParent()
                removeAction(forKey: "sequenceOfGlory")
                blour.removeFromParent()
                framePicture.removeFromParent()
            }

            if touchedNode.name == "Authors" {
                run(SKAction.playSoundFileNamed("Menu_Navigate_00.mp3", waitForCompletion: false))

                blour.fillColor = SKColor.black
                blour.alpha = 0.7
                blour.lineWidth = 0
                blour.miterLimit = 10

                addChild(blour)


                AuthorsGlory.position = CGPoint(x: 0.5 * size.width, y: -0.5 * size.height)
                AuthorsGlory.setScale(0.4)
                addChild(AuthorsGlory)

                Back.position = CGPoint(x: 0.8 * size.width, y: 0.15 * size.height)
                Back.setScale(0.65)
                Back.name = "Back"
                addChild(Back)

                BackLabel.text = "Back"
                BackLabel.name = "Back"
                BackLabel.fontSize = 20
                BackLabel.fontColor = SKColor.white
                BackLabel.position = Authors.position
                addChild(BackLabel)

                let moveGlory = SKAction.moveTo(y: 1.5 * size.height, duration: 10)
                let backGlory = SKAction.moveTo(y: -0.5 * size.height, duration: 0)
                let sequenceOfGlory = SKAction.sequence([moveGlory, backGlory])
                AuthorsGlory.run(sequenceOfGlory, withKey: "sequenceOfGlory")
            }
        }
    }


    func startMonitoringAcceleration() {
        if motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates()
            NSLog("accelerometer updates on...")
        }
        else {
            NSLog("Can not do this")
        }
    }


    func stopMonitoringAcceleration() {
        if motionManager.isAccelerometerAvailable && motionManager.isAccelerometerActive {
            motionManager.stopAccelerometerUpdates()
            NSLog("accelerometer updates off...")

        }
    }


    func updateBarAccelerationFromMotionManager() {
        if let acceleration = motionManager.accelerometerData?.acceleration {
            let FilterFactor = 0.1
            accelerometerY = acceleration.y * FilterFactor + accelerometerY * (1 - FilterFactor)
            BarAcceleration.dx = CGFloat(accelerometerY)
        }
    }


    func updateBar() {
        let angle = atan(BarAcceleration.dx) * 4
        BarAngle = angle / 1.7

        if BarAngle > 0.02 && BarAngle < 1.1 {
            Bar.zRotation = BarAngle
        }
    }


    func addBall() {
        Ball.position = CGPoint(x: size.width - 100, y: 300)
        Ball.setScale(1.2)
        Ball.texture!.filteringMode = .nearest
        addChild(Ball)
    }

    func addTarget() {
        Target.setScale(1.2)
        Target.texture!.filteringMode = .nearest
        Target.position = CGPoint(x: size.width - size.width * 0.95, y: size.height *  CGFloat.random(in: 0.1 ..< 0.85))
        addChild(Target)
    }


    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == EdgesCategory {
            if score > UserDefaults().integer(forKey: "highscore") {
                let defaults = UserDefaults.standard
                defaults.set(score, forKey: "highscore")
                defaults.synchronize()
            }

            let gameOverScene = GameOverScene(size: scene!.size)
            gameOverScene.scaleMode = SKSceneScaleMode.aspectFill
            scene?.view?.presentScene(gameOverScene)
            backgroundMusic?.pause()
            removeAllActions()
            removeAllChildren()
        }

        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == TargetCategory {
            run(SKAction.playSoundFileNamed("Collect_Point_01", waitForCompletion: false))
            score += 1
            ScoreLabel.removeFromParent()
            ScoreLabelShadow.removeFromParent()
            updateScore()
            addChild(ScoreLabelShadow)
            addChild(ScoreLabel)
            firstBody.node!.removeFromParent()
            secondBody.node!.removeFromParent()
        }
    }


    func updateScore() {
        ScoreLabel.text = String(score)
        ScoreLabel.fontSize = 66
        ScoreLabel.fontColor = SKColor.white
        ScoreLabel.position = CGPoint(x: 0.5 * size.width, y: 0.65 * size.height)
        ScoreLabelShadow.text = String(score)
        ScoreLabelShadow.fontSize = 72
        ScoreLabelShadow.fontColor = SKColor.black
        ScoreLabelShadow.position = CGPoint(x: 0.505 * size.width, y: 0.65 * size.height)
    }


    override func update(_ currentTime: TimeInterval) {
        updateBarAccelerationFromMotionManager()
        updateBar()
    }

    deinit {
        stopMonitoringAcceleration()
    }
}
