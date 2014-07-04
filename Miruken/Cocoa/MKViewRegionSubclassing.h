//
//  MKViewRegionSubclassing.h
//  Miruken
//
//  Created by Craig Neuwirt on 5/29/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKViewRegion.h"
#import "MKPresentationPolicy.h"

@protocol MKViewRegionSubclassing <MKViewRegion>

@optional
- (BOOL)canPresentWithOptions:(id<MKPresentationOptions>)options;

- (MKPromise)presentViewController:(UIViewController *)viewController
                        withPolicy:(MKPresentationPolicy *)policy;

@end

@interface MKViewRegionSubclassing : NSObject <MKViewRegionSubclassing>

@end
