//
//  AIRecordableGameScene.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/16/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit
import GameplayKit
import SwiftUI

/// A subclass of a challenge game scene that allows users to record states.
class AIRecordableGameScene: GameScene {

    /// The state recording machine.
    var journal: StateRecorderViewModel?

    /// The strategy to use for state recording.
    var strategy: AITreeStrategy?

    /// The game's current abstract state.
    var state: AIAbstractGameState?

    /// The recording window.
    var recorder: NSWindowController?

    /// Set up the scene, journal, and strategy to begin recording.
    override func sceneDidLoad() {
        super.sceneDidLoad()
        self.state = self.getState()
        self.strategy = AITreeStrategy()
        self.strategy?.gameModel = self.state

        print("TEST")

        guard let firstAssessment = self.strategy?.assess(state: self.state!) else {
            return
        }

        self.journal = StateRecorderViewModel(from: firstAssessment) { _, action in
            let realActionName = self.strategy?.process(action, from: self.state!)
            self.apply(
                AIGameDecision(
                    by: AIGamePlayerAction(rawValue: realActionName ?? "stop") ?? .stop,
                        with: 0
                )
            )
        }
        self.makeRecorder()
    }

    override func willMove(from view: SKView) {
        self.recorder?.close()
    }

    func makeRecorder() {
        guard let journal = self.journal else { return }
        let recordingView = NSHostingView(rootView: AIStateRecordingView(journal: journal))
        let viewController = NSViewController()
        viewController.view = recordingView

        let toolbar = NSHostingView(rootView: AIStateRecordingToolbar(journal: journal))
        toolbar.frame.size = toolbar.fittingSize
        let accessory = NSTitlebarAccessoryViewController()
        accessory.view = toolbar
        accessory.layoutAttribute = .trailing

        let window = NSWindow(contentViewController: viewController)
        window.title = "State Recorder"
        window.styleMask.remove(.resizable)

        window.toolbar = NSToolbar()
        window.toolbar?.sizeMode = .regular
        window.addTitlebarAccessoryViewController(accessory)
        window.appearance = NSAppearance(named: .darkAqua)

        let windowController = NSWindowController(window: window)
        self.recorder = windowController
        windowController.showWindow(nil)
    }

    /// Prevent the player from doing anything that could influence state updates.
    func blockInput() {
        NSSound.beep()
    }

    /// Prevent keyboard input.
    override func keyDown(with event: NSEvent) {
        blockInput()
    }

    /// Run the AI's version of didFinishUpdate.
    override func didFinishUpdate() {
        self.aiFinish()
    }

    /// Run any post-update logic and check input states.
    func aiFinish() {
        for input in self.switches where input.activationMethod.contains(.activeByPlayerIntervention) {
            if [GameSignalKind.pressurePlate, GameSignalKind.trigger].contains(input.kind)
                && !(input is GameIrisScanner) {
                input.activate(with: nil, player: self.playerNode, objects: self.interactables)
            } else if input is GameIrisScanner &&
                        input.shouldActivateOnIntervention(with: self.playerNode, objects: self.interactables) {
                input.activate(with: nil, player: self.playerNode, objects: self.interactables)
            }
        }
        self.checkDoorStates()
        if self.exitNode?.active == true {
            self.exitNode?.receive(with: self.playerNode, event: nil) { _ in }
        }
        for child in self.structure.children where child is GameDeathPit {
            guard let pit = child as? GameDeathPit else { continue }
            if pit.shouldKill(self.playerNode) && !self.playerDied {
                self.kill()
            }
        }
    }

    /// Capture the current scene as a game state.
    /// - Returns: An abstract version of the world as a game state that the agent can use.
    func getState() -> AIAbstractGameState? {
        guard let player = playerNode else { return nil }
        let state = AIAbstractGameState(with: AIAbstractGamePlayer(at: player.position, with: player.costumes))
        state.exit = self.exitNode?.position ?? CGPoint.zero

        var signals = [AIAbstractGameSignalSender]()
        for input in self.switches {
            var signal = AIAbstractGameSignalSender(
                kind: input.kind,
                position: input.position,
                prettyPosition: input.worldPosition,
                active: input.active,
                outputs: input.receivers.map { out in out.position }
            )
            signal.timer = Int(input.cooldown)
            signals.append(signal)
        }

        var receivers = [AIAbstractGameSignalReceivable]()
        for output in self.receivers {
            receivers.append(
                AIAbstractGameSignalReceivable(active: output.active, location: output.position)
            )
        }

        state.inputs = signals
        state.outputs = receivers
        state.escapable = self.exitNode?.active ?? false

        return state
    }

    /// Re-evaluate the state and update the assessments.
    func reevaluate() {
        guard let newState = self.getState() else { return }
        self.state = newState
        self.strategy?.gameModel = newState

        guard let gameState = self.strategy?.gameModel as? AIAbstractGameState else {
            return
        }
        self.strategy?.evaluateEnvironmentVariables(from: gameState)
        guard let assessment = self.strategy?.assess(state: gameState) else {
            return
        }
        self.journal?.currentAssessment = assessment
    }

    /// Apply a game state update to the scene.
    /// - Parameter action: The action that will be performed to change the state.
    func apply(_ action: AIGameDecision) {
        var actions = [SKAction]()

        switch action.action {
        case .moveUp, .moveDown, .moveLeft, .moveRight:
            actions = [
                SKAction.run {
                    for _ in 1 ... 14 {
                        self.playerNode?.move(
                            PlayerMoveDirection.mappedFromAction(action.action),
                            unit: self.unit ?? CGSize(squareOf: 128)
                        )
                    }
                },
                SKAction.wait(forDuration: 2.5),
                SKAction.run { self.playerNode?.halt() }
            ]
        case .switchToNextCostume, .switchToPreviousCostume:
            actions = [
                SKAction.run {
                    _ = action.action == .switchToNextCostume
                        ? self.playerNode?.nextCostume()
                        : self.playerNode?.previousCostume()
                }
            ]
        case .deployClone, .retractClone:
            actions = [
                SKAction.run {
                    self.playerNode?.copyAsObject()
                }
            ]
        case .pickup:
            actions = [
                SKAction.run {
                    for object in self.interactables {
                        object.attach(to: self.playerNode)
                    }
                }
            ]
        case .drop:
            actions = [
                SKAction.run {
                    for object in self.interactables {
                        object.resign(from: self.playerNode)
                    }
                }
            ]
        case .activate:
            actions = [
                SKAction.run {
                    self.checkInputStates(NSEvent())
                }
            ]
        default:
            self.playerNode?.halt()
        }
        self.run(SKAction.sequence(actions))

        self.reevaluate()
    }

}
