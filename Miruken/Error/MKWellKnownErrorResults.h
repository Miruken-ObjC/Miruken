//
//  MKWellKnownErrorResults.h
//  Miruken
//
//  Created by Craig Neuwirt on 2/11/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKWellKnownErrorResults : NSObject

+ (id)continue;

+ (id)retry;

+ (id)errorInProgress;

@end
