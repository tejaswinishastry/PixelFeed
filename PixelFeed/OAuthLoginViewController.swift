//
//  OAuthLoginViewController.swift
//  PixelFeed
//
//  Created by Tejaswini Shastry on 6/17/17.
//  Copyright © 2017 Tejaswini Shastry. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class OauthLoginViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    var coreDataStack: CoreDataStack!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.isHidden = true
        URLCache.shared.removeAllCachedResponses()
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        let request = try! URLRequest(url: Instagram.Router.requestOauthToken.asURLRequest().url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        self.webView.loadRequest(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {

        let redirectURIComponents = URLComponents(string: Instagram.Router.redirectURI)!
        let components = URLComponents(string: String(describing: request.url!))
        if components?.host == redirectURIComponents.host {
            //TODO: need a better way to pull out fragment info
            if let accessToken = components?.fragment?.components(separatedBy: "=")[1] {
                requestUserInfoWithToken(accessToken)
                return false
            }
        }
        return true
    }
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.isHidden = false
    }
    
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToPhotoBrowser" && segue.destination.isKind(of: PhotoBrowserCollectionViewController.classForCoder()) {
            let photoBrowserCollectionViewController = segue.destination as! PhotoBrowserCollectionViewController
            if let user = (sender as AnyObject).value(forKey: "user") as? User {
                photoBrowserCollectionViewController.user = user
                
            }
        }
    }
    
    
    func requestUserInfoWithToken(_ accessToken: String) {
        
        let request = Instagram.Router.user(accessToken)
        
        Alamofire.request(request).responseJSON {
            response in
            switch response.result {
            case .success(let jsonObject):
                let jsonResult = JSON(jsonObject)
                let userID = jsonResult["data"]["id"].string
                
                let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: self.coreDataStack.context) as! User
                user.userID = userID!
                user.accessToken = accessToken
                self.coreDataStack.saveContext()
                self.performSegue(withIdentifier: "unwindToPhotoBrowser", sender: ["user": user])
                
            case .failure:
                debugPrint("could not get user information")
                break;
            }
        }
        
    }

}
