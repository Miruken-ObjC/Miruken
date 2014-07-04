//
//  MKAsyncResult_Subclassing.h
//  Miruken
//
//  Created by Craig Neuwirt on 7/3/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAsyncResult.h"

@class MKDeferred;

@interface MKAsyncResult : NSObject <MKAsyncResult>

@property (readonly, strong, nonatomic) MKDeferred *deferred;

- (id)initWithInvocation:(NSInvocation *)invocation;

- (id)extractResultFromInvocation:(NSInvocation *)invocation;

+ (NSArray *)copyBlockArguments:(NSInvocation *)invocation;

+ (void)releaseBlockArguments:(NSArray *)blockArguments;

@end
