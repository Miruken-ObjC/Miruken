//
//  MKDynamicCallbackHandlerExtension.h
//  Miruken
//
//  Created by Craig Neuwirt on 4/24/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKDynamicCallbackHandler.h"

@interface MKDynamicCallbackHandlerExtension : NSObject

+ (void)install;

- (MKDynamicCallbackHandler *)handler;

@end
