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
        self.cropImage(quad: quad!, quardSize: frame1.size, image: image)
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
    
    
    public func cropImage(quad: Quadrilateral, quardSize: CGSize, image: UIImage) {
        let imageSize = image.size
        let scaleTransform = CGAffineTransform.scaleTransform(forSize: imageSize, aspectFillInSize: quardSize)
        let transforms = [scaleTransform]
        let transformedQuad = quad.applyTransforms(transforms)
        guard let ciImage = CIImage(image: image) else {
            return
        }

        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
        let scaledQuad = transformedQuad.scale(quardSize, image.size)

        // Cropped Image
        var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: image.size.height)
        cartesianScaledQuad.reorganize()

        let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
        ])

        let croppedImage = UIImage.from(ciImage: filteredImage)
        self.cropped(image: croppedImage)
    }
    
}
