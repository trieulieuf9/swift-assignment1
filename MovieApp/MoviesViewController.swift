//
//  MoviesViewController.swift
//  MovieApp
//
//  Created by trieulieuf9 on 7/6/16.
//  Copyright © 2016 trieulieuf9. All rights reserved.
//
import UIKit
import AFNetworking
import AMTumblrHud

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITabBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorLabel: UILabel!
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var searchBar: UISearchBar!
    var tumHud:AMTumblrHud!
    var blurView:UIVisualEffectView!
    var refreshControl:UIRefreshControl!
    
    var movies = [NSDictionary]()
    var searchResult = [NSDictionary]()
    var topRatedMovies = [NSDictionary]()
    let baseUrl = "https://image.tmdb.org/t/p/w342"
    var isNetworkFalse = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getDataFromApiAndUpdateView), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = UIColor.clearColor()
        
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items![0]
        tabBar.barTintColor = UIColor(red: 255/255, green: 210/255, blue: 215/255, alpha: 1.0)

        navigationController!.navigationBar.barTintColor = UIColor(red: 255/255, green: 210/255, blue: 215/255, alpha: 1.0)
        
        searchBar.delegate = self
        
        // blur the background when loading for data
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = self.view.bounds
        self.view.addSubview(blurView)
        
        // loading state UI effect
        let screenBounds = UIScreen.mainScreen().bounds
        let width = screenBounds.width
        let height = screenBounds.height
        
        tumHud = AMTumblrHud(frame: CGRectMake(width/2 - 27, height/2, 55, 20))
        tumHud.showAnimated(true)
        
        self.view.addSubview(tumHud)
        
        // check if wifi or 3G is available
        if Reachability.isConnectedToNetwork(){
            getDataFromApiAndUpdateView()
        }else{
            networkError()
        }
    }
    
//    func setUpGridView(){
//        let gridView = UICollectionView(frame: tableView.frame)
//    }
    
    func getDataFromApiAndUpdateView(){
        // loading data from web
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in if let data = dataOrNil {                            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
            data, options:[]) as? NSDictionary {
            self.movies = responseDictionary["results"] as! [NSDictionary]
            self.tableView.reloadData()
            // stop loading UI Effect
            self.tumHud.removeFromSuperview()
            self.blurView.removeFromSuperview()
            self.isNetworkFalse = false
            self.refreshControl.endRefreshing()
            self.networkErrorLabel.hidden = true
            }}})
        
        task.resume()
    }
    
    // show a network error label
    func networkError(){
        if self.isNetworkFalse {
            networkErrorLabel.hidden = false
            self.view.addSubview(networkErrorLabel)
            blurView.removeFromSuperview()
            tumHud.removeFromSuperview()
        }
    }
    
    // TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if searchResult.count != 0 {
            return searchResult.count
        }else if topRatedMovies.count != 0 {
            return topRatedMovies.count
        }
        return movies.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // insert data into cell
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell") as! MovieCell
        var posterUrl = ""
        if searchResult.count != 0 {
            cell.titleLabel?.text = searchResult[indexPath.row]["title"] as? String
            cell.overviewLabel?.text = searchResult[indexPath.row]["overview"] as? String
            posterUrl = baseUrl + (searchResult[indexPath.row]["poster_path"] as! String)
        }else if topRatedMovies.count != 0 {
            cell.titleLabel?.text = topRatedMovies[indexPath.row]["title"] as? String
            cell.overviewLabel?.text = topRatedMovies[indexPath.row]["overview"] as? String
            posterUrl = baseUrl + (topRatedMovies[indexPath.row]["poster_path"] as! String)
        }else{
            cell.titleLabel?.text = movies[indexPath.row]["title"] as? String
            cell.overviewLabel?.text = movies[indexPath.row]["overview"] as? String
            posterUrl = baseUrl + (movies[indexPath.row]["poster_path"] as! String)
        }
        
        
        // Customize Cell
        let backgroundView = UIView()
        backgroundView.backgroundColor =
            UIColor(red: 255/255, green: 210/255, blue: 215/255, alpha: 1.0)
        
        cell.selectedBackgroundView = backgroundView
        cell.accessoryType = .None
        
        cell.titleLabel?.backgroundColor = UIColor(red: 255/255, green: 210/255, blue: 215/255, alpha: 1.0)
        
        // fading in as image loading
        let imageRequest = NSURLRequest(URL: NSURL(string: posterUrl)!)
        cell.posterImage.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    cell.posterImage.alpha = 0.0
                    cell.posterImage.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.posterImage.alpha = 1.0
                    })
                } else {
                    cell.posterImage.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        return cell
    }
    
    // UISearchBar filter
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchResult = []
        for dic in movies { // movies is an array of dictionary
            if dic["title"]!.containsString(searchText) {
                searchResult.append(dic)
            }
        }
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.view.endEditing(true)
        searchBar.text = ""
        
        let highResBaseUrl = "https://image.tmdb.org/t/p/original"
        let nextVC = segue.destinationViewController as! DetailsViewController
        
        let ip = tableView.indexPathForSelectedRow
        
        var lowResolutionUrl = ""
        var highResolutionUrl = ""
        var overview = ""
        var movieTitle = ""
        
        if searchResult.count != 0 {
            lowResolutionUrl = baseUrl + (searchResult[ip!.row]["poster_path"] as! String)
            highResolutionUrl = highResBaseUrl + (searchResult[ip!.row]["poster_path"] as! String)
            overview = searchResult[ip!.row]["overview"] as! String
            movieTitle = searchResult[ip!.row]["title"] as! String
        }else if topRatedMovies.count != 0 {
            lowResolutionUrl = baseUrl + (topRatedMovies[ip!.row]["poster_path"] as! String)
            highResolutionUrl = highResBaseUrl + (topRatedMovies[ip!.row]["poster_path"] as! String)
            overview = topRatedMovies[ip!.row]["overview"] as! String
            movieTitle = topRatedMovies[ip!.row]["title"] as! String
        }else{
            lowResolutionUrl = baseUrl + (movies[ip!.row]["poster_path"] as! String)
            highResolutionUrl = highResBaseUrl + (movies[ip!.row]["poster_path"] as! String)
            overview = movies[ip!.row]["overview"] as! String
            movieTitle = movies[ip!.row]["title"] as! String
        }
        
        nextVC.lowResPosterUrl = lowResolutionUrl
        nextVC.highResPosterUrl = highResolutionUrl
        nextVC.overview = overview
        nextVC.movieTitle = movieTitle
        
        searchResult = []
        topRatedMovies = []
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if item.tag == 1 {
            var topRate:[Double] = []
            for dic in movies {
                topRate.append(dic["vote_average"] as! Double)
            }
            topRate.sortInPlace()
            
            let top6 = topRate.reverse()[0...5]
            for dic in movies {
                if top6.contains(dic["vote_average"] as! Double) {
                    topRatedMovies.append(dic)
                }
            }
            
            tableView.reloadData()
        }else{
            topRatedMovies = []
            tableView.reloadData()
        }
    }
}




