//
//  ChromeCastMetadata.h
//  NBCUMaster
//
//  Created by Julio Rivas on 28/4/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@interface ChromeCastMetadata : NSObject

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *subtitle;

@property (nonatomic,assign) CGSize imageSize;
@property (nonatomic,strong) NSString *imageUrl;

@property (nonatomic,strong) NSString *videoUrl;
@property (nonatomic,strong) NSString *videoContentType;

@end
