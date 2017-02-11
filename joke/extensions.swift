//
//  extensions.swift
//  realTimeChat
//
//  Created by Mehrshad Jalilmasir on 11/1/16.
//  Copyright © 2016 Mehrshad Jalilmasir. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView{
    
    func loadImageWithCasheWithUrl(_ url_ : String){
        
        self.image = nil
        
        if let imageCached = imageCache.object(forKey: "\(url_)" as AnyObject) as? UIImage{
            
            self.image = imageCached
            return
        }
        
        let url = URL(string: "http://54.67.65.222:3000/api/v1/user/userimage/\(url_)")
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil{
                
                //print(error)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data : data!){
                    
                    imageCache.setObject(downloadedImage , forKey: url_ as AnyObject)
                    self.image = downloadedImage
                }
                else
                {
                    //print("hereeeeee")
                    self.image = UIImage(named: "default")
                }
            })
        }).resume()
    }
}
