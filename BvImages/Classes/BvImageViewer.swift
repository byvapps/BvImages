//
//  BvImageViewer.swift
//  Pods
//
//  Created by Adrian Apodaca on 26/5/17.
//
//

import Foundation

import UIKit
import AlamofireImage

//MARK: - Marcros -

private let BvImageViewerAnimationDuriation : TimeInterval =  0.3
private let BvImageViewerBackgroundColor =  UIColor.black
private let BvImageViewBarBackgroundColor =  UIColor.black.withAlphaComponent(0.3)
private let BvImageViewBarHeight : CGFloat =  40.0
private let BvImageViewBarButtonWidth : CGFloat =  30.0
private let BvImageViewBarDefaultMargin : CGFloat =  5.0
private let BvImageGridViewImageMargin : CGFloat = 2.0
private let BvImageViewMaximunScale : CGFloat = 3.0
private let KCOLOR_BACKGROUND_WHITE = UIColor(red:241/255.0, green:241/255.0, blue:241/255.0, alpha:1.0)
private var BvImageViewerScreenWidth : CGFloat { return UIScreen.main.bounds.width }
private var BvImageViewerScreenHeight : CGFloat { return UIScreen.main.bounds.height }

protocol BvImageResourceProtocol {
    var image : UIImage? { get }
    var imageURLString : String? { get }
}

public struct BvImageResource : BvImageResourceProtocol {
    var image: UIImage?
    var imageURLString: String?
    
    public init(imageURLString: String?) {
        self.imageURLString = imageURLString
    }
    public init(image: UIImage?) {
        self.image = image
    }
    
    
    static func resources(_ items:[Any]) -> [BvImageResource] {
        var resources : [BvImageResource] = []
        for item in items {
            if let url = item as? String {
                resources.append(BvImageResource(imageURLString: url))
            } else if let img = item as? UIImage {
                resources.append(BvImageResource(image: img))
            } else if let imageView = item as? UIImageView {
                resources.append(BvImageResource(image: imageView.image))
            }
        }
        return resources
    }
}

public enum ImageContentMode {
    case fitTop
    case fitCenter
    case fitBottom
    case fillTop
    case fillCenter
    case fillBottom
    
    public func isFill() -> Bool {
        switch self {
        case .fillTop:
            return true
        case .fillCenter:
            return true
        case .fillBottom:
            return true
        default:
            return false
        }
    }
    
    public func isTop() -> Bool {
        switch self {
        case .fillTop:
            return true
        case .fitTop:
            return true
        default:
            return false
        }
    }
    
    public func isCenter() -> Bool {
        switch self {
        case .fillCenter:
            return true
        case .fitCenter:
            return true
        default:
            return false
        }
    }
    
    public func isBottom() -> Bool {
        switch self {
        case .fillBottom:
            return true
        case .fitBottom:
            return true
        default:
            return false
        }
    }
    
    public func frame(from frame:CGRect, img:UIImage?) -> CGRect {
        if let img = img {
            if self.isFill() {
                var rect = frame
                let imgRatio = img.size.width / img.size.height
                let rectRatio = rect.size.width / rect.size.height
                if imgRatio > rectRatio {
                    let aspectRatio = img.size.width / img.size.height
                    let newWidth = rect.size.height * aspectRatio
                    rect.origin.x -= (newWidth - rect.size.width) / 2.0
                    rect.size.width = newWidth
                } else {
                    let aspectRatio = img.size.height / img.size.width
                    let newHeight = rect.size.width * aspectRatio
                    if self.isCenter() {
                        rect.origin.y -= (newHeight - rect.size.height) / 2.0
                    } else if self.isBottom() {
                        rect.origin.y -= (newHeight - rect.size.height)
                    }
                    rect.size.height = newHeight
                }
                return rect
            } else if !isCenter() {
                var rect = frame
                let imgRatio = img.size.width / img.size.height
                let rectRatio = rect.size.width / rect.size.height
                if imgRatio > rectRatio {
                    let aspectRatio = img.size.height / img.size.width
                    let newHeight = rect.size.width * aspectRatio
                    if self.isTop() {
                        rect.origin.y = 0.0
                    } else if self.isBottom() {
                        rect.origin.y = (rect.size.height - newHeight)
                    }
                    rect.size.height = newHeight
                }
                return rect
            }
        }
        return frame
    }
}

public typealias ImageChanged =  (_ newIndex:NSInteger)->()

extension BvImageViewer {
    //MARK: - showImages with images (supports both images, imageViews and url strings)
    
    public static func showImages(_ images : [Any] , at index : NSInteger , from view: UIView, fromMode: ImageContentMode = .fitCenter, onImageChange: ImageChanged? = nil) {
        var rects:[CGRect] = []
        
        let rect = view.superview!.convert(view.frame, to:UIApplication.shared.keyWindow)
        
        for _ in 0 ... images.count-1 {
            rects.append(rect)
        }
        self.sharedInstance.showImages(BvImageResource.resources(images), at:index, from:rects, fromMode: fromMode)
        self.sharedInstance.imageChanged = onImageChange
    }
    
    public static func showImages(_ images : [Any] , at index : NSInteger , from rect: CGRect, in view:UIView, fromMode: ImageContentMode = .fitCenter, onImageChange: ImageChanged? = nil) {
        var rects:[CGRect] = []
        
        let rect = view.convert(rect, to:UIApplication.shared.keyWindow)
        
        for _ in 0 ... images.count-1 {
            rects.append(rect)
        }
        self.sharedInstance.showImages(BvImageResource.resources(images), at:index, from:rects, fromMode: fromMode)
        self.sharedInstance.imageChanged = onImageChange
    }
    
    public static func showImages(_ images : [Any] , at index : NSInteger , fromViews: [UIView], fromMode: ImageContentMode = .fitCenter, onImageChange: ImageChanged? = nil) {
        var rects:[CGRect] = []
        
        for i in 0 ... fromViews.count-1 {
            let rect : CGRect = fromViews[i].superview!.convert(fromViews[i].frame, to:UIApplication.shared.keyWindow)
            rects.append(rect)
        }
        self.sharedInstance.showImages(BvImageResource.resources(images), at:index, from:rects, fromMode: fromMode)
        self.sharedInstance.imageChanged = onImageChange
    }
    
    public static func showImages(_ images : [Any] , at index : NSInteger , fromRects: [CGRect], fromMode: ImageContentMode = .fitCenter, onImageChange: ImageChanged? = nil) {
        self.sharedInstance.showImages(BvImageResource.resources(images), at:index, from:fromRects, fromMode: fromMode)
        self.sharedInstance.imageChanged = onImageChange
    }
    
    
}

//MARK: - BvImageViewer -

public class BvImageViewer: NSObject, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    private var fromRect: CGRect!
    private var currenIndex: NSInteger = 0
    private var imageUrlArray: [BvImageResource]!
    private var imageViews: [BvImageView]! = []
    private var fromSenderRectArray: [CGRect] = []
    private var isPanRecognize: Bool = false
    
    public var imageChanged: ImageChanged? = nil
    public var fromMode: ImageContentMode = .fitCenter
    
    
    //MARK: - sharedInstance
    
    public class var sharedInstance : BvImageViewer {
        struct Static {
            static let instance : BvImageViewer = BvImageViewer()
        }
        return Static.instance
    }
    
    //MARK: - showImages with images (supports both images and url strings)
    
    public func showImages(_ images : [BvImageResource] , at index : NSInteger , from rectsArray: [CGRect], fromMode: ImageContentMode = .fitCenter) {
        
        fromSenderRectArray = rectsArray
        self.fromMode = fromMode
        
        currenIndex = index
        imageUrlArray = images
        fromRect = fromSenderRectArray[index]
        
        backgroundView.backgroundColor = UIColor.clear
        UIApplication.shared.keyWindow?.addSubview(backgroundView);
        backgroundView.addSubview(scrollView)
        backgroundView.addSubview(tabBar)
        
        beginAnimationView.isHidden = false
        backgroundView.addSubview(beginAnimationView)
        
        if let img : UIImage = (images[index]).image {
            beginAnimationView.image = img
            let rect = fromMode.frame(from: fromRect!, img: self.beginAnimationView.image)
            beginAnimationView.frame = rect
        }else if let imageURL : String = (images[index]).imageURLString, let url = URL(string: imageURL) {
            beginAnimationView.af_setImage(withURL: url)
            beginAnimationView.frame = fromRect
        }
        
        
        UIView.animate(withDuration: BvImageViewerAnimationDuriation,
                       animations: { () -> Void in
                        self.beginAnimationView.layer.frame = UIScreen.main.bounds
                        self.backgroundView.backgroundColor = BvImageViewerBackgroundColor
        }, completion: { (finished) -> Void in
            if (finished == true){
                self.setupView(shouldAnimate: true)
            }
        })
    }
    
    
    fileprivate lazy var backgroundView : UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        return view
    }()
    
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
        sView.alpha = 0.0
        sView.bounces = true
        sView.showsHorizontalScrollIndicator = false
        sView.showsVerticalScrollIndicator = false
        sView.alwaysBounceHorizontal = true
        sView.delegate = self
        return sView
    }()
    
    fileprivate lazy var tabBar : BvImageViewBar = {
        let view = BvImageViewBar(frame: CGRect(x: 0 ,  y: BvImageViewerScreenHeight ,  width: BvImageViewerScreenWidth, height: BvImageViewBarHeight) ,
                                  saveTapBlock: {
                                    self.saveCurrentImage();
        },
                                  closeTapBlock: {
                                    self.animationOut()
        })
        view.alpha = 0
        return view
    }()
    
    //MARK: - setupView
    
    fileprivate func setupView(shouldAnimate: Bool){
        
        backgroundView.frame = UIScreen.main.bounds
        scrollView.frame = UIScreen.main.bounds
        tabBar.frame = CGRect(x: 0 ,  y: BvImageViewerScreenHeight ,  width: BvImageViewerScreenWidth, height: BvImageViewBarHeight)
        
        
        
        for v in scrollView.subviews{
            v.removeFromSuperview()
        }
        for i in 0 ..< imageUrlArray.count {
            let imageView: BvImageView = BvImageView(frame: CGRect(x: BvImageViewerScreenWidth * CGFloat(i), y: 0, width: BvImageViewerScreenWidth, height: BvImageViewerScreenHeight), imageResource: imageUrlArray[i], at: i)
            imageView.BvImageViewHandleTap = {
                self.animationOut()
            }
            imageView.panGesture.delegate = self;
            imageView.panGesture.addTarget(self, action: #selector(self.panGestureRecognized(_:)))
            scrollView.addSubview(imageView)
            imageViews.append(imageView)
            if i == currenIndex {
                imageView.loadImage()
            }
        }
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(imageUrlArray.count), height: UIScreen.main.bounds.height)
        scrollView.scrollRectToVisible(CGRect(x: BvImageViewerScreenWidth*CGFloat(currenIndex), y: 0, width: BvImageViewerScreenWidth, height: BvImageViewerScreenHeight), animated: false)
        tabBar.countLabel.text = "\(currenIndex+1)/\(imageUrlArray.count)"
        
        if shouldAnimate {
            self.show()
        } else {
            self.scrollView.alpha = 1.0
            self.tabBar.alpha = 1
            self.tabBar.frame = CGRect(x: 0, y: BvImageViewerScreenHeight-BvImageViewBarHeight, width: BvImageViewerScreenWidth, height: BvImageViewBarHeight)
            self.tabBar.layoutIfNeeded()
        }
    }
    
    func show() {
        
        self.addOrientationChangeNotification()
        UIView.animate(withDuration: BvImageViewerAnimationDuriation, animations: { () -> Void in
            self.scrollView.alpha = 1.0
            self.tabBar.alpha = 1
            self.tabBar.frame = CGRect(x: 0, y: BvImageViewerScreenHeight-BvImageViewBarHeight, width: BvImageViewerScreenWidth, height: BvImageViewBarHeight)
        }, completion: { (finished: Bool) -> Void in
            self.beginAnimationView.isHidden = true
        })
    }
    
    
    //MARK: - gestureRecognizerShouldBegin
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer.view!.isKind(of: BvImageView.self)){
            let translatedPoint = (gestureRecognizer as! UIPanGestureRecognizer).translation(in: gestureRecognizer.view)
            return fabs(translatedPoint.y) > fabs(translatedPoint.x);
        }
        return true
    }
    
    //MARK: - panGestureRecognized
    
    @objc func panGestureRecognized(_ gesture : UIPanGestureRecognizer){
        let currentItem : UIView = gesture.view!
        let translatedPoint = gesture.translation(in: currentItem)
        let newAlpha = CGFloat(1 - fabsf(Float(translatedPoint.y/BvImageViewerScreenHeight)))
        
        if (gesture.state == UIGestureRecognizerState.began || gesture.state == UIGestureRecognizerState.changed){
            scrollView.isScrollEnabled = false
            currentItem.frame = CGRect(x: currentItem.frame.origin.x, y: translatedPoint.y, width: currentItem.frame.size.width, height: currentItem.frame.size.height)
            self.tabBar.frame = CGRect(x: 0, y: BvImageViewerScreenHeight-BvImageViewBarHeight*newAlpha, width: BvImageViewerScreenWidth, height: BvImageViewBarHeight)
            backgroundView.backgroundColor = BvImageViewerBackgroundColor.withAlphaComponent(newAlpha)
        }else if (gesture.state == UIGestureRecognizerState.ended ){
            
            scrollView.isScrollEnabled = true
            if (fabs(translatedPoint.y) >= BvImageViewerScreenHeight*0.2){
                UIView.animate(withDuration: BvImageViewerAnimationDuriation, animations: { () -> Void in
                    self.backgroundView.backgroundColor = UIColor.clear
                    if (translatedPoint.y > 0){
                        currentItem.frame = CGRect(x: currentItem.frame.origin.x, y: BvImageViewerScreenHeight, width: currentItem.frame.size.width, height: currentItem.frame.size.height)
                    }else{
                        currentItem.frame = CGRect(x: currentItem.frame.origin.x, y: -BvImageViewerScreenHeight, width: currentItem.frame.size.width, height: currentItem.frame.size.height)
                    }
                    
                    self.tabBar.frame = CGRect(x: 0, y: BvImageViewerScreenHeight, width: BvImageViewerScreenWidth, height: BvImageViewBarHeight)
                }, completion: { (finished: Bool) -> Void in
                    if  (finished == true){
                        self.removeOrientationChangeNotification()
                        self.scrollView.removeFromSuperview()
                        self.tabBar.removeFromSuperview()
                        self.backgroundView.removeFromSuperview()
                    }
                })
            }else{
                UIView.animate(withDuration: BvImageViewerAnimationDuriation, animations: { () -> Void in
                    self.backgroundView.backgroundColor = BvImageViewerBackgroundColor
                    currentItem.frame = CGRect(x: currentItem.frame.origin.x, y: 0, width: currentItem.frame.size.width, height: currentItem.frame.size.height)
                    self.tabBar.frame = CGRect(x: 0, y: BvImageViewerScreenHeight-BvImageViewBarHeight, width: BvImageViewerScreenWidth, height: BvImageViewBarHeight)
                }, completion: { (finished: Bool) -> Void in
                    
                })
            }
        }
    }
    
    
    //MARK: - UIScrollViewDelegate
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        currenIndex = NSInteger(scrollView.contentOffset.x / BvImageViewerScreenWidth)
        tabBar.countLabel.text = "\(currenIndex+1)/\(imageUrlArray.count)"
        self.imageViews[currenIndex].loadImage()
        if (imageViews.count > currenIndex + 1) {
            self.imageViews[currenIndex + 1].loadImage()
        }
        self.imageChanged?(currenIndex)
    }
    
    //MARK: - animationOut
    
    fileprivate func animationOut(){
        
        self.removeOrientationChangeNotification()
        
        let page = NSInteger(scrollView.contentOffset.x / BvImageViewerScreenWidth)
        
        for img in scrollView.subviews{
            if (img is BvImageView) && ((img as! BvImageView).tag == page) {
                if ((img as! BvImageView).imageView.image != nil) {
                    self.beginAnimationView.image = (img as! BvImageView).imageView.image
                    break
                }
            }
        }
        self.beginAnimationView.isHidden = false
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        let rect = self.fromMode.frame(from: self.fromSenderRectArray[page], img: self.beginAnimationView.image)
        UIView.animate(withDuration: BvImageViewerAnimationDuriation, animations: { () -> Void in
            self.beginAnimationView.frame = rect
            self.scrollView.alpha = 0
            self.backgroundView.backgroundColor = UIColor.clear
            self.tabBar.frame = CGRect(x: 0, y: BvImageViewerScreenHeight, width: BvImageViewerScreenWidth, height: BvImageViewBarHeight)
            self.beginAnimationView.alpha = 0.8
        }, completion: { (finished: Bool) -> Void in
            if  (finished == true){
                self.beginAnimationView.isHidden = true
                self.scrollView.removeFromSuperview()
                self.tabBar.removeFromSuperview()
                self.backgroundView.removeFromSuperview()
            }
        })
    }
    
    //MARK: - saveCurrentImage
    
    fileprivate func saveCurrentImage(){
        var imageToSave : UIImage? = nil;
        for img in scrollView.subviews{
            if (img is BvImageView) && ((img as! BvImageView).tag == currenIndex) {
                if ((img as! BvImageView).imageView.image != nil) {
                    imageToSave = (img as! BvImageView).imageView.image!
                }
            }
        }
        if imageToSave != nil {
            UIImageWriteToSavedPhotosAlbum(imageToSave!, self, #selector(self.saveImageDone(_:error:context:)), nil)
        }
    }
    
    //MARK: - saveImageDone
    
    @objc func saveImageDone(_ image : UIImage, error: Error, context: UnsafeMutableRawPointer?) {
        self.tabBar.countLabel.text = NSLocalizedString("Save image done.", comment: "Save image done.")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.tabBar.countLabel.text = "\(self.currenIndex+1)/\(self.imageUrlArray.count)"
        })
    }
    
    
}
extension BvImageViewer {
    
    fileprivate func addOrientationChangeNotification() {
        NotificationCenter.default.addObserver(self,selector: #selector(onChangeStatusBarOrientationNotification(notification:)),
                                               name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation,
                                               object: nil)
        
    }
    
    fileprivate func removeOrientationChangeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func onChangeStatusBarOrientationNotification(notification : Notification) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.setupView(shouldAnimate: false)
        })
    }
    
}

//MARK: - BvImageView -

/**
 BvImageView
 */

public class BvImageView: UIScrollView, UIScrollViewDelegate{
    
    var resource: BvImageResource!
    var imageView: UIImageView!
    var activityIndicator: UIActivityIndicatorView?
    var BvImageViewHandleTap: (() -> ())?
    var singleTap : UITapGestureRecognizer!
    var doubleTap : UITapGestureRecognizer!
    var panGesture : UIPanGestureRecognizer!
    
    
    //MARK: - BvImageViewBar
    
    public init(frame : CGRect, imageResource : BvImageResource, at index : NSInteger){
        super.init(frame: frame)
        
        self.resource = imageResource
        
        self.backgroundColor = UIColor.clear
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.minimumZoomScale = 1.0
        self.maximumZoomScale = BvImageViewMaximunScale
        self.delegate = self
        self.tag = index
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        
        if let img : UIImage = imageResource.image {
            imageView.image = img
        } else {
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: (frame.width - BvImageViewBarHeight)/2, y: (frame.height - BvImageViewBarHeight)/2, width: BvImageViewBarHeight, height: BvImageViewBarHeight))
            activityIndicator!.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
            activityIndicator!.hidesWhenStopped = true
            self.addSubview(activityIndicator!)
            
            activityIndicator!.startAnimating()
        }
        
        self.addSubview(imageView)
        
        self.setupGestures()
    }
    
    func loadImage() {
        if let imageURL = self.resource.imageURLString, let url = URL(string: imageURL) {
            self.imageView.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: false, completion:{ (response) -> Void in
                if let aiv = self.activityIndicator {
                    aiv.removeFromSuperview()
                    self.activityIndicator = nil
                }
            })
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupGestures() {
        //gesture
        singleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.delaysTouchesBegan = true
        self.addGestureRecognizer(singleTap)
        
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delaysTouchesBegan = true
        self.addGestureRecognizer(doubleTap)
        
        singleTap.require(toFail: doubleTap)
        
        panGesture = UIPanGestureRecognizer()
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        self.addGestureRecognizer(panGesture)
    }
    
    //MARK: - UIScrollViewDelegate
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView?{
        return imageView
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat){
        let ws = scrollView.frame.size.width - scrollView.contentInset.left - scrollView.contentInset.right
        let hs = scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        let w = imageView.frame.size.width
        let h = imageView.frame.size.height
        var rct = imageView.frame
        rct.origin.x = (ws > w) ? (ws-w)/2 : 0
        rct.origin.y = (hs > h) ? (hs-h)/2 : 0
        imageView.frame = rct;
    }
    
    //MARK: - handleSingleTap
    
    @objc func handleSingleTap(_ sender: UITapGestureRecognizer){
        self.BvImageViewHandleTap?()
    }
    
    //MARK: - handleDoubleTap
    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer){
        let touchPoint = sender.location(in: self)
        if (self.zoomScale == self.maximumZoomScale){
            self.setZoomScale(self.minimumZoomScale, animated: true)
        }else{
            self.zoom(to: CGRect(x: touchPoint.x, y: touchPoint.y, width: 1, height: 1), animated: true)
        }
    }
    
}

//MARK: - BvImageViewBar -

public class BvImageViewBar : UIView {
    
    var saveButtonTapBlock : (() ->())!
    var closeButtonTapBlock : (() ->())!
    
    fileprivate lazy var closeButton : UIButton = {
        let button = UIButton(frame: CGRect(x: BvImageViewBarDefaultMargin, y: (self.frame.height-BvImageViewBarButtonWidth)/2, width: BvImageViewBarButtonWidth, height: BvImageViewBarButtonWidth))
        button.backgroundColor = UIColor.clear
        button.contentMode = UIViewContentMode.scaleAspectFill
        button.addTarget(self, action: #selector(BvImageViewBar.onCloseButtonTapped), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    
    fileprivate lazy var saveButton : UIButton = {
        let button = UIButton(frame: CGRect(x: self.frame.width-BvImageViewBarButtonWidth-BvImageViewBarDefaultMargin, y: (self.frame.height-BvImageViewBarButtonWidth)/2, width: BvImageViewBarButtonWidth, height: BvImageViewBarButtonWidth))
        button.backgroundColor = UIColor.clear
        button.contentMode = UIViewContentMode.scaleAspectFill
        button.addTarget(self, action: #selector(BvImageViewBar.onSaveButtonTapped), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    fileprivate lazy var countLabel : UILabel = {
        let label = UILabel(frame: CGRect(x: BvImageViewBarButtonWidth+BvImageViewBarDefaultMargin*2, y: 0, width: self.frame.width-(BvImageViewBarButtonWidth+BvImageViewBarDefaultMargin*2)*2, height: self.frame.height))
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = NSTextAlignment.center
        label.text = "-/-"
        return label
    }()
    
    //MARK: - convenience init
    
    public convenience init(frame: CGRect , saveTapBlock: @escaping ()->() , closeTapBlock: @escaping ()->()) {
        self.init(frame: frame)
        self.backgroundColor = BvImageViewBarBackgroundColor
        
        saveButtonTapBlock = saveTapBlock
        closeButtonTapBlock = closeTapBlock
        
        var imageBundle : Bundle = Bundle.main
        
        if let bundleURL : String = Bundle(for: BvImageViewer.classForCoder()).path(forResource: "BvResource", ofType: "bundle") {
            if let bundle : Bundle = Bundle(path: bundleURL){
                imageBundle = bundle;
            }
        }
        closeButton.setImage(UIImage(named: "close", in: imageBundle, compatibleWith: nil), for: UIControlState())
        self.addSubview(closeButton)
        
        saveButton.setImage(UIImage(named: "save", in: imageBundle, compatibleWith: nil), for: UIControlState())
        self.addSubview(saveButton)
        
        self.addSubview(countLabel)
    }
    
    public override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        self.closeButton.frame = CGRect(x: BvImageViewBarDefaultMargin, y: (self.frame.height-BvImageViewBarButtonWidth)/2, width: BvImageViewBarButtonWidth, height: BvImageViewBarButtonWidth)
        self.saveButton.frame = CGRect(x: self.frame.width-BvImageViewBarButtonWidth-BvImageViewBarDefaultMargin, y: (self.frame.height-BvImageViewBarButtonWidth)/2, width: BvImageViewBarButtonWidth, height: BvImageViewBarButtonWidth)
        self.countLabel.frame = CGRect(x: BvImageViewBarButtonWidth+BvImageViewBarDefaultMargin*2, y: 0, width: self.frame.width-(BvImageViewBarButtonWidth+BvImageViewBarDefaultMargin*2)*2, height: self.frame.height)
    }
    
    //MARK: - onCloseButtonTapped
    
    @objc func onCloseButtonTapped(){
        self.closeButtonTapBlock();
    }
    
    //MARK: - onSaveButtonTapped
    
    @objc func onSaveButtonTapped(){
        self.saveButtonTapBlock();
    }
}


//MARK: - BvImageGridView -

public class BvImageGridView: UIView {
    
    var BvImageGridViewTapBlock : ((_ buttonArray: [UIButton] , _ buttonIndex : NSInteger) ->())?
    var buttonArray : [UIButton] = []
    
    //MARK: - internal init frame imageArray tapBlock
    
    public convenience init(frame : CGRect, imageArray : [String] , tapBlock : @escaping ((_ buttonsArray: [UIButton] , _ buttonIndex : NSInteger) ->())){
        self.init(frame: frame)
        
        self.showWithImageArray(imageArray, tapBlock: tapBlock)
        
    }
    
    public func showWithImageArray(_ imageArray : [String] , tapBlock : @escaping ((_ buttonsArray: [UIButton] , _ buttonIndex : NSInteger) ->())) {
        
        buttonArray = []
        
        for views in self.subviews {
            if views.isKind(of: UIButton.classForCoder()){
                views.removeFromSuperview();
            }
        }
        
        if imageArray.count > 0 {
            BvImageGridViewTapBlock = tapBlock
            let imgHeight : CGFloat = (frame.size.width - BvImageGridViewImageMargin * 2) / 3
            for i in 0 ... imageArray.count-1 {
                let x = CGFloat(i % 3) * (imgHeight + BvImageGridViewImageMargin)
                let y = CGFloat(i / 3) * (imgHeight + BvImageGridViewImageMargin)
                let imageButton  = UIButton()
                imageButton.frame = CGRect(x: x, y: y, width: imgHeight, height: imgHeight)
                imageButton.backgroundColor = KCOLOR_BACKGROUND_WHITE
                imageButton.imageView?.contentMode = UIViewContentMode.scaleAspectFill
                if let url = URL(string: imageArray[i]) {
                    imageButton.af_setImage(for: .normal, url: url)
                }
                
                imageButton.tag = i
                imageButton.clipsToBounds = true
                imageButton.addTarget(self, action: #selector(BvImageGridView.onClickImage(_:)), for: UIControlEvents.touchUpInside)
                self.addSubview(imageButton)
                
                self.buttonArray.append(imageButton)
            }
        }
        
        
    }
    
    //MARK: - get Height With Width
    
    public class func getHeightWithWidth(_ width: CGFloat, imgCount: Int) -> CGFloat{
        let imgHeight: CGFloat = (width - BvImageGridViewImageMargin * 2) / 3
        let photoAlbumHeight : CGFloat = imgHeight * CGFloat(ceilf(Float(imgCount) / 3)) + BvImageGridViewImageMargin * CGFloat(ceilf(Float(imgCount) / 3)-1)
        return photoAlbumHeight
    }
    
    //MARK: - onClickImage
    
    @objc func onClickImage(_ sender: UIButton){
        BvImageGridViewTapBlock?(self.buttonArray , sender.tag)
    }
    
}
