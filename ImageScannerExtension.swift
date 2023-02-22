//
//  ImageScannerExtension.swift
//  TnexScan
//
//  Created by Din Vu Dinh on 22/02/2023.
//

import Foundation

extension ImageScannerController {
    
    public class func cropImage(quad: Quadrilateral, quardSize: CGSize, image: UIImage, padding: CGFloat = 30) -> UIImage? {
        let imageSize = image.size
        let scaleTransform = CGAffineTransform.scaleTransform(forSize: imageSize, aspectFillInSize: quardSize)
        let transforms = [scaleTransform]
        let transformedQuad = quad.applyTransforms(transforms)
        guard let ciImage = CIImage(image: image) else {
            return nil
        }

        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
        let scaledQuad = transformedQuad.scale(quardSize, image.size)

        // Cropped Image
        var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: image.size.height)
        cartesianScaledQuad.reorganize()
        let newPadding: CGFloat = padding * image.size.width / UIScreen.main.bounds.width
        let filteredImage: CIImage
        if ImageScannerController.checkCanMakePadding(padding: padding, quad: quad, imageSize: imageSize) {
            filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
                "inputTopLeft": CIVector(cgPoint: CGPoint(x: cartesianScaledQuad.bottomLeft.x - newPadding, y: cartesianScaledQuad.bottomLeft.y + newPadding)),
                "inputTopRight": CIVector(cgPoint: CGPoint(x: cartesianScaledQuad.bottomRight.x + newPadding, y: cartesianScaledQuad.bottomRight.y + newPadding)),
                "inputBottomLeft": CIVector(cgPoint: CGPoint(x: cartesianScaledQuad.topLeft.x - newPadding, y: cartesianScaledQuad.topLeft.y - newPadding)),
                "inputBottomRight": CIVector(cgPoint: CGPoint(x: cartesianScaledQuad.topRight.x + newPadding, y: cartesianScaledQuad.topRight.y - newPadding))
            ])
        } else {
            filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
                "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
                "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
                "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
                "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
            ])
        }

        let croppedImage = UIImage.from(ciImage: filteredImage)
        return croppedImage
    }
    
    public class func checkCanMakePadding(padding: CGFloat, quad: Quadrilateral, imageSize: CGSize) -> Bool {
        if quad.bottomLeft.x - padding < 0 {
            return false
        }
        if quad.bottomLeft.y + padding < 0 {
            return false
        }
        if quad.bottomRight.x + padding > imageSize.width {
            return false
        }
        if quad.bottomRight.y + padding < 0 {
            return false
        }
        
        if quad.topLeft.x - padding < 0 {
            return false
        }
        if quad.topLeft.y + padding > imageSize.height {
            return false
        }
        if quad.topRight.x + padding > imageSize.width {
            return false
        }
        if quad.topRight.y + padding > imageSize.height {
            return false
        }
        
        return true
    }
}
