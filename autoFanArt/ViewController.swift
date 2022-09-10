//
//  ViewController.swift
//  autoFanArt
//
//  Created by Yosep on 2022/08/30.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: - IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK: - Properties
    var style:Int?
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchToPickPhoto(_:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.contentMode = .scaleAspectFill
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2941176471, green: 0.3960784314, blue: 0.5176470588, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(cgColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))]
        
        view.backgroundColor = #colorLiteral(red: 0.915378511, green: 0.931581676, blue: 0.9433452487, alpha: 1)
        

    }
    
    @objc func touchToPickPhoto(_ gesture: UITapGestureRecognizer) {
         print("dd")
         let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
         
         //Defining Camera Action
         let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
             DispatchQueue.main.async {
                 self.presentImagePicker(withType: .camera)
             }
         }
         
         //Defining Gallery Action
         let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
             DispatchQueue.main.async {
                 self.presentImagePicker(withType: .photoLibrary)
             }
         }
         
         //Defining Cancel Action
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
         
         //Add Action to the Controller
         actionSheet.addAction(cameraAction)
         actionSheet.addAction(libraryAction)
         actionSheet.addAction(cancelAction)
         
         present(actionSheet, animated: true, completion: nil)
     }
    
    @IBAction func pickImageButtonPressed(_ sender: Any) {
 
    }
    
    // MARK: Private Methods
    private func presentImagePicker(withType type: UIImagePickerController.SourceType) {
        //Definiton of imagePickerController with Delegate, sourceType and Present
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = type
        present(pickerController, animated: true)
    }
    
    //MARK: - @objc Function
    //Alert displayed when you have applied the effect
    @objc func imageSave(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            
        } else {
            
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            
        }
    }

    //the delegate take the media that you have choose in the picker and pass it to the variable
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    //Helper Function: we have to convert an image which the user chooses into some readable data
    //(takes an image and extracts its data by turning it into a pixel buffer which can be read easily by Core ML)
    func pixelBuffer(from image: UIImage) -> CVPixelBuffer? {
        
        // 1. we convert the image into a square 512x512.
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 512, height: 512), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: 512, height: 512))
        _ = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
     
        // 2. from newImage into a CVPixelBuffer that is an image buffer which holds the pixels in the main memory
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, 512, 512, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
           
        // 3. We then take all the pixels present in the image and convert them into a device-dependent RGB color space.
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
           
        // 4. create device space color RGB
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        // 5. Create the context where render the image
        let context = CGContext(data: pixelData, width: 512, height: 512, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
           
        // 6. render image
        context?.translateBy(x: 0, y: 512)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        // 7. Push, modify and pop the context
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: 512, height: 512))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            
        // 8. we return our pixel buffer
        return pixelBuffer
    }
    
    @IBOutlet weak var verticalScrollPage: UIScrollView!
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
        
        let xUnit = verticalScrollPage.bounds.width
            verticalScrollPage.contentSize.width = xUnit * 4
     
        let newButton00 = UIButton()
        newButton00.contentMode = .scaleAspectFit
        newButton00.setImage(UIImage(named: "filterImage_00"), for: .normal)
       // newButton00.imageEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
        newButton00.addTarget(self, action: #selector(buttonClicked00), for: .touchUpInside)
        newButton00.frame = CGRect(x: CGFloat(0) * xUnit,
                                            y: 0,
                                            width: xUnit,
                                            height: xUnit)
            
                verticalScrollPage.addSubview(newButton00)
        
        
      
        let newButton01 = UIButton()
        newButton01.contentMode = .scaleAspectFit
        newButton01.setImage(UIImage(named: "JohnLennonImage"), for: .normal)
       // newButton01.imageEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
        newButton01.addTarget(self, action: #selector(buttonClicked01), for: .touchUpInside)
        newButton01.frame = CGRect(x: CGFloat(1) * xUnit,
                                        y: 0,
                                        width: xUnit,
                                        height: xUnit)
        
            verticalScrollPage.addSubview(newButton01)
        
    
        let newButton02 = UIButton()
        newButton02.contentMode = .scaleAspectFit
        newButton02.setImage(UIImage(named: "PerpleFlower"), for: .normal)
       // newButton02.imageEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
        newButton02.addTarget(self, action: #selector(buttonClicked02), for: .touchUpInside)
        newButton02.frame = CGRect(x: CGFloat(2) * xUnit,
                                        y: 0,
                                        width: xUnit,
                                        height: xUnit)
        
            verticalScrollPage.addSubview(newButton02)
        
        
        let newButton03 = UIButton()
        newButton03.contentMode = .scaleAspectFit
        newButton03.setImage(UIImage(named: "YellowFlower"), for: .normal)
       // newButton03.imageEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
        newButton03.addTarget(self, action: #selector(buttonClicked03), for: .touchUpInside)
        newButton03.frame = CGRect(x: CGFloat(3) * xUnit,
                                        y: 0,
                                        width: xUnit,
                                        height: xUnit)
        
            verticalScrollPage.addSubview(newButton03)
    }
    
    @objc func buttonClicked00() {
        print("button00 Clicked")
        let model = JohnLennonFilter()
        
        if let image = pixelBuffer(from: imageView.image!) {
            do {
                let predictionOutput = try model.prediction(image: image)
                
                let ciImage = CIImage(cvPixelBuffer: predictionOutput.stylizedImage)
                let tempContext = CIContext(options: nil)
                let tempImage = tempContext.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(predictionOutput.stylizedImage), height: CVPixelBufferGetHeight(predictionOutput.stylizedImage)))
                imageView.image = UIImage(cgImage: tempImage!)
            } catch let error as NSError {
                print("CoreML Model Error: \(error)")
            }
        }
    }
    
    @objc func buttonClicked01() {
        print("button01 Clicked")
    }
    
    @objc func buttonClicked02() {
        print("button02 Clicked")
    }
    
    @objc func buttonClicked03() {
        print("button03 Clicked")
    }
}
