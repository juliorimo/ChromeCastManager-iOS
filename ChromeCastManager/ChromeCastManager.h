//
//  ChromeCastManager.h
//  NBCUMaster
//
//  Created by Julio Rivas on 17/4/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@class ChromeCastMetadata;

typedef NS_ENUM(NSUInteger, ChromeCastErrorCode) {
    ChromeCastCodeCredentials=0,
    ChromeCastCodeDevices,
    ChromeCastCodeMetadata
};

typedef void (^ChromeCastStatus)(BOOL success, NSError *error);

@interface ChromeCastManager : NSObject

+ (instancetype)sharedInstance;

#pragma mark - Init 

/**
 *  Init singleton with defautl identifier
 *
 *  @param completionBlock
 */

- (void)initChromeCastManagerWithCompletionBlock:(ChromeCastStatus)completionBlock;

/**
 *  Init singleton with id or default identifier 
 *
 *  @param identifier
 *  @param completionBlock
 */

- (void)initChromeCastManager:(NSString *)identifier withCompletionBlock:(ChromeCastStatus)completionBlock;

#pragma mark - Play

- (void)playVideo:(ChromeCastMetadata *)metadata fromView:(UIView *)view withCompletionBlock:(ChromeCastStatus)completionBlock;

@end
