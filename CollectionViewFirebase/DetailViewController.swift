//
//  DetailViewController.swift
//  CollectionViewFirebase
//
//  Created by mac on 08/04/21.
//

import UIKit

class DetailViewController : UIViewController {
    @IBOutlet weak var detailImage: UIImageView!
    
    var detailName: String?
    
    override func viewDidLoad() {
      super.viewDidLoad()
     
      title = detailName
      detailImage.image = UIImage.init(named: detailName!)
    }
    override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
    }
    
}
