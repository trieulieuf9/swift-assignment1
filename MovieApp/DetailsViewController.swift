//
//  DetailsViewController.swift
//  MovieApp
//
//  Created by trieulieuf9 on 7/6/16.
//  Copyright © 2016 trieulieuf9. All rights reserved.
//

import UIKit
import AFNetworking

class DetailsViewController: UIViewController {

    @IBOutlet weak var posterImage: UIImageView!
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    var overview = ""
    var lowResPosterUrl = ""
    var highResPosterUrl = ""
    var movieTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load low res poster first, then high later
        posterImage.setImageWithURL(NSURL(string: lowResPosterUrl)!)
        posterImage.setImageWithURL(NSURL(string: highResPosterUrl)!)
        overviewLabel.text = overview
        self.navigationItem.title = movieTitle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
