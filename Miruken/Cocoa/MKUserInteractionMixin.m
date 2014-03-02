//
//  MKUserIneractionMixin.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/16/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKUserInteractionMixin.h"
#import "MKMixin.h"

@implementation MKUserInteractionMixin

+ (void)mixInto:(Class)class
{
    if ([class isSubclassOfClass:UIApplication.class] == NO)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"The MKUserIneractionMixin requires the target class "
                                               "to be a subclass of UIApplication."
                                     userInfo:nil];
    
    [class mixinFrom:self];
}

- (void)swizzleUserInteraction_sendEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(eventDetected:)] == NO ||
        [(id)self.delegate eventDetected:event])
    {
        [self swizzleUserInteraction_sendEvent:event];
    }
}

@end
