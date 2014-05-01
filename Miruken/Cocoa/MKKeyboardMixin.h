//
//  MKKeyboardMixin.h
//  Miruken
//
//  Created by Craig Neuwirt on 5/2/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
  Protocol adopted by targets interested in the keyboard.
 */

@protocol MKKeyboardLifecycle

@optional
- (BOOL)isKeyboardVisible;

- (CGRect)keyboardScreenFrame;

- (void)keyboardWillShowInFrame:(CGRect)endFrame fromFrame:(CGRect)startFrame
              animationDuration:(NSTimeInterval)duration animationCurve:(UIViewAnimationCurve)curve;

- (void)keyboardDidShowInFrame:(CGRect)endFrame fromFrame:(CGRect)startFrame
             animationDuration:(NSTimeInterval)duration animationCurve:(UIViewAnimationCurve)curve;

- (void)keyboardWillHideFromFrame:(CGRect)startFrame toFrame:(CGRect)endFrame
                animationDuration:(NSTimeInterval)duration animationCurve:(UIViewAnimationCurve)curve;

- (void)keyboardDidHideFromFrame:(CGRect)startFrame toFrame:(CGRect)endFrame
               animationDuration:(NSTimeInterval)duration animationCurve:(UIViewAnimationCurve)curve;

- (void)keyboardWillChangeFrame:(CGRect)startFrame toFrame:(CGRect)endFrame
              animationDuration:(NSTimeInterval)duration animationCurve:(UIViewAnimationCurve)curve;

- (void)keyboardDidChangeFrame:(CGRect)startFrame toFrame:(CGRect)endFrame
             animationDuration:(NSTimeInterval)duration animationCurve:(UIViewAnimationCurve)curve;

@end

/**
  This class is an opaque mix-in that exposes the keyboards lifecycle.
  e.g. KeyboardMixin mixInto:MyViewController.class]
 */

@interface MKKeyboardMixin : NSObject <MKKeyboardLifecycle>

@end
