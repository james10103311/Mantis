//
//  ViewController.swift
//  Mantis
//
//  Created by Echo on 10/19/18.
//  Copyright © 2018 Echo. All rights reserved.
//

import UIKit
import Mantis

class ViewController: UIViewController {
    func cropViewControllerDidRender(_ cropViewController: CropViewController) {
        print("cropViewControllerDidRender(_ cropViewController: CropViewController)")
    }
    func cropViewControllerDidEndRender(_ cropViewController: CropViewController) {
        print("cropViewControllerDidEndRender(_ cropViewController: CropViewController) ")
    }
    
    
    var image = UIImage(named: "sunflower.jpg")
    
    @IBOutlet weak var croppedImageView: UIImageView!
    var imagePicker: ImagePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
        
    @IBAction func getImageFromAlbum(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func normalPresent(_ sender: Any) {
        let vc = CustomCameraViewController.loadCamera()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        vc.delegate = self
    }
    
    @IBAction func hideRotationDialPresent(_ sender: Any) {
        guard let image = image else {
            return
        }
        
        var config = Mantis.Config()
        config.showRotationDial = false
        
        let cropViewController = Mantis.cropViewController(image: image, config: config)
        cropViewController.modalPresentationStyle = .fullScreen
        cropViewController.delegate = self
        present(cropViewController, animated: true)
    }

    
    @IBAction func alwayUserOnPresetRatioPresent(_ sender: Any) {
            guard let image = image else {
                return
            }
            
        let vc = CustomCroppingImageViewController.loadCroppingImage(image: image)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        }
    
    @IBAction func cropEllips(_ sender: Any) {
        guard let image = image else {
            return
        }
        
        var config = Mantis.Config()
        config.cropShapeType = .ellipse
        
        let cropViewController = Mantis.cropViewController(image: image, config: config)
        cropViewController.modalPresentationStyle = .fullScreen
        cropViewController.delegate = self
        present(cropViewController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nc = segue.destination as? UINavigationController,
            let vc = nc.viewControllers.first as? EmbeddedCropViewController {
            vc.image = image
            vc.didGetCroppedImage = {[weak self] image in
                self?.croppedImageView.image = image
                self?.dismiss(animated: true)
            }
        }
    }
}

extension ViewController: CustomCameraViewControllerDelegate {
    func didCapture(_ cameraViewController: CustomCameraViewController, cropped: UIImage?) {
        croppedImageView.image = cropped
        cameraViewController.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: CropViewControllerDelegate {
    func cropViewControllerWillDismiss(_ cropViewController: CropViewController) {
        print("sdasdasdas")
    }
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage) {
        croppedImageView.image = cropped
    }
}

extension ViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        guard let image = image else {
            return
        }
        
        self.image = image
        self.croppedImageView.image = image
    }
}
