//
//  ScreenshotDetector.swift
//  Commander
//
//  Created by Janis Kirsteins on 10/03/2019.
//
//  Content from https://gist.github.com/ts95/300c5a815393087c72cc
//

import Foundation

public typealias NewFileCallback = (_ fileURL: NSURL) -> Void

public class ScreenshotDetector: NSObject, NSMetadataQueryDelegate {

    let query = NSMetadataQuery()

    public var newFileCallback: NewFileCallback?

    override public init() {
        super.init()

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(ScreenshotDetector.queryUpdated), name: NSNotification.Name.NSMetadataQueryDidStartGathering, object: query)
        center.addObserver(self, selector: #selector(ScreenshotDetector.queryUpdated), name: NSNotification.Name.NSMetadataQueryDidUpdate, object: query)
        center.addObserver(self, selector: #selector(ScreenshotDetector.queryUpdated), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: query)

        query.delegate = self
        query.predicate = NSPredicate(format: "kMDItemIsScreenCapture = 1")
        query.start()
    }

    deinit {
        query.stop()
    }


    @objc public func queryUpdated(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            for v in userInfo.values {
                let items = v as! [NSMetadataItem]
                if items.count > 0 {
                    let item = items[0]
                    if let filename = item.value(forAttribute: "kMDItemFSName") as? String {
                        let filenameWithPath = NSString(string: "~/Desktop/" + filename).expandingTildeInPath
                        let url = NSURL(fileURLWithPath: filenameWithPath, isDirectory: false)
                        if let cb = self.newFileCallback {
                            cb(url)
                        }
                    }
                }
            }
        }
    }
}
