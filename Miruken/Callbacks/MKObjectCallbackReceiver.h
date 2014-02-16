//
//  MKObjectCallbackReceiver.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/8/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackReceiver.h"
#import "MKDeferred.h"

/**
  An MKObjectCallbackReceiver is a callback wrapper for receiving instances of class.
  */

@interface MKObjectCallbackReceiver : MKDeferred <MKCallbackReceiver>

@property (readonly, assign, nonatomic) Class forClass;

+ (instancetype)forClass:(Class)aClass;

+ (instancetype)forObject:(id)callback;

- (BOOL)tryResolve:(id)result withKindOfClass:(BOOL)kindOfClass;

@end
