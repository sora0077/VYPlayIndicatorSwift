//: Playground - noun: a place where people can play

import UIKit
import VYPlayIndicatorSwift

import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true


let view = UIView()
view.backgroundColor = .lightGray
view.frame.size.width = 100
view.frame.size.height = 100
PlaygroundPage.current.liveView = view


let indicator = VYPlayerIndicator()
indicator.frame = view.bounds
view.layer.addSublayer(indicator)


indicator.state = .playing
