//
//  MKHandleGreedy.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/1/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
  Marks a Callback so it will be handled greedily by default.  Otherwise, callers
  would have to explicitly indicate greedy through a parameter.
  */

@protocol MKHandleGreedy <NSObject>

@optional
@property (readonly, nonatomic) BOOL handled;

@end
