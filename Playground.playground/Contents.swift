//: Playground - noun: a place where people can play

import UIKit
import VYPlayIndicatorSwift

import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true


let view = VYPlayerIndicatorView()
view.backgroundColor = .white
view.frame.size.width = 100
view.frame.size.height = 100
PlaygroundPage.current.liveView = view


view.state = .playing

