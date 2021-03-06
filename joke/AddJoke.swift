//
//  AddJoke.swift
//  joke
//
//  Created by Mehrshad Jalilmasir on 11/17/16.
//  Copyright © 2016 Mehrshad Jalilmasir. All rights reserved.
//

import UIKit

var jokeAdded = false

class AddJoke: UIViewController , UITextViewDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    @IBOutlet weak var jokeImageView: UIImageView!
    
    @IBOutlet var addImgeLabel: UILabel!
    
    @IBOutlet var unPickBtn: UIButton!
    
    
    var selectedImage = false
    var imageToUpload:UIImage!
    
    var container: UIView!
    
    @IBOutlet weak var _text: UITextView!
    var textForSending:String?
    
    @IBOutlet weak var senBtn: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        
        jokeAdded = false
        _text.layer.cornerRadius = 10.0
        _text.layer.masksToBounds = false
        _text.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        _text.layer.shadowOffset = CGSize(width: 0, height: 0)
        _text.layer.shadowOpacity = 0.8
        //_text.textColor = UIColor.lightGrayColor()
        
        //comment.becomeFirstResponder()
        _text.selectedTextRange = _text.textRange(from: _text.beginningOfDocument, to: _text.beginningOfDocument)
        
        //_text.text = "متن جوک..."
        
        _text.textAlignment = .right
        _text.delegate = self
        
        jokeImageView.isUserInteractionEnabled = false
        jokeImageView.layer.cornerRadius = 5
        jokeImageView.clipsToBounds = true
        //jokeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickImage)))
        
        addImgeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickImage)))
        
        imageToUpload = UIImage(named: "default")
        unPickBtn.layer.cornerRadius = 25
        jokeImageView.clipsToBounds = true
        unPickBtn.isHidden = true
    }
    
    func ActivityIndicatory(_ uiView: UIView) {
        
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColor(red: CGFloat(0xFF)/255, green: CGFloat(0xFF)/255, blue: CGFloat(0xFF)/255, alpha: 0.3)
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor(red: CGFloat(0x44)/255, green: CGFloat(0x44)/255, blue: CGFloat(0x44)/255, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        actInd.center = CGPoint(x: loadingView.frame.size.width / 2,
                                y: loadingView.frame.size.height / 2);
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        actInd.startAnimating()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        
        /*
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:NSString = _text.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            _text.text = "متن جوک..."
            _text.textColor = UIColor.lightGrayColor()
            
            _text.selectedTextRange = _text.textRangeFromPosition(_text.beginningOfDocument, toPosition: _text.beginningOfDocument)
            
            return false
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry
        else if _text.textColor == UIColor.lightGrayColor() && !text.isEmpty {
            _text.text = nil
            _text.textColor = UIColor.blackColor()
        }
        */
        //textForSending = updatedText
        return true
    }
    
    
    @IBAction func sendJoke(_ sender: AnyObject) {
        
        if let text = _text.text
        {
            if NSString(string : text).length < 10
            {
                return
            }
            
            /*if !selectedImage
            {
                return
            }*/
            
            senBtn.isEnabled = false
            var haveimage = "true"
            //ActivityIndicatory(self.view)
            
            var imageData:Data?
            if selectedImage {
                
                imageData = UIImageJPEGRepresentation(imageToUpload, 0.1)
            }
            else
            {
                imageData = UIImageJPEGRepresentation(imageToUpload, 0.001)
                haveimage = "false"
            }

            
            let configuration: URLSessionConfiguration = URLSessionConfiguration.default
            let session : URLSession = URLSession(configuration: configuration)
            let request = NSMutableURLRequest(url: URL(string: "http://54.67.65.222:3001/api/v1/joke/addjoke")!)
            request.httpMethod = "POST"
            let boundary = generateBoundaryString()
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let body = NSMutableData()
            let fname = "joke.jpg"
            let mimetype = "image/jpg"
            
            let date = Date()
            let calendar = Calendar.current
            
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            let hour = calendar.component(.hour, from: date)
            let min = calendar.component(.minute, from: date)
            let sec = calendar.component(.second, from: date)
            
            let finalDate = "\(year)-\((month < 10 ? "0\(month)" : "\(month)"))-\((day < 10 ? "0\(day)" : "\(day)")) \((hour < 10 ? "0\(hour)" : "\(hour)")):\((min < 10 ? "0\(min)" : "\(min)")):\((sec < 10 ? "0\(sec)" : "\(sec)"))"
            
            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition:form-data; name=\"text\"\r\n\r\n".data(using: String.Encoding.utf8)!)
            body.append("\(text)\r\n".data(using: String.Encoding.utf8)!)
            
            
            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition:form-data; name=\"writer\"\r\n\r\n".data(using: String.Encoding.utf8)!)
            body.append("\(currentUser._id!)\r\n".data(using: String.Encoding.utf8)!)
            
            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition:form-data; name=\"date\"\r\n\r\n".data(using: String.Encoding.utf8)!)
            body.append("\(finalDate)\r\n".data(using: String.Encoding.utf8)!)
            
            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition:form-data; name=\"haveimage\"\r\n\r\n".data(using: String.Encoding.utf8)!)
            body.append("\(haveimage)\r\n".data(using: String.Encoding.utf8)!)
            
            
            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition:form-data; name=\"image\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
            body.append(imageData!)
            
            body.append("\r\n".data(using: String.Encoding.utf8)!)
            body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
            
            request.httpBody = body as Data
            
            /*let configuration: URLSessionConfiguration = URLSessionConfiguration.default
            let session : URLSession = URLSession(configuration: configuration)
            let request = NSMutableURLRequest(url: URL(string: "http://54.67.65.222:3001/api/v1/joke/addjoke")!)
            let bodyData = String.localizedStringWithFormat("text=%@&writer=%@", text , currentUser._id as! String) // in request body
            
            //print(bodyData)
            request.httpMethod = "POST"
            request.httpBody = bodyData.data(using: String.Encoding.utf8)*/
            
            let dataTask = session.dataTask(with: request as URLRequest) {data,response,error in
                
                if error == nil
                {
                    if let httpResponse = response as? HTTPURLResponse{
                        
                        switch(httpResponse.statusCode)
                        {
                            
                        case 200,300,304:
                            
                            if let data = data{
                                
                                guard let _result = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String : AnyObject] else{
                                    
                                    return
                                }
                                //print(_result)
                                if let status = _result["status"] as? Int{
                                    
                                    if status == 200
                                    {
                                        if let _ = _result["content"] as? [String : AnyObject]{
                                            
                                            //let _Joke = Joke()
                                            //_Joke.setValuesForKeys(_joke)
                                            //print(_joke)
                                            //jokes.insert(_Joke, at: 0)
                                            jokeAdded = true
                                            
                                            DispatchQueue.main.async(execute: {
                                            
                                                self.dismiss(animated: true, completion: { 
                                                    
                                                    let _ = SCLAlertView(appearance : appearance).showSuccess("جوک اضافه شد!", subTitle: "" , closeButtonTitle: "بازگشت" , duration: 3 , colorStyle: 0x00EE00 , colorTextButton: 0x000000)
                                                })
                                            })
                                        }
                                    }
                                }
                            }
                            
                        default:
                            break
                            //defaults.removeObjectForKey("seen_\(id)")
                        }
                    }
                }
                else{
                    
                    //defaults.removeObjectForKey("seen_\(id)")
                }
                DispatchQueue.main.async(execute: {
                    
                    self.senBtn.isEnabled = true
                    //print(currentUser._id)
                    //self.container.removeFromSuperview()
                })
            }
            dataTask.resume()
        }
    }
    func generateBoundaryString() -> String
    {
        return "Boundary-\(UUID().uuidString)"
    }
    
    
    @IBAction func unPickImage(_ sender: Any) {
        
        unPickBtn.isHidden = true
        selectedImage = false
        imageToUpload = UIImage(named :"default")
        jokeImageView.isHidden = true
    }
    
    
    func pickImage(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        //print("canceled picker")
        selectedImage = false
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //print(info)
        var image : UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"]  as? UIImage{
            
            jokeImageView.isHidden = false
            image = editedImage
            selectedImage = true
            unPickBtn.isHidden = false
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            
            jokeImageView.isHidden = false
            unPickBtn.isHidden = false
            image = originalImage
            selectedImage = true
        }
        
        if selectedImage
        {
            if let selectedImage = image{
                
                imageToUpload = selectedImage
                jokeImageView.image = imageToUpload
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true) { 
            
            
        }
    }
}
