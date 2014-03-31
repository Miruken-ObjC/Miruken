//
//  MKModalPresentationScope.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKModalPresentationScope.h"

@implementation MKModalPresentationScope

+ (instancetype)for:(MKCallbackHandler *)handler
{
    MKModalPresentationScope *scope = [super for:handler];
    scope.presentationPolicy        = [MKPresentationPolicy new];
    scope.presentationPolicy.modal  = YES;
    return scope;
}

#pragma mark - UIModalPresentationStyle

- (instancetype)fullScreen
{
    return [self presentationStyle:UIModalPresentationFullScreen];
}

- (instancetype)pageSheet
{
    return [self presentationStyle:UIModalPresentationPageSheet];
}

- (instancetype)formSheet
{
    return [self presentationStyle:UIModalPresentationFormSheet];
}

- (instancetype)currentContext
{
    return [self presentationStyle:UIModalPresentationFormSheet];
}

- (instancetype)presentationStyle:(UIModalPresentationStyle)presentationStyle
{
    self.presentationPolicy.modalPresentationStyle = presentationStyle;
    return self;
}

#pragma mark - UIModalTransitionStyle

- (instancetype)coverVertical
{
    return [self transitionStyle:UIModalTransitionStyleCoverVertical];
}

- (instancetype)flipHorizontal
{
    return [self transitionStyle:UIModalTransitionStyleFlipHorizontal];
}

- (instancetype)crossDissolve
{
    return [self transitionStyle:UIModalTransitionStyleCrossDissolve];
}

- (instancetype)partialCurl
{
    return [self transitionStyle:UIModalTransitionStylePartialCurl];
}

- (instancetype)transitionStyle:(UIModalTransitionStyle)transitionStyle
{
    self.presentationPolicy.modalTransitionStyle = transitionStyle;
    return self;
}

- (instancetype)definesPresentationContext
{
    self.presentationPolicy.definesPresentationContext = YES;
    return self;
}

- (instancetype)providesPresentationContextTransition
{
    self.presentationPolicy.providesPresentationContextTransitionStyle = YES;
    return self;
}

@end
