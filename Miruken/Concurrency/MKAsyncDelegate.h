//
//  MKAsyncDelegate.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/24/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKAsyncResult.h"

/**
  This protocol encapsulates the concurrency strategy for invocation execution.
 */

@protocol MKAsyncDelegate <NSObject>

- (id<MKAsyncResult>)asyncResultForInvocation:(NSInvocation *)invocation;

- (void)completeResult:(id<MKAsyncResult>)asyncResult;

@end

@interface MKAsyncDelegate : NSObject <MKAsyncDelegate>

@end
