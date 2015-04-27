//
//  ChromeCastManager.m
//  NBCUMaster
//
//  Created by Julio Rivas on 17/4/15.
//  Copyright (c) 2015 accedo.tv. All rights reserved.
//

#import "ChromeCastManager.h"
#import <GoogleCast/GoogleCast.h>

static NSString * const ChromeCastManagerErrorDomain = @"ChromeCastManager";

static NSInteger const CCActionSheetScannedDevices = 1;
static NSInteger const CCActionSheetConnectedDevice = 2;

static NSString * ChromeCastReceiverAppID;

@interface ChromeCastManager() <GCKDeviceScannerListener,GCKDeviceManagerDelegate,GCKMediaControlChannelDelegate,UIActionSheetDelegate>
@property(nonatomic, strong) GCKDeviceScanner *deviceScanner;
@property(nonatomic, strong) GCKDeviceManager *deviceManager;
@property(nonatomic, readonly) GCKMediaInformation *mediaInformation;
@end

@implementation ChromeCastManager{
    
    //Selected device
    GCKDevice *_selectedDevice;
    
    //Control
    GCKMediaControlChannel *_mediaControlChannel;
    
    //Metadata
    GCKApplicationMetadata *_applicationMetadata;
    
    //Init block
    ChromeCastStatus _initBlock;
    
    //Play block
    ChromeCastStatus _playBlock;
}

#pragma mark - Init

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)initChromeCastManager{
    
    DLog();
    
    //Scan
    [self startScan];
    
    //Block
    _initBlock(YES,nil);
}

- (void)initChromeCastManagerWithCompletionBlock:(ChromeCastStatus)completionBlock{
    
    //Default
    ChromeCastReceiverAppID = kGCKMediaDefaultReceiverApplicationID;
    
    //Block
    _initBlock = completionBlock;
    
    //Init
    [self initChromeCastManager];
}

- (void)initChromeCastManager:(NSString *)identifier withCompletionBlock:(ChromeCastStatus)completionBlock{
    
    //Id
    if(identifier && identifier.length){
    
        //Id
        ChromeCastReceiverAppID = identifier;
        
    }else{
    
        //Default
        ChromeCastReceiverAppID = kGCKMediaDefaultReceiverApplicationID;
    }
    
    //Block
    _initBlock = completionBlock;

    //init
    [self initChromeCastManager];
}

#pragma mark - Play

- (void)playVideo:(NSString *)videoUrl fromView:(UIView *)view withCompletionBlock:(ChromeCastStatus)completionBlock{

    DLog(@"%@",videoUrl);
    
    //More than one
    if([self getScannedDevices].count){
        
        //Block
        _playBlock = completionBlock;
        
        //Show devices
        [self showScannedDevicesInView:view];
        
    }else{
        
        //Error
        NSError *error = [self errorWithCode:ChromeCastDevices andDescription:NSLocalizedStringFromTable(@"_ERROR_DEVICES_NOT_FOUND", @"ChromeCast", @"")];
    
        //Error
        completionBlock(NO,error);
    }
}

#pragma mark - Show devices

- (NSArray *)getScannedDevices {
    return self.deviceScanner.devices;
}

- (void)showScannedDevicesInView:(UIView *)view{
    
    if (_selectedDevice == nil) {

        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"_ACTION_SHEET_TITLE_CONNECT", @"ChromeCast", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        actionSheet.tag = CCActionSheetScannedDevices;
        
        for (GCKDevice *device in self.deviceScanner.devices) {
            [actionSheet addButtonWithTitle:device.friendlyName];
        }
        
        
        
        [actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"_BUTTON_CANCEL", @"ChromeCast", nil)];
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
        
        [actionSheet showInView:view];
        
    }else{

        if (_mediaControlChannel && self.deviceManager.isConnected) {
            _mediaInformation = _mediaControlChannel.mediaStatus.mediaInformation;
        }
    
        NSString *friendlyName = [NSString stringWithFormat:@"%@ %@",NSLocalizedStringFromTable(@"_ACTION_SHEET_CONNECTING", @"ChromeCast", nil), _selectedDevice.friendlyName];
        NSString *mediaTitle = [self.mediaInformation.metadata stringForKey:kGCKMetadataKeyTitle];
        
        UIActionSheet *sheet = [[UIActionSheet alloc] init];
        sheet.tag = CCActionSheetConnectedDevice;
        sheet.title = friendlyName;
        sheet.delegate = self;
        if (mediaTitle != nil) {
            [sheet addButtonWithTitle:mediaTitle];
        }
        
        //Offer disconnect option
        [sheet addButtonWithTitle:NSLocalizedStringFromTable(@"_BUTTON_DISCONNECT", @"ChromeCast", nil)];
        [sheet addButtonWithTitle:NSLocalizedStringFromTable(@"_BUTTON_CANCEL", @"ChromeCast", nil)];
        sheet.destructiveButtonIndex = (mediaTitle != nil ? 1 : 0);
        sheet.cancelButtonIndex = (mediaTitle != nil ? 2 : 1);
        
        [sheet showInView:view];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(actionSheet.tag==CCActionSheetScannedDevices){
        
        if (buttonIndex < self.deviceScanner.devices.count) {
            
            //Select
            _selectedDevice = self.deviceScanner.devices[buttonIndex];
            
            //Connect
            [self connectToDevice];
            
        }else{
            
            //Error
            _playBlock(NO,nil);
        }
    
    }else if(actionSheet.tag==CCActionSheetConnectedDevice){
    
        if (buttonIndex == 1) {  //Disconnect button
            DLog(@"Disconnecting device:%@", _selectedDevice.friendlyName);
            
            // New way of doing things: We're not going to stop the applicaton. We're just going
            // to leave it.
            [self.deviceManager leaveApplication];
            
            // If you want to force application to stop, uncomment below
            //[self.deviceManager stopApplicationWithSessionID:self.applicationMetadata.sessionID];
            [self.deviceManager disconnect];
            
            [self deviceDisconnected];
            
            //Dissconnect
            _playBlock(YES,nil);
            
        } else if (buttonIndex == 0) {
            // Join the existing session.
        }
    }
}

#pragma mark - Connect

- (BOOL)isConnected {
    return self.deviceManager.isConnected;
}

- (void)connectToDevice {
    
    if (_selectedDevice == nil){
    
        _playBlock(NO,nil);

        return;
    }
        
    DLog(@"Selecting device: %@", _selectedDevice.friendlyName);
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    self.deviceManager = [[GCKDeviceManager alloc] initWithDevice:_selectedDevice clientPackageName:[info objectForKey:@"CFBundleIdentifier"]];
    self.deviceManager.delegate = self;
    [self.deviceManager connect];
}

- (void)deviceDisconnected {
    
    DLog();
    
    _mediaControlChannel = nil;
    self.deviceManager = nil;
    _selectedDevice = nil;
}

#pragma mark - GCKDeviceManagerDelegate

- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager {
    
    DLog(@"connected!!");
    
    [self.deviceManager launchApplication:ChromeCastReceiverAppID];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata sessionID:(NSString *)sessionID launchedApplication:(BOOL)launchedApplication {
    
    DLog(@"application has launched");
    
    _mediaControlChannel = [[GCKMediaControlChannel alloc] init];
    _mediaControlChannel.delegate = self;
    [self.deviceManager addChannel:_mediaControlChannel];
    [_mediaControlChannel requestStatus];
    
    //Cast
    [self castVideo];
    
    //Play video
    _playBlock(YES,nil);
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didFailToConnectToApplicationWithError:(NSError *)error {

    //Disconnect
    [self deviceDisconnected];
    
    //Play error
    _playBlock(NO,error);
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didFailToConnectWithError:(GCKError *)error {
    
    [self deviceDisconnected];
    
    //Play error
    _playBlock(NO,error);
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didDisconnectWithError:(GCKError *)error {

    DLog(@"Received notification that device disconnected");
    
    if (error != nil) {
        [self showError:error];
    }
    
    [self deviceDisconnected];
    
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didReceiveStatusForApplication:(GCKApplicationMetadata *)applicationMetadata {
//    self.applicationMetadata = applicationMetadata;
    
    DLog();
}

#pragma mark - Scan

- (void)startScan{

    DLog();
    
    //Initialize device scanner
    self.deviceScanner = [[GCKDeviceScanner alloc] init];
    
    [self.deviceScanner addListener:self];
    [self.deviceScanner startScan];
}

- (void)stopScan{
    
    DLog();

    [self.deviceScanner stopScan];
}

#pragma mark - Cast Video

- (void)castVideo{

    DLog(@"Cast Video");
    
    //Show alert if not connected
    if (!self.deviceManager || !self.deviceManager.isConnected) {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"_ALERT_NOT_CONNECT", @"ChromeCast", nil)
                                   message:NSLocalizedStringFromTable(@"_ALERT_PLEASE_CONNECT_TO_CAST", @"ChromeCast", nil)
                                  delegate:nil
                         cancelButtonTitle:NSLocalizedStringFromTable(@"_BUTTON_OK", @"ChromeCast", nil)
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //Define Media metadata EXAMPLE
    GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];
    
    [metadata setString:@"Big Buck Bunny (2008)" forKey:kGCKMetadataKeyTitle];
    
    [metadata setString:@"Big Buck Bunny tells the story of a giant rabbit with a heart bigger than "
     "himself. When one sunny day three rodents rudely harass him, something "
     "snaps... and the rabbit ain't no bunny anymore! In the typical cartoon "
     "tradition he prepares the nasty rodents a comical revenge."
                 forKey:kGCKMetadataKeySubtitle];
    
    [metadata addImage:[[GCKImage alloc]
                        initWithURL:[[NSURL alloc] initWithString:@"http://commondatastorage.googleapis.com/"
                                     "gtv-videos-bucket/sample/images/BigBuckBunny.jpg"]
                        width:480
                        height:360]];
    
    //define Media information
    GCKMediaInformation *mediaInformation =
    [[GCKMediaInformation alloc] initWithContentID:
     @"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
                                        streamType:GCKMediaStreamTypeNone
                                       contentType:@"video/mp4"
                                          metadata:metadata
                                    streamDuration:0
                                        customData:nil];
    
    //cast video
    [_mediaControlChannel loadMedia:mediaInformation autoplay:TRUE playPosition:0];
}

#pragma mark - GCKDeviceScannerListener

- (void)deviceDidComeOnline:(GCKDevice *)device {
    DLog(@"%@", device.friendlyName);
}

- (void)deviceDidGoOffline:(GCKDevice *)device {
    DLog(@"%@", device.friendlyName);
}

- (void)deviceDidChange:(GCKDevice *)device{
    DLog(@"%@", device.friendlyName);
}

#pragma mark - misc

- (void)showError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"_ERROR_TITLE", @"ChromeCast", nil)
                                                    message:NSLocalizedString(error.description, nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedStringFromTable(@"_BUTTON_OK", @"ChromeCast", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Error

- (NSError *)errorWithCode:(ChromeCastErrorCode)code andDescription:(NSString *)description{
    
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: description,
                               NSLocalizedFailureReasonErrorKey: @"",
                               NSLocalizedRecoverySuggestionErrorKey: @""};
    
    
    NSError *error = [NSError errorWithDomain:ChromeCastManagerErrorDomain
                                         code:code
                                     userInfo:userInfo];
    
    return error;
}


@end
