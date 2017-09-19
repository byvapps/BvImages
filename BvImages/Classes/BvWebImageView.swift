//
//  BvImageView.swift
//  Pods
//
//  Created by Adrian Apodaca on 26/5/17.
//
//

import Foundation

import UIKit
import AlamofireImage
import ByvUtils
import UIImageViewAlignedSwift

public class BvWebImageView: UIImageViewAligned {
    
    public var urlStr:String? = nil
    var progressMask:BvProgressMask? = nil
    
    
    static public func from(_ item: Any) -> BvWebImageView? {
        if let url = item as? String {
            return BvWebImageView(urlStr: url)
        } else if let url = item as? URL {
            return BvWebImageView(urlStr: url.absoluteString)
        } else if let img = item as? UIImage {
            let response = BvWebImageView()
            response.image = img
            return response
        } else if let imgView = item as? UIImageView {
            let response = BvWebImageView()
            response.image = imgView.image
            return response
        } else if let imageView = item as? BvWebImageView {
            return imageView
        }
        return nil
    }
    
    public convenience init(urlStr: String, mask:BvProgressMask? = nil, autoLoad:Bool = false) {
        self.init(frame: CGRect.zero)
        self.urlStr = urlStr
        self.progressMask = mask
        if let progressMask = progressMask {
            progressMask.maskView.addTo(self)
            if autoLoad {
                self.loadImage()
            }
        }
    }
    
    public func setProgressMask(_ mask:BvProgressMask) {
        self.progressMask?.maskView.removeFromSuperview()
        self.progressMask = mask
        self.progressMask!.maskView.addTo(self)
    }
    
    public func loadImage() {
        if let urlStr = urlStr, let url = URL(string: urlStr) {
            self.progressMask?.start()
            self.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: { (p) in
                self.progressMask?.setProgress(value: CGFloat(p.completedUnitCount / p.totalUnitCount))
            }, completion: { (response) in
                self.endLoadingImage()
            })
        } else {
            self.endLoadingImage()
        }
    }
    
    func endLoadingImage() {
        self.progressMask?.end(completion: {
            self.progressMask?.maskView.removeFromSuperview()
        })
    }
}
