//
//  BvScrollCarouselViewController.swift
//  Pods
//
//  Created by Adrian Apodaca on 2/6/17.
//
//

import UIKit
import ByvUtils

let arrows = ["1": "iVBORw0KGgoAAAANSUhEUgAAAA0AAAAWCAYAAAAb+hYkAAAATUlEQVR4AWMgFvz//98HiKVJ0ZAJxP+A+A4QyxCjIQusAQEKiLMBAWYDMSOlGkY1VMBUEtaA0FSJwxbCsT6YNY5qRGRCwhoR2Z2sggUA/sSuHgLFFEkAAAAASUVORK5CYII=","2": "iVBORw0KGgoAAAANSUhEUgAAABoAAAAsCAYAAAB7aah+AAAAbUlEQVR42u3YsQmAQBBEUSMLsAUtSezC5Eo7bMdKRNbJNjDegYM/8OMHl+1Nwy4idnWrsxI51BO5ZkASq0Vyr1rqkFx3IJeaQUBAQEBGRlb11iEJbcXQ/+nAwMDAwMD8WLeelg6sWc5/14eGfx8H4Lbx8jEALAAAAABJRU5ErkJggg==","3": "iVBORw0KGgoAAAANSUhEUgAAACcAAABCCAYAAADUms/cAAAAn0lEQVR4AWLAAUbB////5YA4HIi5BpvDXID4G6BdOzZBIAiDMFqCkdYl2JVmdmVuDdrCZXsLF064cEzwBv78wbLZN459590aYSOBXbAE9sACeC2Cxd5FsNizFfaZdwEDAwMDOxsGBgYGBgYGBnaft5XAAvcrggXu34x71D5r34cABAQEBAQEBAQEBAQEBHwJENbTjf7oRS6UwIRJ1Ja3A+yrRR50Ey8ZAAAAAElFTkSuQmCC"]

open class BvScrollCarouselViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var carouselContainer: UIView!
    
    open var carousel:BvCarousel = BvCarousel()
    var carouselHeigth:CGFloat = 100.0
    
    var showWhenScrolledAt: CGFloat = 227
    var startWhenScrolledAt: CGFloat = 163
    var maxScroll:CGFloat {
        get {
            return showWhenScrolledAt - startWhenScrolledAt
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        scrollView.delegate = self

        carouselHeigth = self.carouselContainer.height()?.constant ?? self.carouselContainer.bounds.size.height
        carousel.clipsToBounds = true
        carousel.autoresizingMask = .flexibleWidth
        carousel.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: carouselHeigth)
        self.view.addSubview(carousel)
//        carousel.addTo(self.view, position: .top, height: carouselHeigth)
        
        self.navigationController?.updateNavAlpha(0.0)
        
        showWhenScrolledAt = carouselHeigth - 64
        startWhenScrolledAt = showWhenScrolledAt - 64
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        self.navigationItem.leftBarButtonItem?.target = self
        self.navigationItem.leftBarButtonItem?.action = #selector(self.back(sender:))
        self.navigationItem.hidesBackButton = true
        var backButton = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(self.back(sender:)))
        if let base64Str = arrows[String(format: "%.0f", UIScreen.main.scale)],
            let data = Data(base64Encoded: base64Str, options: .ignoreUnknownCharacters),
            let img = UIImage(data: data),
            let cgi = img.cgImage {
            
            let image = UIImage(cgImage: cgi, scale: UIScreen.main.scale, orientation: img.imageOrientation)
            backButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.back(sender:)))
        }
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.resetFromAlphaUpdates()
        let deadlineTime = DispatchTime.now() + .milliseconds(30)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.navigationController?.popViewController(animated: true)
        }
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func rotated() {
        carouselHeigth = self.carouselContainer.height()?.constant ?? self.carouselContainer.bounds.size.height
        
        showWhenScrolledAt = carouselHeigth - 64
        startWhenScrolledAt = showWhenScrolledAt - 64
        self.scrollViewDidScroll(self.scrollView)
    }

}

extension BvScrollCarouselViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y + scrollView.contentInset.top
        let diff = offsetY - startWhenScrolledAt
        if (diff > 0) {
            let alpha:CGFloat = min (1, diff / maxScroll)
            self.navigationController?.updateNavAlpha(alpha)
        } else {
            self.navigationController?.updateNavAlpha(0)
        }
        
        let carouselH = max(self.carouselHeigth - offsetY, 0)
        var frame = carousel.frame
        if self.navigationController?.navigationBar.isTranslucent ?? false {
            frame.origin.y = 0
        } else {
            frame.origin.y = -(self.navigationController?.navigationBar.bounds.size.height ?? 0)
            if !UIApplication.shared.isStatusBarHidden {
                frame.origin.y -= UIApplication.shared.statusBarFrame.height
            }
        }
        self.scrollView.top()?.constant = frame.origin.y
        frame.size.height = carouselH
        self.carousel.frame = frame
        
    }
    
}
