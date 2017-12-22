
import UIKit
import CoreML
import Vision
import Social
//import SVProgressHUD

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var photoView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var picType: UIImageView!
    
    //@IBOutlet weak var shareButton: UIButton!
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        cameraButton.isEnabled = false
        
        
        //if let optional bind / downcast from Any to UIImage
        
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
          photoView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage to CIImage")
            }
            
            detect(image: ciimage)
    
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loadind CoreML model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            print(results)
            
            DispatchQueue.main.async {
                self.cameraButton.isEnabled = true
                //SVProgressHUD.dismiss
            }
            
            if let firstResult = results.first {
                
                if firstResult.identifier.contains("hotdog") {
                  self.navigationItem.title = "Hotdog!"
                  self.navigationController?.navigationBar.barTintColor = UIColor.green
                  self.navigationController?.navigationBar.isTranslucent = false
                  self.picType.image = UIImage(named: "hotdog")
                }
                else {
                  self.navigationItem.title = "Not Hotdog!"
                  self.navigationController?.navigationBar.barTintColor = UIColor.red
                  self.navigationController?.navigationBar.isTranslucent = false
                  self.picType.image = UIImage(named: "not-hotdog")
                }
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
          try handler.perform([request])
        }
        catch {
          print(error)
        }
        
    }

    @IBAction func CameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
//    @IBAction func shareTapped(_ sender: Any) {
//
//        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
//            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
//            vc?.setInitialText("My food is \(String(describing: navigationItem.title))")
//            vc?.add(#imageLiteral(resourceName: "hotdogBackground"))
//            present(vc!, animated: true, completion: nil)
//        }
//        else {
//            self.navigationItem.title = "Please log in to Twitter"
//        }
//    }
    
}

