//
//  APIManager.swift
//  DemoApp
//
//  Created by ChenWei on 2020/5/18.
//  Copyright © 2020 Jacob. All rights reserved.
//

import UIKit

class APIManager: NSObject {
    typealias completionClosure = (VirtualModelEntity) -> Void
    static let ServerURL: URL = URL(string: "https://bamboowand.github.io/")!
    static let FileNames = ["retrotv", "coffee_machine"]
    static var ModelDictionary = [ String : VirtualModelEntity]()
    static let TempDictPathURL = URL(fileURLWithPath: NSTemporaryDirectory())
    static var caches = NSCache<NSString, UIImage>()
    
    
    static func DownloadUSDZFromURL(_ url: URL, complete: @escaping completionClosure) {
        let destinationUrl = TempDictPathURL.appendingPathComponent(url.lastPathComponent)
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destinationUrl.path) {
            VirtualModelEntityLoader.loadAsync(url: destinationUrl, loadedHandle: complete)
            return
        }
        
        // URLSession
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let downloadTask = session.downloadTask(with: request, completionHandler: { (location:URL?, response:URLResponse?, error:Error?) -> Void in
            DispatchQueue.main.async {
                guard let location = location else { return }
                do {
                    try fileManager.moveItem(atPath: location.path, toPath: destinationUrl.path)
                    VirtualModelEntityLoader.loadAsync(url: destinationUrl, loadedHandle: complete)
                }
                catch {
                    print("Error: File couldn't be moved to tmp, reson \(error.localizedDescription)")
                }
            }
        })
        downloadTask.resume()
    }
    
    // MARK: - Property methods
    var cache: NSCache = NSCache<NSURL, VirtualModelEntity>()
    
    // MARK: - Singleton init
    struct Static {
        internal static var instance: APIManager?
    }
        
    public class var shared: APIManager {
        if Static.instance == nil {
            Static.instance = APIManager()
        }
        return Static.instance!
    }
    
    private override init() {
        super.init()
        
        print("J_🔧 ARGameEngine init")
    }
        
    func dispose() {
        APIManager.Static.instance = nil
        print("J_🗡 ARGameEngine disposed singleton instance")
    }
        
    deinit {
        print("J_☠️ ARGameEngine release")
    }
    
    func downloadUSDZFrom(_ url: URL, complete: @escaping completionClosure) {
        
    }
    
    
    
}

extension APIManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }
    
    
}
