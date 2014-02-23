//
//  MKSideEffects.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/12/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

@protocol MKSideEffects

@optional
- (void)beginNetworkActivity;

- (void)endNetworkActivity;

@end

#define MKSideEffects(handler)  ((id<MKSideEffects>)(handler))
