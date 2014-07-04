//
//  MKOperationResult.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/29/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAsyncResult_Subclassing.h"

/**
  Specialized AsyncResult that integrates with the NSOperationQueue mechanism. 
 */

@protocol MKOperationResult <MKAsyncResult>

- (NSOperation *)operation;

@end

@interface MKOperationResult : MKAsyncResult <MKOperationResult>

@end
