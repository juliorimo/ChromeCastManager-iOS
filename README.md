# ChromeCastManager-iOS
Manager for playing videos in your TV using ChromeCast.

This manager use Google-Cast-SDK in order to connect and play videos via ChromeCast.

## How to use it

Make an init call into your AppDelegate to start scanning

    //Init
    [[ChromeCastManager sharedInstance] initChromeCastManagerWithCompletionBlock:^(BOOL success, NSError *error) {
        
        if(error){
            NSLog(@"Init chromecast: %@",error.localizedDescription);
        }
        
    }];

After that, when you want to play any content, you have to create a ChomeCastMetadata object with all the information from your video:

	//Metadata
    ChromeCastMetadata *metadata = [[ChromeCastMetadata alloc] init];
    metadata.title = @"Big Buck Bunny (2008)";
    metadata.subtitle = @"Big Buck Bunny tells the story of a giant rabbit with a heart bigger than himself. When one sunny day three rodents rudely harass him, something snaps... and the rabbit ain't no bunny anymore! In the typical cartoon tradition he prepares the nasty rodents a comical revenge.";
    metadata.imageUrl = @"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg";
    metadata.imageSize = CGSizeMake(480, 360);
    metadata.videoUrl = @"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
    metadata.videoContentType = @"video/mp4";

And just playing your content:

    //Chromecast
    [[ChromeCastManager sharedInstance] playVideo:metadata fromView:self.view withCompletionBlock:^(BOOL success, NSError *error) {
        
        if(success){
            
            
        }else{
            
            if(error){
                NSLog(@"error: %@",error);
            }
        }
    }];

