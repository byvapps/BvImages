//
//  TableViewController.swift
//  BvImages
//
//  Created by Adrian Apodaca on 9/6/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import BvImages

class TableViewController: BvScrollCarouselViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let deadlineTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            super.carousel.setImages(["https://i.redd.it/yogrzpnhzkpy.jpg",
                                      "https://www.w3schools.com/css/trolltunga.jpg",
                                      "https://tse4.mm.bing.net/th?id=ORT.TH_470633631&pid=1.12&eid=G.470633631",
                                      "https://daktakdotme.files.wordpress.com/2014/12/palaair.jpg",
                                      "http://zllox.com/wp-content/uploads/2017/02/Freeride-Snowboard.jpg",
                                      "http://www.byvapps.com/img/projects/carousel/surf/slide3.png"], at: .center)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 115
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
