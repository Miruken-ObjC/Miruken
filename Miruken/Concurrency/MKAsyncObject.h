//
//  MKAsyncObject.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/23/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKAsyncDelegate.h"
#import "MKAsyncResult.h"

/**
  This class is a proxy that adds concurrency behaviors to an object.
  The concurrency details are determined by the AsyncDelegate.
 */

@protocol MKAsyncObject

- (id)outAsyncResult:(id<MKAsyncResult> __autoreleasing *)outAsyncResult;

- (id)weak;

@end

@interface MKAsyncObject : NSProxy <MKAsyncObject>

- (id)initWithClass:(Class)aClass delegate:(id<MKAsyncDelegate>)delegate;

- (id)initWithObject:(id)anObject delegate:(id<MKAsyncDelegate>)delegate;

@end
