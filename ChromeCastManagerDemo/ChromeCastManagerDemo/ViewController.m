//
//  ViewController.m
//  ChromeCastManagerDemo
//
//  Created by Julio Rivas on 27/4/15.
//  Copyright (c) 2015 Julio Rivas. All rights reserved.
//

#import "ViewController.h"

#import "ChromeCastMetadata.h"
#import "ChromeCastManager.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - Play video

- (IBAction)playVideo:(id)sender{

    //Metadata
    ChromeCastMetadata *metadata = [[ChromeCastMetadata alloc] init];
    metadata.title = @"Big Buck Bunny (2008)";
    metadata.subtitle = @"Big Buck Bunny tells the story of a giant rabbit with a heart bigger than himself. When one sunny day three rodents rudely harass him, something snaps... and the rabbit ain't no bunny anymore! In the typical cartoon tradition he prepares the nasty rodents a comical revenge.";
    metadata.imageUrl = @"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg";
    metadata.imageSize = CGSizeMake(480, 360);
    metadata.videoUrl = @"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
    metadata.videoContentType = @"video/mp4";
    
    //Chromecast
    [[ChromeCastManager sharedInstance] playVideo:metadata fromView:self.view withCompletionBlock:^(BOOL success, NSError *error) {
        
        if(success){
            
            
        }else{
            
            if(error){
                NSLog(@"error: %@",error);
            }
        }
    }];

}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - Memory warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
