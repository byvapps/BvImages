//
//  ViewController.swift
//  BvImages
//
//  Created by Pataluze on 05/26/2017.
//  Copyright (c) 2017 Pataluze. All rights reserved.
//

import UIKit
import BvImages

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: BvWebImageView!
    @IBOutlet weak var loadBtn: UIButton!
    
    lazy var base64Img:UIImage? = {
        let base64Str = "iVBORw0KGgoAAAANSUhEUgAAABQAAAAKCAYAAAC0VX7mAAAACXBIWXMAAAsSAAALEgHS3X78AAACN0lEQVQokU2STUvrTACFn2QmCZNoG9FAqRYFQRGk7tyJC/EPuPEn+i/c6VqsXcjtFQpW8Qu7KJnJTCfzLuSVe9aHA8/DkX///A3GGD4+Pnh8fOTq6oooilBKYYwhjmO01iyXS7rdLqenp1xeXlIUBUIIQgg452iaBq018u7ujk6nw/f3NwBaa0IIpGmKUgrvPUIIhBDkec7m5iZSSoQQxHFM27ZIKYnjmCiKkIPBgNXVVYqiYH9/nziOubm5YTwe0+/3iaKINE0BSJKELMsACCGQJAkhBLz3tG2LtRaplKKqKtI0Jcsyjo6O0Frz9fVFXddkWYb3njRNSZKEpmkYjUYIIej3+/R6PaSUhBAAiMuyBCDPc/I8Z319na2tLc7OzqjrmiRJfopxTFmWpGnK/f091lq898znc5qmwTmHc464qiqMMTRNg/ce5xy7u7usra1hjKGua+q6xlrL5+cnt7e3jEYjrLW8vLzgnGM+n+O9/3EYQqAsS97f31ksFkwmEyaTCU9PTyilmE6nvzg7OztcXFwwnU7p9XrkeY4QAmstzjmklMjZbIbWGq01s9mM6+trxuMxxhiccywWC6SUpGnK+fk529vb7O3t/V7pf6/L5fJn8OHhgbe3N9q2pSxLjo+PqaqK0WjE6+vrr/DhcMjBwQErKysopVBKobXGGIMQAu89TdMQPz8/0+12OTk54fDwkCRJ2NjYoNPpkOc5g8EAKSXD4ZCiKAghYK2lbVv+jbWWuq75D3gUIrKXAcaqAAAAAElFTkSuQmCC"
        if let data = Data(base64Encoded: base64Str) {
            return UIImage(data: data)
        }
        return nil
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let mask = BarProgressMask(placeholder: base64Img, blur: .dark)
        imageView.backgroundColor = UIColor.lightGray
        imageView.setProgressMask(mask)
        imageView.tintColor = UIColor.gray
        imageView.urlStr = "https://i.redd.it/yogrzpnhzkpy.jpg"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loadImage(_ sender: UIButton) {
        imageView.image = nil
        imageView.loadImage()
    }
    
    @IBAction func showPreview(_ sender: UIButton) {
        
        let imageViews:[Any] = [imageView.image ?? "https://i.redd.it/yogrzpnhzkpy.jpg",
                                   "https://www.w3schools.com/css/trolltunga.jpg",
                                   "https://tse4.mm.bing.net/th?id=ORT.TH_470633631&pid=1.12&eid=G.470633631",
                                   "https://daktakdotme.files.wordpress.com/2014/12/palaair.jpg",
                                   "http://zllox.com/wp-content/uploads/2017/02/Freeride-Snowboard.jpg",
                                   "http://www.byvapps.com/img/projects/carousel/surf/slide3.png"]
        
        BvImageViewer.showImages(imageViews, at: 0, from: sender)
        
    }
}

