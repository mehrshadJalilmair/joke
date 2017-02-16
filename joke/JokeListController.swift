//
//  ViewController.swift
//  joke
//
//  Created by Mehrshad Jalilmasir on 11/1/16.
//  Copyright © 2016 Mehrshad Jalilmasir. All rights reserved.
//

import UIKit
import FoldingCell
import LiquidFloatingActionButton

var jokes:[Joke] = [Joke]()
let defaults = UserDefaults.standard
let appearance = SCLAlertView.SCLAppearance(
    kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
    kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
    kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
    showCloseButton: false
)
var loadAgain = 1

class ViewController: UIViewController, LiquidFloatingActionButtonDataSource, LiquidFloatingActionButtonDelegate , FoldingCellDelegate , UIScrollViewDelegate{

    var Offset = 0
    var loadingMore = false
    
    var cells: [LiquidFloatingCell] = []
    var bottomRightButton: LiquidFloatingActionButton!
    
    let kCloseCellHeight: CGFloat = 315
    let kOpenCellHeight: CGFloat = 320
    var cellHeights = [CGFloat]()
    
    @IBOutlet weak var tableView: UITableView!
    
    let container: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentToDisplay = .none
        self.tableView.alwaysBounceVertical = false
        self.tableView.alwaysBounceHorizontal = false
        settingPullRefresh()
        createCellHeightsArray()
        setupActionButton()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        self.Offset = 0
        self.loadingMore = false
        getJokes()
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
        
        contentToDisplay = .none
        if loadAgain == 1
        {
            if defaults.object(forKey: "joke_user_id") != nil
            {
                //print(_id)
                getProfileInfo()
            }
            loadAgain = 0
        }
        
        if jokeAdded {
            
            self.Offset = 0
            loadingMore = false
            jokeAdded = false
            getJokes()
        }
        //print("viewDidAppear")
        //self.tableView.reloadData()
    }
    
    //Mark : Just Vars
    var refreshControl: UIRefreshControl!
    func settingPullRefresh()
    {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PullToRefresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        //loadCustomRefreshContents()
    }
    func PullToRefresh() {
        
        if refreshControl.isRefreshing {
            
            //refreshControl.beginRefreshing()
            self.Offset = 0
            self.loadingMore = false
            getJokes()
        }
    }
    
    fileprivate var lastContentOffset: CGFloat = 0
    fileprivate var lastContentOffsetCache: CGFloat = 0
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if jokes.count < 2
        {
            return
        }
        
        var temp = -1
        
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            
            temp = 1
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y) {
            
            temp = 0
        }
        
        var reachBottom = false
        var reachTop = false
        
        self.lastContentOffset = scrollView.contentOffset.y
        
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            //reach bottom
            //print("bottom")
            reachBottom = true
        }
        
        if (scrollView.contentOffset.y < 0){
            //reach top
            //print("top")
            reachTop = true
        }
        
        if reachBottom && jokes.count < 3
        {
            self.bottomRightButton.isHidden = true
        }
        else if reachTop && jokes.count < 3
        {
            self.bottomRightButton.isHidden = false
        }
        
        if (scrollView.contentOffset.y >= 0 && scrollView.contentOffset.y < (scrollView.contentSize.height - scrollView.frame.size.height)){
            //not top and not bottom
            //print("not top and not bottom")
            if temp == 0 {
                
                UIView.animate(withDuration: 1, delay: 0, options: .showHideTransitionViews, animations: {
                    self.bottomRightButton.alpha = 0 // Here you will get the animation you want
                    }, completion: { finished in
                        self.bottomRightButton.isHidden = true // Here you hide it when animation done
                })
            }else{
                
                UIView.animate(withDuration: 0.6, delay: 0, options: .showHideTransitionViews, animations: {
                    self.bottomRightButton.alpha = 1 // Here you will get the animation you want
                    }, completion: { finished in
                        self.bottomRightButton.isHidden = false // Here you hide it when animation done
                })
            }
        }
    }
    
    func setupActionButton(){
    
        let createButton: (CGRect, LiquidFloatingActionButtonAnimateStyle) -> LiquidFloatingActionButton = { (frame, style) in
            let floatingActionButton = CustomDrawingActionButton(frame: frame)
            floatingActionButton.animateStyle = style
            floatingActionButton.dataSource = self
            floatingActionButton.delegate = self
            return floatingActionButton
        }
        
        ///let cellFactory: (String) -> LiquidFloatingCell = { (iconName) in
            //let cell = LiquidFloatingCell(icon: UIImage(named: iconName)!)
            //return cell
        //}
//        let customCellFactory: (String) -> LiquidFloatingCell = { (iconName) in
//            let cell = CustomCell(icon: UIImage(named: iconName)!, name: iconName)
//            return cell
//        }
        //cells.append(cellFactory("edit"))
        //cells.append(customCellFactory("exit"))
        
        let floatingFrame = CGRect(x: self.view.frame.width - 64 - 16, y: self.view.frame.height - 64 - 16, width: 64, height: 64)
        
        bottomRightButton = createButton(floatingFrame, .up)
        
        let image = UIImage(named: "ic_add_white_48pt")
        bottomRightButton.cellRadiusRatio = 0.41
        bottomRightButton.image = image
        bottomRightButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(newJoke)))
        //let floatingFrame2 = CGRect(x: 16, y: 16, width: 56, height: 56)
        //let topLeftButton = createButton(floatingFrame2, .Down)
        
        self.view.addSubview(bottomRightButton)
        //self.view.addSubview(topLeftButton)
    }
    
    func newJoke(){
        
        //print("newJoke")
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let content = storyboard.instantiateViewController(withIdentifier: "addJoke")
        let partialModal: EMPartialModalViewController = EMPartialModalViewController(rootViewController: content, contentHeight: self.view.bounds.height - 100)
        self.present(partialModal, animated: true)
        {
            
        }
    }
    
    func createCellHeightsArray() {
        
        for _ in 0...50 {
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
     
        return jokes.count
    }
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "JokeCell" , for: indexPath) as! JokeCell
        cell.joke = jokes[indexPath.row]
        cell.delegate = self
        
        if indexPath.row == jokes.count - 1 { //load more
            
            if loadingMore {
                
                getJokes()
                loadingMore = false
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        
        //print(indexPath.row)
        
        if jokes.count > 0
        {
            if defaults.object(forKey: "seen_\(jokes[indexPath.row]._id!)_\(currentUser._id!)") != nil{
                
                //print(visited)
            }
            else{
                
                defaults.set("1" , forKey: "seen_\(jokes[indexPath.row]._id!)_\(currentUser._id!)")
                self.seen(jokes[indexPath.row]._id! as! String , index: indexPath.row , indexPath: indexPath)
            }
        }

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
        
        //if NSString(string : (jokes[indexPath.row].text as! String)).length < 50 //numberOfLinesInLabel((jokes[indexPath.row].text as! String), labelWidth: 288, labelHeight: 124, font: UIFont(name: "American Typewriter", size: 14)!) >= 5
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
    
    //menu bar actions
    @IBAction func userSetting(_ sender: AnyObject) {
        
        
        if defaults.object(forKey: "joke_user_id") != nil
        {
            //print(_id)
            self.performSegue(withIdentifier: "profile", sender: self)
        }
        else{
            self.performSegue(withIdentifier: "registering", sender: self)
        }
    }
    
    @IBAction func refreshList(_ sender: AnyObject) {
        
        if !refreshControl.isRefreshing
        {
            refreshControl.beginRefreshing()
            self.Offset = 0
            self.loadingMore = false
            getJokes()
        }
    }
    
    //action button funcs override
    func numberOfCells(_ liquidFloatingActionButton: LiquidFloatingActionButton) -> Int {
        return cells.count
    }
    
    func cellForIndex(_ index: Int) -> LiquidFloatingCell {
        return cells[index]
    }
    
    func liquidFloatingActionButton(_ liquidFloatingActionButton: LiquidFloatingActionButton, didSelectItemAtIndex index: Int) {
        
        switch index{
            
        case 0:
            
            break
            
        default:
            break
        }
        
        liquidFloatingActionButton.close()
    }
}


open class CustomCell : LiquidFloatingCell {
    
    var name: String = "sample"
    
    init(icon: UIImage, name: String) {
        self.name = name
        super.init(icon: icon)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func setupView(_ view: UIView) {
        super.setupView(view)
        let label = UILabel()
        label.text = name
        label.textColor = UIColor.white
        label.font = UIFont(name: "Helvetica-Neue", size: 12)
        addSubview(label)
        
        //NSLayoutConstraint(item: label, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .LeadingMargin, multiplier: 1.0, constant: -80.0).active = true
        
        //NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .TrailingMargin, multiplier: 1.0, constant: 0.0).active = true
        
        //NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: label, attribute:.Width, multiplier: 2.0, constant:75.0).active = true
    }
}

open class CustomDrawingActionButton: LiquidFloatingActionButton {
    
    override open func createPlusLayer(_ frame: CGRect) -> CAShapeLayer {
        
        let plusLayer = CAShapeLayer()
        plusLayer.lineCap = kCALineCapRound
        plusLayer.strokeColor = UIColor.white.cgColor
        plusLayer.lineWidth = 3.0
        
        let w = frame.width
        let h = frame.height
        
        let points = [
            (CGPoint(x: w * 0.25, y: h * 0.35), CGPoint(x: w * 0.75, y: h * 0.35)),
            (CGPoint(x: w * 0.25, y: h * 0.5), CGPoint(x: w * 0.75, y: h * 0.5)),
            (CGPoint(x: w * 0.25, y: h * 0.65), CGPoint(x: w * 0.75, y: h * 0.65))
        ]
        
        let path = UIBezierPath()
        for (start, end) in points {
            path.move(to: start)
            path.addLine(to: end)
        }
        
        plusLayer.path = path.cgPath
        return plusLayer
    }
}

extension ViewController{
    
    func edit(_ cell: FoldingCell) {
        
    }
    func delete_(_ cell: FoldingCell) {
    }
    //cell protocol functions
    func like(_ cell: FoldingCell) {
        
        
        guard let indexPath = self.tableView.indexPath(for: cell) else
        {
            return
        }
        let index = indexPath.row
        
        var like_or_dislike:Int!
        (jokes[index].like_or_not! == 1 ? (like_or_dislike = -1) : (like_or_dislike = 1)) //error at Here
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session : URLSession = URLSession(configuration: configuration)
        let request = NSMutableURLRequest(url: URL(string: "http://54.67.65.222:3001/api/v1/joke/like_dislike")!)
        let joke = jokes[index]
        let bodyData = String.localizedStringWithFormat("jokeid=%@&like=%@", "\(joke._id!)" , "\(like_or_dislike!)")
        
        request.httpMethod = "POST"
        request.httpBody = bodyData.data(using: String.Encoding.utf8)
        
        let dataTask = session.dataTask(with: request as URLRequest) {data,response,error in
            
            if error == nil
            {
                if let httpResponse = response as? HTTPURLResponse
                {
                    
                    switch(httpResponse.statusCode)
                    {
                        
                    case 200,304:
                        
                        if let data = data{
                            
                            guard let _result = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String : AnyObject] else{
                                
                                return
                            }
                            //print(_result)
                            if let status = _result["status"] as? Int{
                                
                                if status == 200
                                {
                                    DispatchQueue.main.async(execute: {
                                        
                                        (jokes[index].like_or_not! == 1 ? (jokes[index].like_or_not! = -1) : (jokes[index].like_or_not = 1))
                                        
                                        let a = (jokes[index].like as! Int) + 1
                                        let b = (jokes[index].like as! Int) - 1
                                        (jokes[index].like_or_not! == 1) ? (jokes[index].like = a as AnyObject?) : (jokes[index].like = b as AnyObject?)
                                        
                                        if(jokes[index].like_or_not! == 1){
                                            
                                            defaults.set("1" , forKey: "like_\(jokes[index]._id!)_\(currentUser._id!)")
                                            defaults.synchronize()
                                        }
                                        else{
                                            
                                            defaults.set("-1" , forKey: "like_\(jokes[index]._id!)_\(currentUser._id!)")
                                            defaults.synchronize()
                                        }
                                        
                                        //error at Here
                                        
                                        
                                        guard let indexPath = self.tableView.indexPath(for: cell) else
                                        {
                                            return
                                        }
                                        
                                        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                                    })
                                }
                                else if(status == 501){
                                    
                                    DispatchQueue.main.async(execute: {
                                        
                                        jokes.remove(at: index)
                                        self.tableView.reloadData()
                                    })
                                }
                            }
                            else{
                                
                                //self.likeRollBack(index!, like_dislike: jokes[index!].like_or_not!)
                            }
                        }
                        else{
                            
                            //self.likeRollBack(index!, like_dislike: jokes[index!].like_or_not!)
                        }
                        
                    default:
                        //self.likeRollBack(index!, like_dislike: jokes[index!].like_or_not!)
                        break
                        //print(httpResponse.statusCode)
                    }
                }
                else{
                    
                    //self.likeRollBack(index!, like_dislike: jokes[index!].like_or_not!)
                }
            }
            else{
                
                //self.likeRollBack(index!, like_dislike: jokes[index!].like_or_not!)
            }
        }
        dataTask.resume()
    }
    
    func likeRollBack(_ index : Int , like_dislike : Int)
    {
        
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
        let _Joke = jokes[index!]
        
        if defaults.object(forKey: "favorite_\(_Joke._id!)_\(currentUser._id!)") != nil{
            
            //print(favorite)
            defaults.removeObject(forKey: "favorite_\(_Joke._id!)_\(currentUser._id!)")
        }else{
            
            defaults.set(_Joke._id! , forKey: "favorite_\(_Joke._id!)_\(currentUser._id!)")
        }
        
        self.tableView.reloadRows(at: [self.tableView.indexPath(for: cell)!], with: UITableViewRowAnimation.fade)
    }
    
    func getJokes(){
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session : URLSession = URLSession(configuration: configuration)
        let request = NSMutableURLRequest(url: URL(string: "http://54.67.65.222:3001/api/v1/joke/getjokes/\(self.Offset)")!)
        
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
                            
                            
                            /*if jokes.count > 0 {
                                
                                jokes.removeAll()
                                jokes = [Joke]()
                            }*/
                            
                            if let _jokes = _result["content"] as? [AnyObject]{
                                
                                self.Offset == 0 ? (jokes = [Joke]()) : ()
                                
                                if _jokes.count == 0
                                {
                                    self.loadingMore = false
                                }
                                else
                                {
                                    self.loadingMore = true
                                    self.Offset += 20
                                }
                                
                                for joke in _jokes{
                                    
                                    if let actJoke = joke as? [String : AnyObject]{
                                        
                                        //print(actJoke)
                                        let _Joke = Joke()
                                        _Joke.setValuesForKeys(actJoke)
                                        //print("date_\(_Joke.date!)\n")
                                        if let like_ = defaults.object(forKey: "like_\(_Joke._id!)_\(currentUser._id!)"){
                                            
                                            if like_  as! String == "1"{
                                                
                                                _Joke.like_or_not = 1
                                            }
                                            else{
                                                
                                                _Joke.like_or_not = -1
                                            }
                                        }
                                        jokes.append(_Joke)
                                    }
                                }
                                DispatchQueue.main.async(execute: {
                                    
                                    //self.refreshControl.endRefreshing()
                                    //self.refreshControl.endRefreshing()
                                    self.tableView.reloadData()
                                })
                            }
                        }
                        
                    default:
                        break
                        //print(httpResponse.statusCode)
                    }
                }
            }
            
            DispatchQueue.main.async(execute: {
                
                //self.refreshControl.endRefreshing()
                //self.refreshControl.endRefreshing()
                self.refreshControl.endRefreshing()
            })
        }
        dataTask.resume()
    }
    
    func seen(_ id : String , index : Int , indexPath : IndexPath){
        
        if (jokes[index].writer! as! String) == (currentUser._id! as! String)
        {
            return
        }
        //print("\(id)\n")
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session : URLSession = URLSession(configuration: configuration)
        let request = NSMutableURLRequest(url: URL(string: "http://54.67.65.222:3001/api/v1/joke/viewsplus")!)
        let bodyData = String.localizedStringWithFormat("jokeid=%@", id) // in request body
        
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
                                        
                                        jokes[index].view = (jokes[index].view as! Int) + 1 as  AnyObject
                                        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                                        //print("visited")
                                    })
                                }
                                else if(status == 501){
                                    
                                    DispatchQueue.main.async(execute: {
                                        defaults.removeObject(forKey: "seen_\(id)_\(currentUser._id!)")
                                        jokes.remove(at: index)
                                        self.tableView.reloadData()
                                    })
                                }
                            }
                        }
                        
                    default:
                        defaults.removeObject(forKey: "seen_\(id)_\(currentUser._id!)")
                    }
                }
            }
            else{
                
                defaults.removeObject(forKey: "seen_\(id)_\(currentUser._id!)")
            }
        }
        dataTask.resume()
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
}

