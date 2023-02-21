//
//  ReviewImageViewController.swift
//  TnexScan_Example
//
//  Created by Din Vu Dinh on 21/02/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

final class ReviewImageViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let image else { return }
        imageView.image = image
    }
}
