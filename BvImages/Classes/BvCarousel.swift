//
//  BvCarousel.swift
//  Pods
//
//  Created by Adrian Apodaca on 2/6/17.
//
//

import UIKit
import ByvUtils

private var BvImageViewerScreenWidth : CGFloat { return UIScreen.main.bounds.width }
private var BvImageViewerScreenHeight : CGFloat { return UIScreen.main.bounds.height }

class PaddingLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 4.0
    @IBInspectable var bottomInset: CGFloat = 4.0
    @IBInspectable var leftInset: CGFloat = 8.0
    @IBInspectable var rightInset: CGFloat = 8.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
}

public class BvCarousel: UIView {
    
    fileprivate lazy var beginAnimationView : UIImageView = {
        let imageView = UIImageView(frame : CGRect.zero)
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.backgroundColor = UIColor.clear;
        return imageView
    }()
    
    fileprivate lazy var scrollView : UIScrollView = {
        let sView = UIScrollView(frame: UIScreen.main.bounds)
        sView.backgroundColor = UIColor.clear
        sView.isPagingEnabled = true
        sView.bounces = true
        sView.showsHorizontalScrollIndicator = false
        sView.showsVerticalScrollIndicator = false
        sView.alwaysBounceHorizontal = true
        sView.delegate = self
        sView.addTo(self)
        return sView
    }()
    
    var imageViews:[BvWebImageView] = []
    lazy var countLbl:PaddingLabel = {
        let response = PaddingLabel()
        response.backgroundColor = UIColor(white: 0.0, alpha: 0.52)
        response.textColor = .white
        response.font = UIFont.systemFont(ofSize: 17.0)
        response.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(response)
        let views = ["label": response]
        var visualStr = "V:[label]-(16.0)-|"
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: visualStr,
                                                           options: NSLayoutFormatOptions(rawValue: 0),
                                                           metrics: nil,
                                                           views: views))
        visualStr = "H:|-(16.0)-[label]"
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: visualStr,
                                                           options: NSLayoutFormatOptions(rawValue: 0),
                                                           metrics: nil,
                                                           views: views))
        return response
    }()
    var currentIndex:Int = 0
    var singleTap = UITapGestureRecognizer(target: self, action: #selector(showImage(_:)))
    
    var items:[Any] = []
    var position:VPosition = .center
    
    public func setImage(_ item:Any, at position:VPosition = .center) {
        self.setImages([item], at: position, singleImageMode: true)
    }
    
    public func setImages(_ items:[Any], at position:VPosition = .center, singleImageMode:Bool = false) {
        NotificationCenter.default.addObserver(self,selector: #selector(onChangeStatusBarOrientationNotification(notification:)),
                                               name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation,
                                               object: nil)
        self.items = items
        self.position = position
        for v in scrollView.subviews {
            v.removeFromSuperview()
        }
        
        imageViews = []
        
        for i in 0...items.count - 1 {
            let item = items[i]
            if let imageView = BvWebImageView.from(item) {
                switch position {
                case .top:
                    imageView.alignment = .top
                case .bottom:
                    imageView.alignment = .bottom
                default:
                    imageView.alignment = .center
                }
                imageView.clipsToBounds = true
                imageView.isUserInteractionEnabled = true
                imageView.contentMode = .scaleAspectFill
                imageView.backgroundColor = UIColor.clear
                imageViews.append(imageView)
            }
        }
        
        scrollView.add(subViews: imageViews, direction: .horizontal)
        
        
        for imageView in imageViews {
            
            let views = ["image": imageView, "self": self]
            var visualStr = "V:[image(==self)]"
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: visualStr,
                                                                    options: NSLayoutFormatOptions(rawValue: 0),
                                                                    metrics: nil,
                                                                    views: views))
            visualStr = "H:[image(==self)]"
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: visualStr,
                                                               options: NSLayoutFormatOptions(rawValue: 0),
                                                               metrics: nil,
                                                               views: views))
        }
        
        if singleImageMode {
            countLbl.isHidden = true
            scrollView.alwaysBounceHorizontal = false
        } else {
            countLbl.isHidden = false
            scrollView.alwaysBounceHorizontal = true
        }
        
        setPage(0)
        
        self.singleTap = UITapGestureRecognizer(target: self, action: #selector(showImage(_:)))
        scrollView.addGestureRecognizer(self.singleTap)
        
    }
    
    func showImage(_ sender: UITapGestureRecognizer) {
        var items:[Any] = []
        for imageView in imageViews {
            if let image = imageView.image {
                items.append(image)
            } else if let urlStr = imageView.urlStr {
                items.append(urlStr)
            }
        }
        var mode:ImageContentMode = .fillCenter
        if position == .top {
            mode = .fillTop
        } else if position == .bottom {
            mode = .fillBottom
        }
        BvImageViewer.showImages(items, at: currentIndex, from: self, fromMode: mode) { (newIndex) in
            self.setPage(newIndex)
        }
    }
    
    public func setPage(_ page:Int, animated:Bool = false) {
        currentIndex = page
        countLbl.text = "\(currentIndex+1)/\(imageViews.count)"
        imageViews[currentIndex].loadImage()
        if (imageViews.count > currentIndex + 1) {
            imageViews[currentIndex + 1].loadImage()
        }
        let rect = CGRect(x: BvImageViewerScreenWidth*CGFloat(currentIndex), y: 0.0, width: BvImageViewerScreenWidth, height: 1.0)
        scrollView.scrollRectToVisible(rect, animated: animated)
    }
    
    
    @objc fileprivate func onChangeStatusBarOrientationNotification(notification : Notification) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.setPage(self.currentIndex)
        })
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension BvCarousel:UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        self.setPage(NSInteger(scrollView.contentOffset.x / BvImageViewerScreenWidth))
    }
}
