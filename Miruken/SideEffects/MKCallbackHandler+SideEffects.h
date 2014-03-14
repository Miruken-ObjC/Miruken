//
//  MKCallbackHandler+SideEffects.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/1/12.
//  Copyright (c) 2012 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKCallbackHandler.h"
#import "MKContextual.h"
#import "MKLoading.h"

/**
  MKCallbackHandler category for constructing side-effects.
  */

typedef BOOL (^MKSideEffectBeforeAction)(id callback, id<MKCallbackHandler> composer);
typedef void (^MKSideEffectAfterAction)(id callback, id<MKCallbackHandler> composer);

@interface MKCallbackHandler (MKCallbackHandler_SideEffects)

- (instancetype)timer:(void(^)(double duration))done;

- (instancetype)network;

- (instancetype)loading:(id<MKLoading>)Loading;

- (instancetype)spinToolbarItem:(UIViewController<MKContextual> *)viewController atIndex:(NSUInteger)index;

- (instancetype)guard:(id)guard;

- (instancetype)suspendUserInteraction:(UIView *)view;

- (instancetype)suppressScrolling:(UIScrollView *)scrollView;

- (instancetype)sideEffect:(MKSideEffectBeforeAction)before after:(MKSideEffectAfterAction)after;

@end
