//
//  UserProfile.swift
//  joke
//
//  Created by Mehrshad Jalilmasir on 11/17/16.
//  Copyright © 2016 Mehrshad Jalilmasir. All rights reserved.
//

import UIKit
import FoldingCell

enum contentTypes {
    case myJokes, favorites , none
}
var contentToDisplay : contentTypes = .myJokes
var userJokes:[Joke] = [Joke]()
var userFavoritJokes:[Joke] = [Joke]()
var userJokesLoadAgain = 1
var userFavoriteJokesLoadAgain = 1

class UserProfile: UIViewController ,UIScrollViewDelegate , FoldingCellDelegate{

    let container: UIView = UIView()
    
    let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
    let distance_W_LabelHeader:CGFloat = 30.0 // The distance between the top of the screen and the top of the White Label
    
    let kCloseCellHeight: CGFloat = 315
    let kOpenCellHeight: CGFloat = 320
    var cellHeights = [CGFloat]()
    
    // MARK: Outlet properties
    @IBOutlet var tableView : UITableView!
    @IBOutlet var headerView : UIView!
    @IBOutlet var profileView : UIView!
    @IBOutlet var segmentedView : UIView!
    @IBOutlet var avatarImage:UIImageView!
    @IBOutlet var handleLabel : UILabel!
    @IBOutlet var headerLabel : UILabel!
    @IBOutlet var userName : UILabel!
    
    // MARK: class properties
    var headerBlurImageView:UIImageView!
    var headerImageView:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentToDisplay = .myJokes
        
        tableView.contentInset = UIEdgeInsetsMake(headerView.frame.height, 0, 0, 0)
        
        settingPullRefresh()
        createCellHeightsArray()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
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

    
    //Mark : Just Vars
    var refreshControl: UIRefreshControl!
    func settingPullRefresh()
    {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(PullToRefresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        //loadCustomRefreshContents()
    }
    func PullToRefresh() {
        
        if refreshControl.isRefreshing {
            
            contentToDisplay == .myJokes ? getUserJokes() : getUserFavoriteJokes()
            getProfileInfo()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        contentToDisplay = .myJokes
        
        headerImageView = UIImageView(frame: headerView.bounds)
        headerImageView?.image = UIImage(named: "bg")
        headerImageView?.contentMode = UIViewContentMode.scaleToFill
        headerView.insertSubview(headerImageView, belowSubview: headerLabel)
        
        // Header - Blurred Image
        headerBlurImageView = UIImageView(frame: headerView.bounds)
        headerBlurImageView.image = UIImage(named: "bg")?.blurredImage(withRadius: 10, iterations: 20, tintColor: UIColor.clear)
        headerBlurImageView?.contentMode = UIViewContentMode.scaleToFill
        headerBlurImageView?.alpha = 0.0
        headerView.insertSubview(headerBlurImageView, belowSubview: headerLabel)
        
        /*back = UIButton(frame: CGRect(x: 15, y: 30, width: 20, height: 20))
         back.setImage(UIImage(named: "universal_back"), forState: UIControlState.Normal)
         headerView.insertSubview(back, belowSubview: headerLabel)*/
        
        headerView.clipsToBounds = true
        
        initProfile()
        getUserJokes()
    }
    
    func initProfile(){
        
        if let image = currentUser.image
        {
            avatarImage.loadImageWithCasheWithUrl(image as! String)
            //headerImageView.loadImageWithCasheWithUrl(image as! String)
            //headerBlurImageView.loadImageWithCasheWithUrl(image as! String)
        }
        headerLabel.text = currentUser.name as? String
        handleLabel.text = currentUser.name as? String
        userName.text = currentUser.email as? String
    }
    
    // MARK: Scroll view delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y + headerView.bounds.height
        
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        // PULL DOWN -----------------
        
        if offset < 0 {
            
            let headerScaleFactor:CGFloat = -(offset) / headerView.bounds.height
            let headerSizevariation = ((headerView.bounds.height * (1.0 + headerScaleFactor)) - headerView.bounds.height)/2
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            
            // Hide views if scrolled super fast
            headerView.layer.zPosition = 0
            headerLabel.isHidden = true
            
        }
            
            // SCROLL UP/DOWN ------------
            
        else {
            
            // Header -----------
            
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            
            //  ------------ Label
            
            headerLabel.isHidden = false
            let alignToNameLabel = -offset + handleLabel.frame.origin.y + headerView.frame.height + offset_HeaderStop
            
            headerLabel.frame.origin = CGPoint(x: headerLabel.frame.origin.x, y: max(alignToNameLabel, distance_W_LabelHeader + offset_HeaderStop))
            
            
            //  ------------ Blur
            
            headerBlurImageView?.alpha = min (1.0, (offset - alignToNameLabel)/distance_W_LabelHeader)
            
            // Avatar -----------
            
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / avatarImage.bounds.height / 1.4 // Slow down the animation
            let avatarSizeVariation = ((avatarImage.bounds.height * (1.0 + avatarScaleFactor)) - avatarImage.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
            if offset <= offset_HeaderStop {
                
                if avatarImage.layer.zPosition < headerView.layer.zPosition{
                    headerView.layer.zPosition = 0
                }
                
                
            }else {
                if avatarImage.layer.zPosition >= headerView.layer.zPosition{
                    headerView.layer.zPosition = 2
                }
                
            }
        }
        
        // Apply Transformations
        headerView.layer.transform = headerTransform
        avatarImage.layer.transform = avatarTransform
        
        // Segment control
        
        let segmentViewOffset = profileView.frame.height - segmentedView.frame.height - offset
        
        var segmentTransform = CATransform3DIdentity
        
        // Scroll the segment view until its offset reaches the same offset at which the header stopped shrinking
        segmentTransform = CATransform3DTranslate(segmentTransform, 0, max(segmentViewOffset, -offset_HeaderStop), 0)
        
        segmentedView.layer.transform = segmentTransform
        
        
        // Set scroll view insets just underneath the segment control
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(segmentedView.frame.maxY, 0, 0, 0)
    }
    
    // MARK: Interface buttons
    @IBAction func selectContentType(_ sender: UISegmentedControl) {
        
        // crap code I know
        //self.tableView.reloadData()
        if sender.selectedSegmentIndex == 0 {
            
            contentToDisplay = .myJokes
            self.tableView.reloadData()
            getUserJokes()
            //self.tableView.reloadData()
        }
        else if sender.selectedSegmentIndex == 1{
            
            contentToDisplay = .favorites
            self.tableView.reloadData()
            getUserFavoriteJokes()
        }
    }
    
    @IBAction func EditProfile(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: "EditProfile", sender: self)
    }
    
    @IBAction func SignOut(_ sender: AnyObject) {
        
        defaults.removeObject(forKey: "joke_user_email")
        defaults.removeObject(forKey: "joke_user_name")
        defaults.removeObject(forKey: "joke_user_image")
        defaults.removeObject(forKey: "joke_user_id")
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: AnyObject) {
        
        self.dismiss(animated: true) {
            
        }
    }
}

extension UserProfile{
    
    // MARK: Table view processing
    func createCellHeightsArray() {
        
        for _ in 0...10 {
            cellHeights.append(kCloseCellHeight)
        }
    }
    
    // MARK: Table view processing
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return cellHeights[indexPath.row]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if contentToDisplay == .myJokes {
            
            return userJokes.count
        }
        return userFavoritJokes.count
    }
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "JokeCell" , for: indexPath) as! JokeCell
        if contentToDisplay == .myJokes {
            
            cell.joke = userJokes[indexPath.row]
        }
        else{
            
            cell.joke = userFavoritJokes[indexPath.row]
        }
    
        cell.delegate = self
        
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        
        //print(indexPath.row)
        if cell is FoldingCell {
            let foldingCell = cell as! FoldingCell
            
            if cellHeights[indexPath.row] == kCloseCellHeight {
                foldingCell.selectedAnimation(false, animated: false, completion:nil)
            } else {
                foldingCell.selectedAnimation(true, animated: false, completion: nil)
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        //if numberOfLinesInLabel((jokes[indexPath.row].text as! String), labelWidth: 288, labelHeight: 124, font: UIFont(name: "American Typewriter", size: 14)!) >= 5
        //{
            let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
            
            var duration = 0.0
            if cellHeights[indexPath.row] == kCloseCellHeight { // open cell
                cellHeights[indexPath.row] = kOpenCellHeight
                cell.selectedAnimation(true, animated: true, completion: nil)
                duration = 0.5
            } else {// close cell
                cellHeights[indexPath.row] = kCloseCellHeight
                cell.selectedAnimation(false, animated: true, completion: nil)
                duration = 1.1
            }
            
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
                tableView.beginUpdates()
                tableView.endUpdates()
                }, completion: nil)
        //}
    }
    
    func numberOfLinesInLabel(_ yourString: String, labelWidth: CGFloat, labelHeight: CGFloat, font: UIFont) -> Int {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = labelHeight
        paragraphStyle.maximumLineHeight = labelHeight
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributes: [String: AnyObject] = [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle]
        
        let constrain = CGSize(width: labelWidth, height: CGFloat(Float.infinity))
        
        let size = yourString.size(attributes: attributes)
        let stringWidth = size.width
        
        let numberOfLines = ceil(Double(stringWidth/constrain.width))
        
        return Int(numberOfLines)
    }

    func getUserFavoriteJokes(){
        
        var favList :[String] = [String]()
        for (key, value) in defaults.dictionaryRepresentation() {
            
            if key.contains("favorite") && key.contains("\(currentUser._id!)") {
                //print("\(key) = \(value)")
                favList.append("\(value)")
            }
        }
        
        if favList.count == 0 {
            
            self.tableView.reloadData()
            return
        }
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session : URLSession = URLSession(configuration: configuration)
        
        let urlString = "http://54.67.65.222:3001/api/v1/joke/getuserfavoritejokes/\(favList.joined(separator: ","))"
        
        if let url = URL(string: urlString) {
            
            let request = NSMutableURLRequest(url: url)
            
            request.httpMethod = "GET"
            
            let dataTask = session.dataTask(with: request as URLRequest){data , response , error in
                
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
                                
                                if userFavoritJokes.count > 0 {
                                    
                                    userFavoritJokes.removeAll()
                                    userFavoritJokes = [Joke]()
                                }
                                
                                if let _jokes = _result["content"] as? [AnyObject]{
                                    
                                    
                                    for joke in _jokes{
                                        
                                        if let actJoke = joke as? [String : AnyObject]{
                                            
                                            //print(actJoke)
                                            let _Joke = Joke()
                                            _Joke.setValuesForKeys(actJoke)
                                            //print("like_\(_Joke._id!)")
                                            if let like_ = defaults.object(forKey: "like_\(_Joke._id!)_\(currentUser._id!)"){
                                                
                                                if like_  as! String == "1"{
                                                    
                                                    _Joke.like_or_not = 1
                                                }
                                                else{
                                                    
                                                    _Joke.like_or_not = -1
                                                }
                                            }
                                            userFavoritJokes.append(_Joke)
                                        }
                                    }
                                }
                                DispatchQueue.main.async(execute: {
                                    
                                    userFavoriteJokesLoadAgain = 0
                                    if contentToDisplay == .favorites
                                    {
                                        //self.refreshControl.endRefreshing()
                                        self.tableView.reloadData()
                                    }
                                })
                            }
                            
                        default:
                            break
                            //print(httpResponse.statusCode)
                        }
                    }
                }
                DispatchQueue.main.async(execute: {
                    
                    self.refreshControl.endRefreshing()
                })
            }
            dataTask.resume()
        }
    }
    
    func getUserJokes(){
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session : URLSession = URLSession(configuration: configuration)
        let request = NSMutableURLRequest(url: URL(string: "http://54.67.65.222:3001/api/v1/joke/getuserjokes/\(currentUser._id!)")!)
        
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
                            
                            if userJokes.count > 0 {
                                
                                userJokes.removeAll()
                                userJokes = [Joke]()
                            }
                            
                            if let _jokes = _result["content"] as? [AnyObject]{
                                
                                for joke in _jokes{
                                    
                                    if let actJoke = joke as? [String : AnyObject]{
                                        
                                        //print(actJoke)
                                        let _Joke = Joke()
                                        _Joke.setValuesForKeys(actJoke)
                                        //print("like_\(_Joke._id!)")
                                        if let like_ = defaults.object(forKey: "like_\(_Joke._id!)_\(currentUser._id!)"){
                                            
                                            if like_  as! String == "1"{
                                                
                                                _Joke.like_or_not = 1
                                            }
                                            else{
                                                
                                                _Joke.like_or_not = -1
                                            }
                                        }
                                        userJokes.append(_Joke)
                                    }
                                }
                            }
                            DispatchQueue.main.async(execute: {
                                
                                userJokesLoadAgain = 0
                                if contentToDisplay == .myJokes
                                {
                                    //self.refreshControl.endRefreshing()
                                    self.tableView.reloadData()
                                }
                            })
                        }
                        
                    default:
                        break
                        //print(httpResponse.statusCode)
                    }
                    
                }
            }
            
            DispatchQueue.main.async(execute: { 
                
                self.refreshControl.endRefreshing()
            })
        }
        dataTask.resume()
    }
    
    func like(_ cell: FoldingCell) {
        
        //print("like \(self.tableView.indexPathForCell(cell)?.row)")
        let index = self.tableView.indexPath(for: cell)?.row
        var like_or_dislike:Int!
        let joke : Joke!
        
        if pendingLikeRequest[jokes[index!]._id as! String] == true {
            
            return
        }
        else
        {
            pendingLikeRequest[jokes[index!]._id as! String] = true
        }
        
        if contentToDisplay == .myJokes {
            
            joke = userJokes[index!]
            (userJokes[index!].like_or_not! == 1 ? (like_or_dislike = -1) : (like_or_dislike = 1))
        }
        else{
            joke = userFavoritJokes[index!]
            (userFavoritJokes[index!].like_or_not! == 1 ? (like_or_dislike = -1) : (like_or_dislike = 1))
        }
        
        //print(jokes[index!].like_or_not!)
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session : URLSession = URLSession(configuration: configuration)
        let request = NSMutableURLRequest(url: URL(string: "http://54.67.65.222:3001/api/v1/joke/like_dislike")!)
        
        
        let bodyData = String.localizedStringWithFormat("jokeid=%@&like=%@", "\(joke._id!)" , "\(like_or_dislike!)")
        
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
    
                                    DispatchQueue.main.async(execute: {
                                        
                                        if contentToDisplay == .myJokes {
                            
                                            
                                            
                                            (userJokes[index!].like_or_not! == 1 ? (userJokes[index!].like_or_not! = -1) : (userJokes[index!].like_or_not = 1))
                                            
                                            let a = (userJokes[index!].like as! Int + (1))
                                            let b = (userJokes[index!].like as! Int - (1))
                                            (userJokes[index!].like_or_not! == 1) ? (userJokes[index!].like = a as AnyObject?) : (userJokes[index!].like = b as AnyObject?)
                                        }
                                        else{
                                            
                                            (userFavoritJokes[index!].like_or_not! == 1 ? (userFavoritJokes[index!].like_or_not! = -1) : (userFavoritJokes[index!].like_or_not = 1))
                                            
                                            let a = (userFavoritJokes[index!].like as! Int) + 1
                                            let b = (userFavoritJokes[index!].like as! Int) - 1
                                            
                                            (userFavoritJokes[index!].like_or_not! == 1) ? (userFavoritJokes[index!].like = a as AnyObject?) : (userFavoritJokes[index!].like = b as AnyObject?)
                                        }
                                        
                                        if contentToDisplay == .myJokes {
                                            
                                            if(userJokes[index!].like_or_not! == 1){
                                                
                                                defaults.set("1" , forKey: "like_\(userJokes[index!]._id!)_\(currentUser._id!)")
                                                defaults.synchronize()
                                            }
                                            else{
                                                
                                                defaults.set("-1" , forKey: "like_\(userJokes[index!]._id!)_\(currentUser._id!)")
                                                defaults.synchronize()
                                            }
                                        }
                                        else{
                                            
                                            if(userFavoritJokes[index!].like_or_not! == 1){
                                                
                                                defaults.set("1" , forKey: "like_\(userFavoritJokes[index!]._id!)_\(currentUser._id!)")
                                                defaults.synchronize()
                                            }
                                            else{
                                                
                                                defaults.set("-1" , forKey: "like_\(userFavoritJokes[index!]._id!)_\(currentUser._id!)")
                                                defaults.synchronize()
                                            }
                                        }
                                    
                                        self.tableView.reloadRows(at: [self.tableView.indexPath(for: cell)!], with: UITableViewRowAnimation.fade)
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
            pendingLikeRequest[jokes[index!]._id as! String] = false
        }
        dataTask.resume()
    }
    
    func share(_ cell: FoldingCell) {
        
        //print("share")
        // text to share
        let index = self.tableView.indexPath(for: cell)?.row
        let text = jokes[index!].text as! String
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        // exclude some activity types from the list (optional)
        //activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook]
        
        // present the view controller
        present(activityViewController, animated: true) {
            
            
        }
    }
    
    func favorite(_ cell: FoldingCell) {
        
        let index = self.tableView.indexPath(for: cell)?.row
        
        let _Joke:Joke!
        contentToDisplay == .myJokes ? (_Joke = userJokes[index!]) : (_Joke = userFavoritJokes[index!])
        
        if defaults.object(forKey: "favorite_\(_Joke._id!)_\(currentUser._id!)") != nil{
            
            //print(favorite)
            defaults.removeObject(forKey: "favorite_\(_Joke._id!)_\(currentUser._id!)")
            
            var i = 0
            for joke in userFavoritJokes
            {
                if "favorite_\(joke._id!)_\(currentUser._id!)" == "favorite_\(_Joke._id!)_\(currentUser._id!)"
                {
                   userFavoritJokes.remove(at: i)
                    break
                }
                i += 1
            }
            
        }else{
            
            defaults.set(_Joke._id! , forKey: "favorite_\(_Joke._id!)_\(currentUser._id!)")
        }
        
        contentToDisplay == .favorites ? (self.tableView.reloadData()) : self.tableView.reloadRows(at: [self.tableView.indexPath(for: cell)!], with: UITableViewRowAnimation.fade)
    }
    
    func getProfileInfo(){
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session : URLSession = URLSession(configuration: configuration)
        let request = NSMutableURLRequest(url: URL(string: "http://54.67.65.222:3001/api/v1/user/userinfo/\(currentUser._id!)")!)
        
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
                                
                                if status == 200
                                {
                                    if let user = _result["content"] as? [String : AnyObject]{
                                        
                                        currentUser.setValuesForKeys(user)
                                        defaults.set(currentUser._id, forKey: "joke_user_id")
                                        defaults.set(currentUser.name, forKey: "joke_user_name")
                                        defaults.set(currentUser.email, forKey: "joke_user_email")
                                        defaults.set(currentUser.image, forKey: "joke_user_image")
                                        self.initProfile()
                                    }
                                }
                                else{
                                    
                                }
                            }
                        }
                        
                    default:
                        break
                        //print(httpResponse.statusCode)
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    func edit(_ cell: FoldingCell) {
        
        let index = self.tableView.indexPath(for: cell)?.row
        
        jokeForEdit = userJokes[index!]
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let content = storyboard.instantiateViewController(withIdentifier: "EditJoke")
        let partialModal: EMPartialModalViewController = EMPartialModalViewController(rootViewController: content, contentHeight: self.view.bounds.height - 200)
        
        self.present(partialModal, animated: true)
        {
            
        }
    }
    
    func delete_(_ cell: FoldingCell) {
        
        ActivityIndicatory(self.view)
        let index = self.tableView.indexPath(for: cell)?.row
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session : URLSession = URLSession(configuration: configuration)
        let request = NSMutableURLRequest(url: URL(string: "http://54.67.65.222:3001/api/v1/joke/deletejoke")!)
        let joke : Joke!
        joke = userJokes[index!]
        
        let bodyData = String.localizedStringWithFormat("jokeid=%@", "\(joke._id!)")
        
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
                                    DispatchQueue.main.async(execute: { 
                                        
                                        if defaults.object(forKey: "favorite_\(joke._id!)_\(currentUser._id!)") != nil
                                        {
                                            defaults.removeObject(forKey: "favorite_\(joke._id!)_\(currentUser._id!)")
                                        }
                                        userJokes.remove(at: index!)
                                        self.tableView.reloadData()
                                    })
                                }
                            }
                        }
                        
                    default:
                        break
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
}
