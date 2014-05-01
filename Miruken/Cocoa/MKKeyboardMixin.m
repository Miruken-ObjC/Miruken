//
//  MKKeyboardMixin.m
//  Miruken
//
//  Created by Craig Neuwirt on 5/2/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKKeyboardMixin.h"
#import <objc/runtime.h>

static CGRect keyboardFrame;

@implementation MKKeyboardMixin

+ (void)initialize
{
    if (self == MKKeyboardMixin.class)
    {
        keyboardFrame = CGRectNull;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(Keyboard_keyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(Keyboard_keyboardDidHide:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
    }
}

+ (void)Keyboard_keyboardDidShow:(NSNotification *)notification
{
    keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
}

+ (void)Keyboard_keyboardDidHide:(NSNotification *)notification
{
    keyboardFrame = CGRectNull;
}

- (CGRect)keyboardScreenFrame
{
    return keyboardFrame;
}

- (BOOL)isKeyboardVisible
{
    return ! CGRectIsNull(keyboardFrame);
}

/**
 * alloc calls allocWithZone:nil
 */
+ (id)swizzleDirty_allocWithZone:(NSZone *)zone
{
    id object = [self swizzleDirty_allocWithZone:zone];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    if ([object respondsToSelector:
         @selector(keyboardWillShowInFrame:fromFrame:animationDuration:animationCurve:)])
    {
        [defaultCenter addObserver:object selector:@selector(Keyboard_keyboardWillShow:)
                              name:UIKeyboardWillShowNotification object:nil];
    }
    
    if ([object respondsToSelector:
         @selector(keyboardDidShowInFrame:fromFrame:animationDuration:animationCurve:)])
    {
        [defaultCenter addObserver:object selector:@selector(Keyboard_keyboardDidShow:)
                              name:UIKeyboardDidShowNotification object:nil];
    }
    
    if ([object respondsToSelector:
         @selector(keyboardWillHideFromFrame:toFrame:animationDuration:animationCurve:)])
    {
        [defaultCenter addObserver:object selector:@selector(Keyboard_keyboardWillHide:)
                              name:UIKeyboardWillHideNotification object:nil];
    }
    
    if ([object respondsToSelector:
         @selector(keyboardDidHideFromFrame:toFrame:animationDuration:animationCurve:)])
    {
        [defaultCenter addObserver:object selector:@selector(Keyboard_keyboardDidHide:)
                              name:UIKeyboardDidHideNotification object:nil];
    }
    
    if ([object respondsToSelector:
         @selector(keyboardWillChangeFrame:toFrame:animationDuration:animationCurve:)])
    {
        [defaultCenter addObserver:object selector:@selector(Keyboard_keyboardWillChangeFrame:)
                              name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    
    if ([object respondsToSelector:
         @selector(keyboardDidChangeFrame:toFrame:animationDuration:animationCurve:)])
    {
        [defaultCenter addObserver:object selector:@selector(Keyboard_keyboardDidChangeFrame:)
                              name:UIKeyboardDidChangeFrameNotification object:nil];
    }
    
    return object;
}

- (void)swizzleDirty_dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self swizzleDirty_dealloc];
}

#pragma mark - Keyboard notifications

- (void)Keyboard_keyboardWillShow:(NSNotification *)notification
{
    CGRect               beginFrame, endFrame;
    NSTimeInterval       animationDuration;
    UIViewAnimationCurve animationCurve;
    [self Keyboard_extractNotification:notification beginFrame:&beginFrame endFrame:&endFrame
                     animationDuration:&animationDuration animationCurve:&animationCurve];
    [self keyboardWillShowInFrame:endFrame fromFrame:beginFrame animationDuration:animationDuration
                   animationCurve:animationCurve];
}

- (void)Keyboard_keyboardDidShow:(NSNotification *)notification
{
    CGRect               beginFrame, endFrame;
    NSTimeInterval       animationDuration;
    UIViewAnimationCurve animationCurve;
    [self Keyboard_extractNotification:notification beginFrame:&beginFrame endFrame:&endFrame
                     animationDuration:&animationDuration animationCurve:&animationCurve];
    [self keyboardDidShowInFrame:endFrame fromFrame:beginFrame animationDuration:animationDuration
                  animationCurve:animationCurve];
}

- (void)Keyboard_keyboardWillHide:(NSNotification *)notification
{
    CGRect               beginFrame, endFrame;
    NSTimeInterval       animationDuration;
    UIViewAnimationCurve animationCurve;
    [self Keyboard_extractNotification:notification beginFrame:&beginFrame endFrame:&endFrame
                     animationDuration:&animationDuration animationCurve:&animationCurve];
    [self keyboardWillHideFromFrame:beginFrame toFrame:endFrame animationDuration:animationDuration
                     animationCurve:animationCurve];
}

- (void)Keyboard_keyboardDidHide:(NSNotification *)notification
{
    CGRect               beginFrame, endFrame;
    NSTimeInterval       animationDuration;
    UIViewAnimationCurve animationCurve;
    [self Keyboard_extractNotification:notification beginFrame:&beginFrame endFrame:&endFrame
                     animationDuration:&animationDuration animationCurve:&animationCurve];
    [self keyboardDidHideFromFrame:beginFrame toFrame:endFrame animationDuration:animationDuration
                    animationCurve:animationCurve];
}

- (void)Keyboard_keyboardWillChangeFrame:(NSNotification *)notification
{
    CGRect               beginFrame, endFrame;
    NSTimeInterval       animationDuration;
    UIViewAnimationCurve animationCurve;
    [self Keyboard_extractNotification:notification beginFrame:&beginFrame endFrame:&endFrame
                     animationDuration:&animationDuration animationCurve:&animationCurve];
    [self keyboardWillChangeFrame:beginFrame toFrame:endFrame animationDuration:animationDuration
                   animationCurve:animationCurve];
}

- (void)Keyboard_keyboardDidChangeFrame:(NSNotification *)notification
{
    CGRect               beginFrame, endFrame;
    NSTimeInterval       animationDuration;
    UIViewAnimationCurve animationCurve;
    [self Keyboard_extractNotification:notification beginFrame:&beginFrame endFrame:&endFrame
                     animationDuration:&animationDuration animationCurve:&animationCurve];
    [self keyboardDidChangeFrame:beginFrame toFrame:endFrame animationDuration:animationDuration
                  animationCurve:animationCurve];
}

- (void)Keyboard_extractNotification:(NSNotification *)notification
                          beginFrame:(CGRect *)beginFrame endFrame:(CGRect *)endFrame
                   animationDuration:(NSTimeInterval *)duration animationCurve:(UIViewAnimationCurve *)curve
{
    NSDictionary *info = notification.userInfo;
    *beginFrame        = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    *endFrame          = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    *duration          = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    *curve             = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
}

@end
