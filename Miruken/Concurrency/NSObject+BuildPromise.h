//
//  NSObject+Promise.h
//  Miruken
//
//  Created by Craig Neuwirt on 11/30/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPromise.h"

@interface NSObject (NSObject_BuildPromise)

- (BOOL)isPromise;

- (id<MKPromise>)makePromise;

@end
