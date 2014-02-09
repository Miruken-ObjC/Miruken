//
//  NSInvocation+Objects.h
//  Concurrency
//
//  Created by Craig Neuwirt on 2/7/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (NSInvocation_Objects)

- (BOOL)returnsObject;

- (id)objectReturnValue;

- (void)setObjectReturnValue:(id)returnValue;

@end
