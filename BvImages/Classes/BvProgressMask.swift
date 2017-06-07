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
    var position:VPosition = .bottom
    
    let progressBar:UIProgressView = UIProgressView()
    
    public convenience init(_placeholderImage:UIImage? = nil, _blurEffect:UIBlurEffectStyle? = nil, _position:VPosition = .bottom) {
        self.init()
        self.placeholderImage = _placeholderImage
        self.blurEffect = _blurEffect
        self.position = _position
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
        if self.position == .top {
            pos = .top
        } else if self.position == .center {
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
    
    public convenience init(_placeholderImage:UIImage? = nil, _blurEffect:UIBlurEffectStyle? = nil, _position:VPosition = .bottom) {
        self.init()
        self.placeholderImage = _placeholderImage
        self.blurEffect = _blurEffect
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
