//
//  LoginRegister.swift
//  joke
//
//  Created by Mehrshad Jalilmasir on 11/17/16.
//  Copyright © 2016 Mehrshad Jalilmasir. All rights reserved.
//

import UIKit

var currentUser = User()

class LoginRegister: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    @IBOutlet weak var errorDisplay: UILabel!
    
    @IBOutlet weak var _switch: UISegmentedControl!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Email: UITextField!
    
    @IBOutlet weak var tempView: UIView!
    
    var selectedImage = false
    
    @IBOutlet weak var rlButton: UIButton!
    
    let container: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageView.isUserInteractionEnabled = true
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickProfileImage)))
        profileImageView.isHidden = true
        
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
        
        if let _id = defaults.object(forKey: "joke_user_id")
        {
            currentUser._id = _id as AnyObject?
            currentUser.email = defaults.object(forKey: "joke_user_email") as AnyObject?
            currentUser.name = defaults.object(forKey: "joke_user_name") as AnyObject?
            currentUser.image = defaults.object(forKey: "joke_user_image") as AnyObject?
            self.performSegue(withIdentifier: "login", sender: self)
        }
        else
        {
            tempView.isHidden = true
            profileImageView.isHidden = false
        }
    }
    
    func generateBoundaryString() -> String
    {
        return "Boundary-\(UUID().uuidString)"
    }
    
    
    func Login(){
    
        //print("login")
        guard let username = Username.text , let email = Email.text else
        {
            return
        }
        
        if username == "" || NSString(string : username).length > 15 || NSString(string : username).length < 3// || !selectedImage
        {
            self.errorDisplay.text = "حداقل سه کاراکتر!"
            return
        }
        else if !validEmail(email) || email == ""
        {
            self.errorDisplay.text = "فرمت ایمیل صحیح نیست!"
            return
        }
        
        ActivityIndicatory(self.view)
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session : URLSession = URLSession(configuration: configuration)
        
        let address = "http://54.67.65.222:3000/api/v1/user/login/\(email)/\(username)"
        let escapedAddress = address.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let urlpath = NSString(format: escapedAddress! as NSString)
        
        let request = NSMutableURLRequest(url: URL(string: urlpath as String)!)
        
        request.httpMethod = "GET"
        
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
                            
                            if let status = _result["status"] as? Int{
                                
                                if status == 200 || status == 300
                                {
                                    if let user = _result["content"] as? [String : AnyObject]{
                                        
                                        currentUser = User()
                                        if userJokes.count > 0
                                        {
                                            userJokes.removeAll()
                                        }
                                        if userFavoritJokes.count > 0
                                        {
                                            userFavoritJokes.removeAll()
                                        }
                                        if jokes.count > 0
                                        {
                                            jokes.removeAll()
                                        }
                                        
                                        currentUser.setValuesForKeys(user)
                                        defaults.set(currentUser._id, forKey: "joke_user_id")
                                        defaults.set(currentUser.name, forKey: "joke_user_name")
                                        defaults.set(currentUser.email, forKey: "joke_user_email")
                                        defaults.set(currentUser.image, forKey: "joke_user_image")
                                        
                                        DispatchQueue.main.async(execute: {
                                            
                                            //print(currentUser._id)
                                            self.performSegue(withIdentifier: "login", sender: self)
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
    
    @IBAction func register(_ sender: AnyObject) {
        
        if _switch.selectedSegmentIndex == 0
        {
            
        }
        else{
            
            Login()
            return
        }
        
        guard let username = Username.text , let email = Email.text else
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
            
            //imageData = UIImageJPEGRepresentation(profileImage, 0.1)
        }
        
        if username == "" || NSString(string : username).length > 15 || NSString(string : username).length < 3// || !selectedImage
        {
            self.errorDisplay.text = "حداقل سه کاراکتر!"
            return
        }
        else if !validEmail(email) || email == ""
        {
            self.errorDisplay.text = "فرمت ایمیل صحیح نیست!"
            return
        }
        
        ActivityIndicatory(self.view)
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session : URLSession = URLSession(configuration: configuration)
        let request = NSMutableURLRequest(url: URL(string: "http://54.67.65.222:3000/api/v1/user/adduser")!)
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
        body.append("Content-Disposition:form-data; name=\"email\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(email.lowercased())\r\n".data(using: String.Encoding.utf8)!)
        
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
                                
                                if status == 200 || status == 300
                                {
                                    if let user = _result["content"] as? [String : AnyObject]{
                                        
                                        currentUser = User()
                                        if userJokes.count > 0
                                        {
                                            userJokes.removeAll()
                                        }
                                        if userFavoritJokes.count > 0
                                        {
                                            userFavoritJokes.removeAll()
                                        }
                                        if jokes.count > 0
                                        {
                                            jokes.removeAll()
                                        }
                                        
                                        currentUser.setValuesForKeys(user)
                                        defaults.set(currentUser._id, forKey: "joke_user_id")
                                        defaults.set(currentUser.name, forKey: "joke_user_name")
                                        defaults.set(currentUser.email, forKey: "joke_user_email")
                                        defaults.set(currentUser.image, forKey: "joke_user_image")
                                        
                                        DispatchQueue.main.async(execute: {
                                            
                                            //print(currentUser._id)
                                            self.performSegue(withIdentifier: "login", sender: self)
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
    
    @IBAction func switcher(_ sender: AnyObject) {
        
        self.errorDisplay.text = ""
        self.rlButton.setTitle(_switch.titleForSegment(at: _switch.selectedSegmentIndex), for: UIControlState())
        (_switch.selectedSegmentIndex == 0 ? (profileImageView.isHidden = false) : (profileImageView.isHidden = true))
    }
    
    func validEmail(_ string:String)->Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: string)
    }
}
