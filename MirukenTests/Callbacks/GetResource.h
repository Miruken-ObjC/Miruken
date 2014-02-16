//
//  GetResource.h
//  MirukenTestss
//
//  Created by Craig Neuwirt on 9/21/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetResource : NSObject

@property (readonly, copy, nonatomic) NSString *resourceId;
@property (strong,   nonatomic)       id        resource;

+ (GetResource *)withId:(NSString *)resourceId;

@end
