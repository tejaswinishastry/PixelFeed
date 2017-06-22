//
//  PhotoViewerViewController.swift
//  PixelFeed
//
//  Created by Tejaswini Shastry on 6/17/17.
//  Copyright © 2017 Tejaswini Shastry. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import SwiftyJSON

class PhotoViewerViewController: UIViewController, UIScrollViewDelegate {
    
    let scrollView = UIScrollView()
    let imageView = UIImageView()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    var user: User?
    var coreDataStack: CoreDataStack!
    
    var photoInfo: PhotoInfo?
        
    @IBOutlet weak var imageLarge: UIImageView!

    @IBOutlet weak var likeButton = UIButton(type: .custom)
    
    
    // MARK: Life-Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        if let fetchRequest = coreDataStack.model.fetchRequestTemplate(forName: "UserFetchRequest") {
            
            let results = try! coreDataStack.context.fetch(fetchRequest) as! [User]
            user = results.first
        }
        
    }

    
    func setupView() {
        //TODO: Add hardcoded values as a const with #define
        scrollView.frame = view.bounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2.0
        scrollView.zoomScale = 1.0
        view.addSubview(scrollView)
        
        spinner.center = CGPoint(x: view.center.x, y: view.center.y - view.bounds.origin.y / 2.0)
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        view.addSubview(spinner)
        scrollView.addSubview(imageLarge)
        
        // SYNC PHOTO LOAD
        let url = URL(string: (self.photoInfo?.sourceImageURL.absoluteString)!)
        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        self.imageLarge.image = UIImage(data: data!)
        
        // Likes
        self.spinner.stopAnimating()
        if ((photoInfo?.userHasLiked)! ){
            if let image = UIImage(named: "like") {
                self.likeButton?.setImage(image, for: UIControlState.normal)
            }
        }
        else {
            if let image = UIImage(named: "unlike") {
                self.likeButton?.setImage(image, for: UIControlState.normal)
            }
        }
        
        view.addSubview(likeButton!)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        // Fetch users
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centerScrollViewContents()
    }
    
    // MARK: Gesture Recognizers
    
    func handleDoubleTap(_ recognizer: UITapGestureRecognizer!) {
        let pointInView = recognizer.location(in: self.imageView)
        self.zoomInZoomOut(pointInView)
    }
    
    // MARK: ScrollView
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerScrollViewContents()
    }
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.frame
        var contentsFrame = self.imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - scrollView.scrollIndicatorInsets.top - scrollView.scrollIndicatorInsets.bottom - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        self.imageView.frame = contentsFrame
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func zoomInZoomOut(_ point: CGPoint!) {
        let newZoomScale = self.scrollView.zoomScale > (self.scrollView.maximumZoomScale/2) ? self.scrollView.minimumZoomScale : self.scrollView.maximumZoomScale
        
        let scrollViewSize = self.scrollView.bounds.size
        
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        let x = point.x - (width / 2.0)
        let y = point.y - (height / 2.0)
        
        let rectToZoom = CGRect(x: x, y: y, width: width, height: height)
        
        self.scrollView.zoom(to: rectToZoom, animated: true)
    }
    
   
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        if (photoInfo?.userHasLiked)! {
            let request = Instagram.Router.unlikePhoto((self.photoInfo?.id)!, (self.user?.accessToken)!)
            likeUnlikePhoto(request)
        }
        else {
            let request = Instagram.Router.likePhoto((self.photoInfo?.id)!, (self.user?.accessToken)!)
            likeUnlikePhoto(request)
        }
    }
    
    func likeUnlikePhoto(_ request: URLRequestConvertible){
        Alamofire.request(request).responseJSON {
            response in
            
            switch response.result {
            case .success(let jsonObject):
                let json = JSON(jsonObject)
                if (json["meta"]["code"].intValue  == 200) {
                    if self.likeButton?.currentImage == UIImage(named: "like") {
                        //unlike photo
                        if let image = UIImage(named: "unlike") {
                            self.likeButton?.setImage(image, for: UIControlState.normal)
                        }
                        self.photoInfo?.userHasLiked = false
                        
                    }
                    else {
                        //likePhoto
                        if let image = UIImage(named: "like") {
                            self.likeButton?.setImage(image, for: UIControlState.normal)
                        }
                        self.photoInfo?.userHasLiked = true
                    }
                }
                
            case .failure:
                break
            }
        }
        
    }
}
