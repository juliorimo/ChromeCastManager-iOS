//
//  ChromeCastManagerTests.swift
//  ChromeCastManagerDemo
//
//  Created by Julio Rivas on 28/4/15.
//  Copyright (c) 2015 Julio Rivas. All rights reserved.
//

import UIKit
import XCTest

class ChromeCastManagerTests: XCTestCase {

    var metadata:ChromeCastMetadata = ChromeCastMetadata()
    
    override func setUp() {
        super.setUp()
        
        //Init
        ChromeCastManager.sharedInstance().initChromeCastManagerWithCompletionBlock { (status:Bool, error:NSError!) -> Void in
            XCTAssertNotNil(status, "init with default key")
        }
        
        //Metadata
        metadata.title = "Big Buck Bunny (2008)"
        metadata.subtitle = "Big Buck Bunny tells the story of a giant rabbit with a heart bigger than himself. When one sunny day three rodents rudely harass him, something snaps... and the rabbit ain't no bunny anymore! In the typical cartoon tradition he prepares the nasty rodents a comical revenge."
        metadata.imageUrl = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg"
        metadata.imageSize = CGSizeMake(480, 360);
        metadata.videoUrl = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
        metadata.videoContentType = "video/mp4"
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        
        //Init
        ChromeCastManager.sharedInstance().initChromeCastManagerWithCompletionBlock { (status:Bool, error:NSError!) -> Void in
            XCTAssertNotNil(status, "init with default key")
        }
    }
    
    func testInitWithKey() {
        
        //Init with key
        ChromeCastManager.sharedInstance().initChromeCastManager("id") { (status:Bool, error:NSError!) -> Void in
            XCTAssertTrue(status, "")
        }
    }
    
    func testInitWithEmptyKey() {
        
        //Init with key
        ChromeCastManager.sharedInstance().initChromeCastManager("") { (status:Bool, error:NSError!) -> Void in
            XCTAssertFalse(status, "")
        }
    }
    
    func testInitWithNilKey() {
        
        //Init with key
        ChromeCastManager.sharedInstance().initChromeCastManager(nil) { (status:Bool, error:NSError!) -> Void in
            XCTAssertFalse(status, "")
        }
    }
    
    func testPlayAsset() {
        
        //Play
        ChromeCastManager.sharedInstance().playVideo(metadata, fromView: UIView()) { (status:Bool, error:NSError!) -> Void in
            
            if(status){
                XCTAssertTrue(status, "metadata ok");
            }else{
                XCTAssertFalse(status, "metadata fail");
            }
        }
    }
    
    func testPlayAssetWithoutUrl() {
        
        //Url
        metadata.videoUrl = ""
        
        //Play
        ChromeCastManager.sharedInstance().playVideo(metadata, fromView: UIView()) { (status:Bool, error:NSError!) -> Void in
            XCTAssertFalse(status, "empty url")
        }
    }
}
