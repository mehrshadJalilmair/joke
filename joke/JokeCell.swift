//
//  RewardCell.swift
//  Choone
//
//  Created by Mehrshad Jalilmasir on 9/26/16.
//  Copyright © 2016 Mehrshad Jalilmasir. All rights reserved.
//

import UIKit
import FoldingCell
import MIBadgeButton_Swift

protocol FoldingCellDelegate{
    
    func like(_ cell : FoldingCell)
    func share(_ cell : FoldingCell)
    func favorite(_ cell : FoldingCell)
    func edit(_ cell : FoldingCell)
    func delete_(_ cell : FoldingCell)
}

class JokeCell: FoldingCell {
    
    var delegate:FoldingCellDelegate?
    
    var joke:Joke!{
        
        didSet{
            
            updateUI()
        }
    }
    
    @IBOutlet weak var btnsBackground: UIView!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var backgroundContainerView: UIView!
    @IBOutlet weak var foregroundContainerView: UIView!
    @IBOutlet weak var jokeOwnerUserName: UILabel!
    @IBOutlet weak var shareImage: UIImageView!
    @IBOutlet weak var jokeOwnerImage: UIImageView!
    @IBOutlet weak var likeBtn: MIBadgeButton!
    @IBOutlet weak var visitedBtn: MIBadgeButton!
    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var fullJokeText: UITextView!
    @IBOutlet weak var JokeText: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    let defaults = UserDefaults.standard
    
    func updateUI()
    {
        if joke.like_or_not == 1 {
            
            self.likeBtn.setImage(UIImage(named: "ic_favorite_white"), for: UIControlState())
        }else{
            
            likeBtn.setImage(UIImage(named: "ic_favorite_border_white"), for: UIControlState())
        }
        
        if let _ = defaults.object(forKey: "favorite_\(joke._id!)_\(currentUser._id!)"){
            
            //print(favorite)
            favoriteBtn.setImage(UIImage(named: "ic_turned_in_white"), for: UIControlState())
        }else{
            
            favoriteBtn.setImage(UIImage(named: "ic_turned_in_not_white"), for: UIControlState())
        }
        
        background.bringSubview(toFront: jokeOwnerImage)
        background.bringSubview(toFront: shareImage)
        background.bringSubview(toFront: jokeOwnerUserName)
        background.bringSubview(toFront: Date)
        
        jokeOwnerUserName.text! = (joke.writer_name as! String)
        //jokeOwnerImage.image = UIImage(named: "")
        JokeText.text! = (joke.text as! String)
        
        var date = NSString(string: (joke.date as! String))
        date = date.substring(with: NSRange( location: 0 , length: 24)) as NSString
        //date = date.stringByReplacingOccurrencesOfString("T", withString: "  ")
        Date.text! = date as String
        fullJokeText.text! = (joke.text as! String)
        likeBtn.badgeString = "\(joke.like!)"
        visitedBtn.badgeString = "\(joke.view!)"
        
        if let image = joke.writer_image
        {
            jokeOwnerImage.loadImageWithCasheWithUrl(image as! String)
        }
        
        if contentToDisplay == .favorites
        {
            deleteBtn.isHidden = true
            editBtn.isHidden = true
            
        }
        else if contentToDisplay == .myJokes
        {
            deleteBtn.isHidden = false
            editBtn.isHidden = false
        }
    }
    
    override func awakeFromNib() {
        
        jokeOwnerUserName.layer.cornerRadius = 5
        jokeOwnerUserName.backgroundColor = UIColor.red
        jokeOwnerUserName.layer.masksToBounds = true
        
        Date.layer.cornerRadius = 5
        Date.backgroundColor = UIColor.orange
        Date.layer.masksToBounds = true
        
        
        background.backgroundColor = UIColor.white
        foregroundContainerView.backgroundColor = UIColor.white
        backgroundContainerView.backgroundColor = UIColor.white

        btnsBackground.layer.cornerRadius = 8
        btnsBackground.layer.masksToBounds = false
        btnsBackground.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        btnsBackground.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnsBackground.layer.shadowOpacity = 0.8
        
        foregroundContainerView.layer.cornerRadius = 8
        foregroundContainerView.layer.masksToBounds = false
        foregroundContainerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        foregroundContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        foregroundContainerView.layer.shadowOpacity = 0.8
        
        backgroundContainerView.layer.cornerRadius = 8
        backgroundContainerView.layer.masksToBounds = false
        backgroundContainerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        backgroundContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backgroundContainerView.layer.shadowOpacity = 0.8
        
        shareImage.layer.cornerRadius = 25
        shareImage.layer.masksToBounds = true
        
        jokeOwnerImage.layer.cornerRadius = 30
        jokeOwnerImage.layer.masksToBounds = true
        
        likeBtn.badgeString = "100"
        visitedBtn.badgeString = "50000"
        
        jokeOwnerImage.isUserInteractionEnabled = true
        
        shareImage.isUserInteractionEnabled = true
        
        jokeOwnerUserName.isUserInteractionEnabled = true
        
        shareImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(share)))
        jokeOwnerImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(noOP)))
    
        super.awakeFromNib()
    }
    
    func share(){
        
        delegate?.share(self)
    }
    
    func noOP(){
        
        //NOP
    }
    
    @IBAction func like(_ sender: AnyObject) {
        
        delegate?.like(self)
    }
    
    @IBAction func favorite(_ sender: AnyObject) {
        
        delegate?.favorite(self)
    }
    @IBAction func edit(_ sender: AnyObject) {
        
        delegate?.edit(self)
    }
    
    @IBAction func delete_(_ sender: AnyObject) {
        
        delegate?.delete_(self)
    }
    
    override func animationDuration(_ itemIndex: NSInteger, type: FoldingCell.AnimationType) -> TimeInterval {
        
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
}
