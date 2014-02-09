//
//  MKAction.h
//  Miruken
//
//  Created by Craig Neuwirt on 2/7/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
  An Action executes an objective-C block so it can leverage concurrency.
  */

@interface MKAction : NSObject

+ (void)do:(dispatch_block_t)action;

- (void)do:(dispatch_block_t)action;

@end
