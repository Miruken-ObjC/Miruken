//
//  NSObject+Promise.h
//  Miruken
//
//  Created by Craig Neuwirt on 11/30/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKPromise.h"

@interface NSObject (NSObject_Promise)

- (id<MKPromise>)makePromise;

@end
