//
//  ViewController.swift
//  GeoLocation
//
//  Created by 加藤 雄大 on 2015/12/13.
//  Copyright © 2015年 grandbig.github.io. All rights reserved.
//

import UIKit
import WebKit
import CoreLocation
import RealmSwift

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, CLLocationManagerDelegate {

    var lm:CLLocationManager! = nil
    var webView:WKWebView?
    let originalProtocol:String = "com.kato.geolocation://"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "GeoLocation"
        
        self.webView = WKWebView(frame: self.view.bounds)
        self.webView?.navigationDelegate = self
        self.webView?.UIDelegate = self
        
        let url = NSURL(string: "URLを指定してください")
        let req = NSURLRequest(URL: url!)
        self.webView?.loadRequest(req)
        
        self.view.addSubview(self.webView!)
        
        self.lm = CLLocationManager()
        self.lm.delegate = self
        self.lm.requestAlwaysAuthorization()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedAlways:
            break
        default:
            break
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // エラーが発生した場合
        print("\(error)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            let location = locations.first
            if let lat = location?.coordinate.latitude, lng = location?.coordinate.longitude, acc = location?.horizontalAccuracy {
                // 緯度および経度, 精度が取得できた場合
                self.insertData(lat, lng: lng, acc: acc, type: "NATIVE")
                let value = "setNativeGeoLocation('\(lat)', '\(lng)', '\(acc)')"
                self.webView?.evaluateJavaScript(value, completionHandler: { (object, error) -> Void in} )
            }
        }
    }
    
    // MARK: - WKNavigationDelegate
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Webページの読込み開始
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        // Webページ遷移前に呼び出される処理
        if let urlArray:[String] = navigationAction.request.URL?.absoluteString.componentsSeparatedByString("://") {
            // URLが分割できた場合
            if urlArray.count > 1 {
                let requestName:String = urlArray[1]
                if requestName == "getLocation" {
                    // 位置情報の取得を要求された場合
                    // 位置情報の取得
                    self.lm.requestLocation()
                    decisionHandler(.Cancel)
                    return
                } else {
                    let paramArray:[String] = requestName.componentsSeparatedByString("?")
                    if paramArray.count > 1 {
                        let paramString = paramArray[1]
                        let params = paramString.componentsSeparatedByString("&")
                        if let lat:Double = Double(params[0]), lng:Double = Double(params[1]), acc:Double = Double(params[2]) {
                            self.insertData(lat, lng: lng, acc: acc, type: "WEB")
                        }
                    }
                }
            }
        }
        decisionHandler(.Allow)
        
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        // Webページ読み込み語に呼び出される処理
    }
    
    // MARK: - WKUIDelegate
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        // アラート表示を要求された場合に呼び出される処理
        let alert:UIAlertController = UIAlertController(title: "確認", message: message, preferredStyle: .Alert)
        let okAction:UIAlertAction = UIAlertAction(title: "OK", style: .Default, handler: { (alert) -> Void in
            completionHandler()
        })
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - other
    func insertData(lat:Double, lng: Double, acc:Double, type:String) {
        let realm = try! Realm()
        
        let geo = Geo()
        geo.lat = lat
        geo.lng = lng
        geo.acc = acc
        geo.type = type
        geo.date = NSDate()
        
        try! realm.write {
            realm.add(geo)
        }
    }
}

