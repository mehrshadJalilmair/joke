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
    @IBOutlet weak var _Date: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var jokeImage: UIImageView!
    
    
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
        background.bringSubview(toFront: _Date)
        background.bringSubview(toFront: JokeText)
        //foregroundContainerView.bringSubview(toFront: editBtn)
        //foregroundContainerView.bringSubview(toFront: deleteBtn)
        foregroundContainerView.bringSubview(toFront: JokeText)
        
        jokeOwnerUserName.text! = (joke.writer_name as! String)
        //jokeOwnerImage.image = UIImage(named: "")
        JokeText.text! = (joke.text as! String)
        
        //print(joke.date!)
        /*var date = NSString(string: (joke.date as! String))
        date = date.substring(with: NSRange( location: 0 , length: 24)) as NSString
        //date = "\(date) +0000" as NSString*/
        let now = Date()
        let nowcalendar = Calendar.current
        
        let year = nowcalendar.component(.year, from: now)
        let month = nowcalendar.component(.month, from: now)
        let day = nowcalendar.component(.day, from: now)
        let hour = nowcalendar.component(.hour, from: now)
        let min = nowcalendar.component(.minute, from: now)
        let sec = nowcalendar.component(.second, from: now)
        
        let nowDate = "\(year)-\((month < 10 ? "0\(month)" : "\(month)"))-\((day < 10 ? "0\(day)" : "\(day)")) \((hour < 10 ? "0\(hour)" : "\(hour)")):\((min < 10 ? "0\(min)" : "\(min)")):\((sec < 10 ? "0\(sec)" : "\(sec)"))"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //dateFormatter.locale = Locale.init(identifier: "en_GB")
        let dateObj = dateFormatter.date(from: joke.date!)
        let nowObj = dateFormatter.date(from: nowDate)
        
        let calendar = NSCalendar.current as NSCalendar
        
        //let date2 = calendar.startOfDay(for: nowObj!)
        //let date1 = calendar.startOfDay(for: dateObj!)
        var unitFlags = NSCalendar.Unit.year
        //let yearcomponents = calendar.components(unitFlags, from: date1, to: date2 , options: [])
        
        unitFlags = NSCalendar.Unit.month
        let monthcomponents = calendar.components(unitFlags, from: dateObj!, to: nowObj! , options: [])
        
        unitFlags = NSCalendar.Unit.day
        let daycomponents = calendar.components(unitFlags, from: dateObj!, to: nowObj! , options: [])
        
        unitFlags = NSCalendar.Unit.hour
        let hourcomponents = calendar.components(unitFlags, from: dateObj!, to: nowObj! , options: [])
        
        unitFlags = NSCalendar.Unit.minute
        let minutecomponents = calendar.components(unitFlags, from: dateObj!, to: nowObj! , options: [])
        
        unitFlags = NSCalendar.Unit.second
        let secondcomponents = calendar.components(unitFlags, from: dateObj!, to: nowObj! , options: [])

        
        if monthcomponents.month! >= 1 {
            
            _Date.text! = "\(monthcomponents.month!) ماه پیش"
        }
        else if daycomponents.day! >= 1 {
            
            _Date.text! = "\(daycomponents.day!) روز پیش"
        }
        else if hourcomponents.hour! >= 1 {
            
            _Date.text! = "\(hourcomponents.hour!) ساعت پیش"
        }
        else if minutecomponents.minute! >= 1
        {
            _Date.text! = "\(minutecomponents.minute!) دقیقه پیش"
        }
        else if secondcomponents.second! >= 30
        {
            _Date.text! = "\(secondcomponents.second!) ثانیه پیش"
        }
        else
        {
            _Date.text! = "همین الان"
        }
        //date = date.stringByReplacingOccurrencesOfString("T", withString: "  ")
        
        fullJokeText.text! = (joke.text as! String)
        likeBtn.badgeString = "\(joke.like!)"
        visitedBtn.badgeString = "\(joke.view!)"
        
        if let image = joke.writer_image
        {
            jokeOwnerImage.loadImageWithCasheWithUrl(image as! String)
        }
        
        if let image = joke.imageName
        {
            jokeImage.loadImageWithCasheWithUrl(image as! String)
        }
        
        if contentToDisplay == .favorites
        {
            guard let delBtn = deleteBtn,let edBtn = editBtn else {
                
                return
            }
            delBtn.isHidden = true
            edBtn.isHidden = true
            
        }
        else if contentToDisplay == .myJokes
        {
            guard let delBtn = deleteBtn,let edBtn = editBtn else {
                
                return
            }
            delBtn.isHidden = false
            edBtn.isHidden = false
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        jokeOwnerUserName.layer.cornerRadius = 5
        jokeOwnerUserName.backgroundColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
        jokeOwnerUserName.layer.masksToBounds = true
        jokeOwnerUserName.textColor = UIColor.black
        
        //_Date.layer.cornerRadius = 5
        //_Date.backgroundColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
        //_Date.layer.masksToBounds = true
        _Date.textColor = UIColor.lightGray
        
        
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
        likeBtn.badgeBackgroundColor = UIColor(red: 255/255, green: 51/255, blue: 51/255, alpha: 1)
        visitedBtn.badgeBackgroundColor = UIColor(red: 255/255, green: 51/255, blue: 51/255, alpha: 1)
        
        jokeOwnerImage.isUserInteractionEnabled = true
        
        shareImage.isUserInteractionEnabled = true
        
        jokeOwnerUserName.isUserInteractionEnabled = true
        
        shareImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(share)))
        
        jokeOwnerImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(noOP)))
        btnsBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(noOP)))
        
        JokeText.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        JokeText.textColor = UIColor.white
    
        if contentToDisplay == .favorites
        {
            
        }
        else if contentToDisplay == .myJokes
        {
            
            guard let delBtn = deleteBtn,let edBtn = editBtn else {
                
                return
            }
            delBtn.layer.cornerRadius = 25
            delBtn.layer.masksToBounds = true
            edBtn.layer.cornerRadius = 25
            edBtn.layer.masksToBounds = true
        }
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
