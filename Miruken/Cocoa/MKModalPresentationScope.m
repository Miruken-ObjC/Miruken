//
//  MKModalPresentationScope.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKModalPresentationScope.h"

@implementation MKModalPresentationScope
{
    MKPresentationPolicy *_presentationPolicy;
}

+ (instancetype)for:(MKCallbackHandler *)handler
{
    MKModalPresentationScope *scope  = [[self alloc] initWithDecoratee:handler];
    scope->_presentationPolicy       = [MKPresentationPolicy new];
    scope->_presentationPolicy.modal = YES;
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
    _presentationPolicy.modalPresentationStyle = presentationStyle;
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
    _presentationPolicy.modalTransitionStyle = transitionStyle;
    return self;
}

- (instancetype)definesPresentationContext
{
    _presentationPolicy.definesPresentationContext = YES;
    return self;
}

- (instancetype)providesPresentationContextTransition
{
    _presentationPolicy.providesPresentationContextTransitionStyle = YES;
    return self;
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
{
    if ([callback isKindOfClass:MKPresentationPolicy.class])
    {
        [_presentationPolicy mergeIntoPolicy:callback];
        return YES;
    }
    return [super handle:callback greedy:greedy composition:composer];
}

@end
