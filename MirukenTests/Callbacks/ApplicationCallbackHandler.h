//
//  ApplicationCallbackHandler.h
//  MirukenTests
//
//  Created by Craig Neuwirt on 10/16/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MirukenCallbacks.h"

@interface ApplicationCallbackHandler : MKDynamicCallbackHandler <UIApplicationDelegate>

@property (strong, nonatomic) NSDictionary *launchOptions;

@end
