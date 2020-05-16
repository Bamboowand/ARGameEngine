//
//  Downloader.swift
//  DemoApp
//
//  Created by ChenWei on 2020/5/15.
//  Copyright © 2020 Jacob. All rights reserved.
//

import Foundation

class WebInteraction {
    
    class func downloadFile(url: URL, completion: @escaping (URL) -> Void) {
        // File path
//        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory())
        let destinationUrl = tempUrl.appendingPathComponent(url.lastPathComponent)
        
        // URLSession
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let downloadTask = session.downloadTask(with: request, completionHandler: { (location:URL?, response:URLResponse?, error:Error?) -> Void in
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: destinationUrl.path) {
//                try! fileManager.removeItem(atPath: destinationUrl.path)
                completion(destinationUrl)
                return
            }
            try! fileManager.moveItem(atPath: location!.path, toPath: destinationUrl.path)
            DispatchQueue.main.async {
                completion(destinationUrl)
            }
        })
        downloadTask.resume()
    }
    
    class func clearTemp() {
        do {
            let tempArray = try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
            for fileString in tempArray {
                try! FileManager.default.removeItem(atPath: NSTemporaryDirectory() + fileString)
            }
            
        }
        catch let error {
            print("Error: Fail to read url, \(error.localizedDescription)")
        }
    }
}
