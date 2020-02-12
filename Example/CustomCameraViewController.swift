//
//  CustomCameraViewController.swift
//  MantisExample
//
//  Created by Tèo Lực on 2/11/20.
//  Copyright © 2020 Echo. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore
import Mantis

// MARK: -

protocol CustomCameraViewControllerDelegate: class {
    func didCapture(_ cameraViewController: CustomCameraViewController, cropped: UIImage?)
}

// MARK: -

class CustomCameraViewController: UIViewController {
    @IBOutlet weak var corner_tr                     : UIImageView!
    @IBOutlet weak var corner_bl                     : UIImageView!
    @IBOutlet weak var corner_br                     : UIImageView!
    @IBOutlet weak var flashBtn                      : UIButton!
    
    @IBOutlet weak var reviewImage                   : UIImageView!
    @IBOutlet weak var blackView                     : UIImageView!
    @IBOutlet weak var maskImageViewHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var maskContentView               : UIView!
    
    weak var delegate: CustomCameraViewControllerDelegate? = nil
    
    private lazy var camera: UIImagePickerController = {
        let imgPicker                   = UIImagePickerController()
        imgPicker.delegate              = self
        imgPicker.sourceType            = .camera
        imgPicker.allowsEditing         = false
        imgPicker.showsCameraControls   = false
        return imgPicker
    }()
    
    private var flashIsOn = false {
        didSet {
            enableFlash(flashIsOn)
            updateFlashState(flashIsOn)
        }
    }
    
    func mask(viewToMask: UIView, maskRect: CGRect, cornerRadius: CGFloat = 0, invert: Bool = false) {
        let maskLayer = CAShapeLayer()
        let path      = CGMutablePath()
        //
        if (invert) { path.addRect(viewToMask.bounds) }
        //
        path.addRoundedRect(in: maskRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
        maskLayer.path = path
        //
        if (invert) { maskLayer.fillRule = CAShapeLayerFillRule.evenOdd }
        //
        viewToMask.layer.mask = maskLayer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCornerImages()
        addCameraAsSubView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            let frm = self.blackView.convert(self.maskContentView.frame, from: self.maskContentView.superview)
            self.mask(viewToMask: self.blackView, maskRect: frm, cornerRadius: 12, invert: true)
        }
    }
    
    private func updateCornerImages() {
        corner_tr.rotate(in: 90)
        corner_bl.rotate(in: -90)
        corner_br.rotate(in: 180)
    }
    private func addCameraAsSubView() {
        let imgPicker        = self.camera
        self.view.insertSubview(imgPicker.view, at: 1)
        imgPicker.view.frame = self.view.bounds
        camera               = imgPicker
        flashIsOn            = false
    }
    private func enableFlash(_ isEnable: Bool) {
        camera.cameraFlashMode = isEnable ? .on : .off
    }
    private func updateFlashState(_ isEnable: Bool) {
        flashBtn.isSelected = isEnable
    }
    // MARK: - Action
    @IBAction func flashAction() {  flashIsOn = !flashIsOn }
    @IBAction func captureAction() {  camera.takePicture() }
    @IBAction func backAction() { self.dismiss(animated: true, completion: nil)  }
}

extension CustomCameraViewController {
    private
    static func loadVCFromNIb() -> CustomCameraViewController {
        return UIViewController.load(ofType: CustomCameraViewController.self)
    }
    static func loadCamera() -> CustomCameraViewController {
        //
//        UIImagePickerController.isCameraDeviceAvailable( UIImagePickerController.CameraDevice.rear)
        //
//        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
//            return CustomCameraViewController.loadVCFromNIb()
//        } else {
//            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
//               if granted == true {
//                return CustomCameraViewController.loadVCFromNIb()
//               }
//           })
//        }
        return CustomCameraViewController.loadVCFromNIb()
    }
}

extension CustomCameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard var myImage = info[.originalImage] as? UIImage else {
            // Call delegate
            delegate?.didCapture(self, cropped: nil)
            return
        }
        //
        myImage                                = myImage.rotateImage(image: myImage)
        let originSize                         = myImage.size
        var viewSize                           = reviewImage.bounds.size
        viewSize.height                        = originSize.height * (viewSize.width/originSize.width)
        maskImageViewHeightConstraint.constant = viewSize.height
        self.reviewImage.image                 = myImage
        //
        guard let image = self.reviewImage.toImage() else { return }
        let cropImage   = image.crop(rect: maskContentView.frame)
        // Call delegate
        delegate?.didCapture(self, cropped: cropImage)
    }
}

// MARK: - UIView

fileprivate
extension UIView {
    func toImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
}

// MARK: - UIImage

fileprivate
extension UIImage {
    func crop( rect: CGRect) -> UIImage? {
        return self.crop(rect: rect, scale: self.scale)
    }
    
    func crop( rect: CGRect, scale: CGFloat) -> UIImage? {
        var rect = rect
        rect.origin.x*=scale
        rect.origin.y*=scale
        rect.size.width*=scale
        rect.size.height*=scale
        if let imageRef = self.cgImage?.cropping(to: rect) {
            return UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        }
        return nil
    }
    
    func rotateImage(image:UIImage)->UIImage
    {
        var rotatedImage = UIImage();
        switch image.imageOrientation
        {
        case UIImageOrientation.right:
            rotatedImage = image;
        default:
            rotatedImage = UIImage(cgImage:image.cgImage!, scale: self.scale, orientation:UIImage.Orientation.right);
        }
        return rotatedImage;
    }
}
