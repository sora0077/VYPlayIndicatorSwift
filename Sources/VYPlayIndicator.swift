//
//  VYPlayIndicator.swift
//  VYPlayIndicatorSwift
//

import UIKit


private let pathKey = "path"
private let opacityKey = "opacity"
private let frameKey = "keyFrame"

public class VYPlayIndicator: CALayer {
    
    public enum State {
        case stopped, playing, paused
    }
    
    public var state: State {
        set {
            switch newValue {
            case .stopped:
                stopPlayback()
            case .playing:
                animatePlayback()
            case .paused:
                pausePlayback()
            }
        }
        get {
            let opacity = animation(forKey: opacityKey) as? CABasicAnimation
            let keyframe = firstBeam.animation(forKey: frameKey)
            
            if keyframe != nil {
                return .playing
            } else if let value = opacity?.toValue as? Float, value > 0 {
                return .paused
            } else {
                return .stopped
            }
        }
    }
    
    public var color: UIColor = .red {
        didSet {
            firstBeam.fillColor = color.cgColor
            secondBeam.fillColor = color.cgColor
            thirdBeam.fillColor = color.cgColor
        }
    }
    
    public var completion: () -> Void = {}
    
    fileprivate let firstBeam = CAShapeLayer()
    
    fileprivate let secondBeam = CAShapeLayer()
    
    fileprivate let thirdBeam = CAShapeLayer()
    
    
    public override init() {
        super.init()
        setup()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addSublayer(firstBeam)
        addSublayer(secondBeam)
        addSublayer(thirdBeam)
        
        color = .red
        
        firstBeam.isOpaque = true
        secondBeam.isOpaque = true
        thirdBeam.isOpaque = true
        
        opacity = 0
        
        applyPath()
    }
    
    public func animatePlayback() {
        let opacity = CABasicAnimation(keyPath: opacityKey)
        opacity.toValue = 1
        opacity.fromValue = presentation()?.value(forKeyPath: opacityKey)
        opacity.duration = 0.2
        opacity.fillMode = kCAFillModeBoth
        opacity.isRemovedOnCompletion = false
        
        let firstKeyframe = CAKeyframeAnimation(keyPath: pathKey)
        firstKeyframe.duration = 1.75
        firstKeyframe.beginTime = CACurrentMediaTime() + 0.35
        firstKeyframe.fillMode = kCAFillModeForwards
        firstKeyframe.isRemovedOnCompletion = false
        firstKeyframe.autoreverses = true
        firstKeyframe.repeatCount = Float.infinity
        
        let secondKeyframe = firstKeyframe.copy() as! CAKeyframeAnimation
        let thirdKeyframe = firstKeyframe.copy() as! CAKeyframeAnimation
        
        let count = 10
        
        firstKeyframe.values = randomPaths(count: count)
        secondKeyframe.values = randomPaths(count: count)
        thirdKeyframe.values = randomPaths(count: count)
        
        firstKeyframe.keyTimes = randomKeytimes(count: count)
        secondKeyframe.keyTimes = randomKeytimes(count: count)
        thirdKeyframe.keyTimes = randomKeytimes(count: count)
        
        firstKeyframe.timingFunctions = randomTimingFunctions(count: count)
        secondKeyframe.timingFunctions = randomTimingFunctions(count: count)
        thirdKeyframe.timingFunctions = randomTimingFunctions(count: count)
        
        let begin = CABasicAnimation(keyPath: pathKey)
        begin.duration = 0.35
        begin.fillMode = kCAFillModeRemoved
        begin.isRemovedOnCompletion = true
        
        let secondBegin = begin.copy() as! CABasicAnimation
        let thirdBegin = begin.copy() as! CABasicAnimation
        
        begin.fromValue = firstBeam.presentation()?.value(forKeyPath: pathKey)
        secondBegin.fromValue = secondBeam.presentation()?.value(forKeyPath: pathKey)
        thirdBegin.fromValue = thirdBeam.presentation()?.value(forKeyPath: pathKey)
        
        begin.toValue = firstKeyframe.values?.first
        secondBegin.toValue = secondKeyframe.values?.first
        thirdBegin.toValue = thirdKeyframe.values?.first
        
        firstBeam.add(begin, forKey: begin.keyPath)
        firstBeam.add(firstKeyframe, forKey: frameKey)
        secondBeam.add(secondBegin, forKey: secondBegin.keyPath)
        secondBeam.add(secondKeyframe, forKey: frameKey)
        thirdBeam.add(thirdBegin, forKey: thirdBegin.keyPath)
        thirdBeam.add(thirdKeyframe, forKey: frameKey)
        
        add(opacity, forKey: opacity.keyPath)
    }
    
    public func stopPlayback() {
        pausePlayback()
        
        let opacity = CABasicAnimation(keyPath: opacityKey)
        opacity.toValue = 0
        opacity.fromValue = presentation()?.value(forKeyPath: opacityKey)
        opacity.beginTime = CACurrentMediaTime() + 0.2 * 0.8
        opacity.duration = 0.1
        opacity.fillMode = kCAFillModeBoth
        opacity.isRemovedOnCompletion = false
        opacity.delegate = self
        add(opacity, forKey: opacityKey)
    }
    
    public func pausePlayback() {
        let path = makePath(withPercentage: 5)
        let animation = CABasicAnimation(keyPath: pathKey)
        animation.toValue = path.cgPath
        animation.duration = 0.2
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.isRemovedOnCompletion = false
        
        [firstBeam, secondBeam, thirdBeam].forEach {
            let step = animation.copy() as! CABasicAnimation
            step.fromValue = $0.presentation()?.value(forKeyPath: pathKey)
            $0.removeAnimation(forKey: frameKey)
            $0.add(step, forKey: pathKey)
        }
    }
    
    public func reset() {
        removeAllAnimations()
        
        [firstBeam, secondBeam, thirdBeam].forEach {
            applyPath()
            $0.removeAllAnimations()
            $0.fillColor = color.cgColor
        }
    }
    
    public override func layoutSublayers() {
        super.layoutSublayers()
        
        applyPath()
    }
}

extension VYPlayIndicator: CAAnimationDelegate {
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard !flag else { return }
        
        completion()
        completion = {}
    }
}

extension VYPlayIndicator {
    
    fileprivate func randomPaths(count: Int) -> [CGPath] {
        return (0..<count).map { _ in
            makePath(withPercentage: CGFloat(arc4random_uniform(UInt32.max)) / CGFloat(UInt32.max) * 100).cgPath
        }
    }
    
    fileprivate func randomTimingFunctions(count: Int) -> [CAMediaTimingFunction] {
        let timings = [
            kCAMediaTimingFunctionLinear,
            kCAMediaTimingFunctionEaseInEaseOut,
            kCAMediaTimingFunctionEaseOut,
            kCAMediaTimingFunctionEaseIn
        ]
        return (0..<count).map { _ in
            CAMediaTimingFunction(name: timings[Int(arc4random_uniform(UInt32(timings.count)))])
        }
    }
    
    fileprivate func randomKeytimes(count: Int) -> [NSNumber] {
        return (0..<count).map { i in
            NSNumber(value: Double(i) / Double(count))
        }
    }
    
}

extension VYPlayIndicator {
    
    fileprivate func makePath(withPercentage factor: CGFloat) -> UIBezierPath {
        let origin = CGPoint(x: bounds.maxX * 0.25, y: bounds.height - bounds.height * factor / 100)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: origin.x, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.minX, y: origin.y))
        path.addLine(to: origin)
        path.close()
        
        return path
    }
    
    fileprivate func applyPath() {
        
        let bounds = makePath(withPercentage: 100).bounds
        let path = makePath(withPercentage: 5)
        
        CATransaction.begin()
        CATransaction.disableActions()
        defer {
            CATransaction.commit()
        }
        
        firstBeam.frame = bounds
        secondBeam.frame = bounds
        thirdBeam.frame = bounds
        
        firstBeam.path = path.cgPath
        secondBeam.path = path.cgPath
        thirdBeam.path = path.cgPath
        
        
        secondBeam.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        thirdBeam.position = CGPoint(x: self.bounds.maxX - self.thirdBeam.bounds.width / 2, y: self.bounds.midY)
    }
    
    
}
