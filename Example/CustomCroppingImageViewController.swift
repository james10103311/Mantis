//
//  CustomCroppingImageViewController.swift
//  MantisExample
//
//  Created by Tèo Lực on 2/12/20.
//  Copyright © 2020 Echo. All rights reserved.
//

import UIKit
import Mantis

class CustomCroppingImageViewController:  UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var introductionTitleLabel: UILabel!

    @IBOutlet weak var maskCroppingImageView: UIImageView!
    private var image: UIImage!
    
    private var cropViewController: CropViewController?
    private func createCropViewController(from image: UIImage) -> CropViewController {
        let config = Mantis.Config()
        let cropViewController = Mantis.cropViewController(image: image, config: config)
        //
        let croppingSize = self.maskCroppingImageView.bounds.size
        cropViewController.config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: Double(croppingSize.width/croppingSize.height))
        //
        cropViewController.delegate = self
        cropViewController.hideCropToolbar(true)
        return cropViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCropingImageAsSubView()
    }
    
    private func addCropingImageAsSubView() {
        let vc = createCropViewController(from: image)
        self.addChild(vc)
        if let subview = vc.view {
            subview.frame = contentView.bounds
            subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.insertSubview(subview, at: 0)
        }
        cropViewController = vc
    }
    
    // MARK: - Action
    @IBAction func backAction() { self.dismiss(animated: true, completion: nil)  }
    @IBAction func doneAction() { backAction();  cropViewController?.handleCrop() }
}

extension CustomCroppingImageViewController {
    static func loadCroppingImage(image: UIImage) -> CustomCroppingImageViewController {
        let vc = UIViewController.load(ofType: CustomCroppingImageViewController.self)
        vc.image = image
        return vc
    }
}


extension CustomCroppingImageViewController: CropViewControllerDelegate {
    func cropViewControllerDidRender(_ cropViewController: CropViewController) {
        UIView.animate(withDuration: 0.25) {
            self.introductionTitleLabel.alpha = 0.0
        }
    }
    
    func cropViewControllerDidEndRender(_ cropViewController: CropViewController) {
        UIView.animate(withDuration: 0.25) {
            self.introductionTitleLabel.alpha = 1.0
        }
    }
    
    func cropViewControllerWillDismiss(_ cropViewController: CropViewController) {
        print("sdasdasdas")
    }
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage) {
        //        croppedImageView.image = cropped
    }
}
