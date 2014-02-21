//
//  MKContextObserver.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/9/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKContext.h"

/**
  Basic implementation of the MKContextObserver protocol.
 */
 
@interface MKContextObserver : NSObject <MKContextObserver>

+ (instancetype)contextDidEnd:(MKContextAction)didEnd;

+ (instancetype)contextWillEnd:(MKContextAction)willEnd didEnd:(MKContextAction)didEnd;

+ (instancetype)childContextDidEnd:(MKContextAction)didEnd;

+ (instancetype)childContextWillEnd:(MKContextAction)willEnd didEnd:(MKContextAction)didEnd;

@end
