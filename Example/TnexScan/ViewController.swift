//
//  ViewController.swift
//  TnexScan
//
//  Created by Din Vu Dinh on 02/21/2023.
//  Copyright (c) 2023 Din Vu Dinh. All rights reserved.
//

import UIKit
import TnexScan
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet private weak var cameraView: UIView!
    var controller: CameraScannerViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        controller = CameraScannerViewController()
        controller.view.frame = cameraView.bounds
        controller.willMove(toParent: self)
        cameraView.addSubview(controller.view)
        self.addChild(controller)
        controller.didMove(toParent: self)
        controller.delegate = self
    }

    @IBAction func flashTapped(_ sender: UIButton) {
        controller.toggleFlash()
    }

    @IBAction func captureTapped(_ sender: UIButton) {
        controller.capture()
    }

}

extension ViewController: CameraScannerViewOutputDelegate {
    func captureImageFailWithError(error: Error) {
        print(error)
    }

    func captureImageSuccess(image: UIImage, withQuad quad: Quadrilateral?) {
        let frame1 = AVMakeRect(aspectRatio: image.size, insideRect: view.bounds)
        guard let image = ImageScannerController.cropImage(quad: quad!, quardSize: frame1.size, image: image) else { return }
        self.cropped(image: image)
    }
}

extension ViewController: EditImageViewDelegate {
    func cropped(image: UIImage) {
        guard let controller = self.storyboard?
            .instantiateViewController(withIdentifier: "ReviewImageView") as? ReviewImageViewController else {
            return
        }
        print("Image!!!!!")
        print(image)
        controller.modalPresentationStyle = .fullScreen
        controller.image = image
        navigationController?.pushViewController(controller, animated: false)
    }
    
    
    
    
}
