//
//  GameView.swift
//  GameEngine
//
//  Created by Yong Lin Han on 8/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// The `GameView` is a view that contains a `scene`.
/// Provides a `gameLoop` to run the game.
class GameView: UIView {

    /// The `Renderer` used to draw a `scene` on this view.
    private var renderer: Renderer? = nil

    /// The `scene` to be presented on this view.
    private var scene: Scene? = nil

    private var updater: CADisplayLink? = nil

    /// Presents `scene` by using `renderer` to draw GameObjects on itself.
    /// Loops and redraws the `scene` according to specified `gameLoopFramesPerSecond`
    /// in Constants file.
    func present(_ scene: Scene, with renderer: Renderer) {
        self.scene = scene
        self.renderer = renderer
        renderer.draw(scene: scene, on: self)
        let updater = CADisplayLink(target: self,
                                    selector: #selector(self.gameLoop))
        updater.preferredFramesPerSecond = Constants.gameLoopFramesPerSecond
        updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        self.updater = updater
    }

    /// The game loop.
    /// Runs the `scene` for `noOfRunsBeforeRendering` times before redrawing the `scene`.
    @objc private func gameLoop() {
        for _ in 0..<Constants.noOfRunsBeforeRendering {
            // Return if game is over.
            guard let scene = scene else {
                return
            }
            scene.run()
        }
        guard let scene = scene,
              let renderer = renderer else {
            return
        }
        renderer.redraw(scene: scene, on: self)
    }

    func stopPresenting() {
        guard let updater = updater,
              let scene = scene,
              let renderer = renderer else {
            return
        }
        updater.invalidate()
        renderer.reset()
        scene.reset()
        self.updater = nil
        self.renderer = nil
        self.scene = nil
    }

    /// Passes touches on this view onto the `scene`.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let scene = scene else {
            return
        }
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        scene.handleTouch(at: touchLocation)
    }
}
