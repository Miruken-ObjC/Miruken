//
//  NSObject+ResolvePromise.h
//  Miruken
//
//  Created by Craig Neuwirt on 2/16/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPromise.h"

@interface NSObject (NSObject_ResolvePromise)

- (MKPromise)effectivePromise;

@end
