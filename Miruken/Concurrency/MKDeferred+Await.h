//
//  MKDeferred+Await.h
//  Miruken
//
//  Created by Craig Neuwirt on 7/3/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKDeferred.h"

extern NSString * const kDeferredAwaitKey;

@interface MKDeferred (Await)

+ (MKDeferred *)await;

+ (MKDeferred *)awaitOrDefault:(MKDeferred *)deferred;

@end
