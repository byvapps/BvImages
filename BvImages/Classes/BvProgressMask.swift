//
//  BvProgressMask.swift
//  Pods
//
//  Created by Adrian Apodaca on 26/5/17.
//
//

import Foundation
import ByvUtils

open class BvProgressMask {
    
    let maskView:UIView = UIView()
    
    open func loadMaskView() {
        
    }
    
    open func start() {
        
    }
    
    open func setProgress(value:CGFloat) {
        
    }
    
    open func end(completion:(() -> ())?) {
        completion?()
    }
}


public enum VPosition {
    case top
    case center
    case bottom
}

public class BarProgressMask: BvProgressMask {
    
    var placeholderImage:UIImage? = nil
    var blurEffect:UIBlurEffectStyle? = nil
    var barPosition:VPosition = .bottom
    
    let progressBar:UIProgressView = UIProgressView()
    
    public convenience init(placeholder:UIImage? = nil, blur:UIBlurEffectStyle? = nil, position:VPosition = .bottom) {
        self.init()
        self.placeholderImage = placeholder
        self.blurEffect = blur
        self.barPosition = position
        self.loadMaskView()
    }
    
    override open func loadMaskView() {
        if let img = placeholderImage {
            let placeHolderImageView = UIImageView()
            placeHolderImageView.contentMode = UIViewContentMode.scaleAspectFit
            placeHolderImageView.tag = 10
            placeHolderImageView.image = img
            placeHolderImageView.addTo(maskView)
        }
        
        if let effect = blurEffect {
            let blurEffect = UIBlurEffect(style: effect)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.addTo(maskView)
        }
        
        maskView.backgroundColor = .clear
        
    }
    
    override open func start() {
        var pos:ByvPosition = .bottom
        if self.barPosition == .top {
            pos = .top
        } else if self.barPosition == .center {
            pos = .all
        }
        progressBar.addTo(maskView, position: pos)
        progressBar.setProgress(0.0, animated: false)
    }
    
    override open func setProgress(value: CGFloat) {
        progressBar.setProgress(Float(value), animated: true)
    }
    
    override open func end(completion:(() -> ())?) {
        progressBar.removeFromSuperview()
        UIView.animate(withDuration: 0.3, animations: {
            self.maskView.alpha = 0.0
        }) { (end) in
            completion?()
        }
        
    }
}

public class BlurMask: BvProgressMask {
    
    var placeholderImage:UIImage? = nil
    var blurEffect:UIBlurEffectStyle? = nil
    
    public convenience init(placeholder:UIImage? = nil, blur:UIBlurEffectStyle? = .light) {
        self.init()
        self.placeholderImage = placeholder
        self.blurEffect = blur
        self.loadMaskView()
    }
    
    override open func loadMaskView() {
        if let img = placeholderImage {
            let placeHolderImageView = UIImageView()
            placeHolderImageView.tag = 10
            placeHolderImageView.image = img
            placeHolderImageView.addTo(maskView)
        }
        
        if let effect = blurEffect {
            let blurEffect = UIBlurEffect(style: effect)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.addTo(maskView)
        }
        
        maskView.backgroundColor = .clear
        
    }
    
    override open func start() {
    }
    
    override open func setProgress(value: CGFloat) {
    }
    
    override open func end(completion:(() -> ())?) {
        UIView.animate(withDuration: 0.3, animations: {
            self.maskView.alpha = 0.0
        }) { (end) in
            completion?()
        }
        
    }
}
