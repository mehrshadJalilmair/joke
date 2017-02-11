//
//  AddJoke.swift
//  joke
//
//  Created by Mehrshad Jalilmasir on 11/17/16.
//  Copyright © 2016 Mehrshad Jalilmasir. All rights reserved.
//

import UIKit

class AddJoke: UIViewController , UITextViewDelegate{

    let container: UIView = UIView()
    
    @IBOutlet weak var _text: UITextView!
    var textForSending:String?
    
    override func viewDidLoad() {
        
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
            
            ActivityIndicatory(self.view)
            let configuration: URLSessionConfiguration = URLSessionConfiguration.default
            let session : URLSession = URLSession(configuration: configuration)
            let request = NSMutableURLRequest(url: URL(string: "http://54.67.65.222:3000/api/v1/joke/addjoke")!)
            let bodyData = String.localizedStringWithFormat("text=%@&writer=%@", text , currentUser._id as! String) // in request body
            
            //print(bodyData)
            request.httpMethod = "POST"
            request.httpBody = bodyData.data(using: String.Encoding.utf8)
            
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
                                        if let _joke = _result["content"] as? [String : AnyObject]{
                                            
                                            let _Joke = Joke()
                                            _Joke.setValuesForKeys(_joke)
                                            //print(_joke)
                                            jokes.insert(_Joke, at: 0)
                                            DispatchQueue.main.async(execute: {
                                                
                                                self.dismiss(animated: true, completion: { 
                                                    
                                                    SCLAlertView(appearance : appearance).showSuccess("New Joke Added Successfully", subTitle: "" , closeButtonTitle: "بازگشت" , duration: 3 , colorStyle: 0x00EE00 , colorTextButton: 0x000000)
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
                    
                    //print(currentUser._id)
                    self.container.removeFromSuperview()
                })
            }
            dataTask.resume()
        }
    }
}
