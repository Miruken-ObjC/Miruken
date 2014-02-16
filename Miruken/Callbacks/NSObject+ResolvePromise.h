//
//  NSObject+ResolvePromise.h
//  Miruken
//
//  Created by Craig Neuwirt on 2/16/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKPromise.h"

@interface NSObject (ResolvePromise)

- (BOOL)isPromise;

- (id<MKPromise>)effectivePromise;

@end
