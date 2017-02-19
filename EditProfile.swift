//
//  LoginRegister.swift
//  joke
//
//  Created by Mehrshad Jalilmasir on 11/17/16.
//  Copyright © 2016 Mehrshad Jalilmasir. All rights reserved.
//

import UIKit

class EditProfile: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    @IBOutlet weak var errorDisplay: UILabel!
    
    let container: UIView = UIView()
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var Username: UITextField!
    //@IBOutlet weak var Email: UITextField!
    
    var selectedImage = false
    
    @IBOutlet weak var rlButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.isUserInteractionEnabled = true
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickProfileImage)))
        
        Username.text = currentUser.name as? String
        //Email.text = currentUser.email as? String
        if let image = currentUser.image
        {
            profileImageView.loadImageWithCasheWithUrl(image as! String)
        }
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

    override func viewDidAppear(_ animated: Bool) {
        
        
    }
    
    func generateBoundaryString() -> String
    {
        return "Boundary-\(UUID().uuidString)"
    }
    
    @IBAction func Ok(_ sender: AnyObject) {
        
        guard let username = Username.text else
        {
            return
        }
        var imageData:Data?
        
        if let profileImage = self.profileImageView.image
        {
            if selectedImage
            {
                imageData = UIImageJPEGRepresentation(profileImage, 0.1)
            }else{
                imageData = "".data(using: String.Encoding.utf8)
            }
        }
        
        if username == "" || NSString(string : username).length > 15 || NSString(string : username).length < 3// || !selectedImage
        {
            self.errorDisplay.text = "حداقل سه کاراکتر!"
            return
        }
        else if username.contains(" ")
        {
            self.errorDisplay.text = "کاراکتر فاصله وارد نکنید!"
            return
        }
        
        ActivityIndicatory(self.view)
        
        let _id = currentUser._id as! String
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session : URLSession = URLSession(configuration: configuration)
        let request = NSMutableURLRequest(url: URL(string: "http://54.67.65.222:3001/api/v1/user/edituser")!)
        request.httpMethod = "POST"
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        let fname = "test.jpg"
        let mimetype = "image/jpg"
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"name\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(username)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"imageselection\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(selectedImage)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"_id\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(_id)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"image\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageData!)
        
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        request.httpBody = body as Data
        
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
                                    if let user = _result["content"] as? [String : AnyObject]{
                                        
                                        currentUser = User()
                                        
                                        currentUser.setValuesForKeys(user)
                                        defaults.set(currentUser._id, forKey: "joke_user_id")
                                        defaults.set(currentUser.name, forKey: "joke_user_name")
                                        defaults.set(currentUser.email, forKey: "joke_user_email")
                                        defaults.set(currentUser.image, forKey: "joke_user_image")
                                        
                                        DispatchQueue.main.async(execute: {
                                            
                                            //print(currentUser._id)
                                            self.dismiss(animated: true, completion: { 
                                                
                                            })
                                        })
                                    }
                                }
                                else if(status == 500 || status == 501){
                                    
                                    DispatchQueue.main.async(execute: {
                                        
                                        self.errorDisplay.text = _result["message"] as? String
                                    })
                                }
                            }
                        }
                        
                    default:
                        break
                        //print(httpResponse.statusCode)
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                
                //print(currentUser._id)
                self.container.removeFromSuperview()
            })
        }
        dataTask.resume()
    }
    
    func pickProfileImage(){
        
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
    
    /*func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePost.image = image
        } else{
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
    }*/
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //print(info)
        var image : UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"]  as? UIImage{
            
            image = editedImage
            selectedImage = true
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            
            image = originalImage
            selectedImage = true
        }
        
        if let selectedImage = image{
            
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: AnyObject) {
        
        self.dismiss(animated: true) { 
            
        }
    }
    
    func validEmail(_ string:String)->Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: string)
    }
}

