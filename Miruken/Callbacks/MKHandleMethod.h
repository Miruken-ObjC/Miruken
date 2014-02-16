//
//  MKHandleMethod.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/16/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import "MKInternalCallback.h"

/**
  Internal callback to discover a viable method signature from any MKCallbackHandler.
 */

@interface MKFindMethodSignature : NSObject <MKInternalCallback>

@property (readonly, assign)    SEL                selector;
@property (strong,   nonatomic) NSMethodSignature *signature;

+ (instancetype)forSelector:(SEL)selector;

@end


/**
  Internal callback to deliver a callback represented as a normal objective-c message.
 */

typedef void (^MKHandleMethodBlock)(NSInvocation *invocation);

@interface MKHandleMethod : NSObject

@property (readonly, strong)  NSInvocation *invocation;

+ (instancetype)withInvocation:(NSInvocation *)invocation;

+ (instancetype)withInvocation:(NSInvocation *)invocation didInvoke:(MKHandleMethodBlock)didInvoke;

+ (instancetype)current;

+ (MKCallbackHandler *)composer;

- (BOOL)invokeOn:(id)target composition:(MKCallbackHandler *)composer;

- (void)notHandled;

@end
