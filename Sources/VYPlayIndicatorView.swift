//
//  VYPlayIndicatorView.swift
//  VYPlayIndicatorSwift
//

import UIKit


@IBDesignable
public class VYPlayerIndicatorView: UIView {
    
    private lazy var indicator: VYPlayerIndicator = {
        let indicator = VYPlayerIndicator()
        indicator.frame = self.bounds
        self.layer.addSublayer(indicator)
        return indicator
    }()
    
    public var indicatorColor: UIColor {
        set { indicator.color = newValue }
        get { return indicator.color }
    }
    
    public var state: VYPlayerIndicator.State {
        set { indicator.state = newValue }
        get { return indicator.state }
    }
    
    public func animatePlayback() {
        indicator.animatePlayback()
    }
    
    public func stopPlayback() {
        indicator.stopPlayback()
    }
    
    public func pausePlayback() {
        indicator.pausePlayback()
    }
    
    public func reset() {
        indicator.reset()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        indicator.frame = bounds
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        state = .playing
    }
}
