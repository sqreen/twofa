//
//  PasteboardWatcher.swift
//  PasteboardWatcher
//
//  Created by Devarshi Kulshreshtha on 6/19/15.PasteboardWatcher
//  Copyright © 2015 Devarshi Kulshreshtha. All rights reserved.
//
import Foundation
import CoreGraphics
import AppKit

/// Protocol defining the methods which delegate has/ can implement
protocol PasteboardWatcherDelegate {
    /// the method which is invoked on delegate when a new url of desired kind is copied
    func newlyCopiedCImageObtained(_ image : CIImage)
}
/// Use this class to notify a delegate once a url with specified kind is copied
/// - Credit goes to: **Josh Goebel**
/// - His wonderful pastie: [PasteboardWatcher in objective-c](http://pastie.org/1129293)
public class PasteboardWatcher : NSObject {
    // assigning a pasteboard object
    private let pasteboard = NSPasteboard.general
    // to keep track of count of objects currently copied
    // also helps in determining if a new object is copied
    private var changeCount : Int
    // used to perform polling to identify if url with desired kind is copied
    private var timer: Timer?
    // the delegate which will be notified when desired link is copied
    var delegate: PasteboardWatcherDelegate?
    // the kinds of files for which if url is copied the delegate is notified
    override public init() {
        self.changeCount = pasteboard.changeCount
        guard Thread.isMainThread else {
            fatalError("Instantiate PasteboardWatcher on the main thread")
        }
        super.init()
        self.startPolling()
        
    }
    /// starts polling to identify if url with desired kind is copied
    /// - Note: uses an NSTimer for polling
    func startPolling () {
        // setup and start of timer
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(PasteboardWatcher.checkForChangesInPasteboard), userInfo: nil, repeats: true)
    }
    /// method invoked continuously by timer
    /// - Note: To keep this method as private I referred this answer at stackoverflow - [Swift - NSTimer does not invoke a private func as selector](http://stackoverflow.com/a/30947182/217586)
    @objc private func checkForChangesInPasteboard() {
        // check if there is any new item copied
        // also check if kind of copied item is string
        if let copiedData = pasteboard.data(forType: NSPasteboard.PasteboardType.png), pasteboard.changeCount != changeCount {
            
            if let img = CIImage(data: copiedData) {
                self.delegate?.newlyCopiedCImageObtained(img)
            }
            
            // assign new change count to instance variable for later comparison
            changeCount = pasteboard.changeCount
        }
    }
}
