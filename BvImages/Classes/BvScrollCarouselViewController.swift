//
//  BvScrollCarouselViewController.swift
//  Pods
//
//  Created by Adrian Apodaca on 2/6/17.
//
//

import UIKit
import ByvUtils

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
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.resetFromAlphaUpdates()
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
    
    func rotated() {
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
