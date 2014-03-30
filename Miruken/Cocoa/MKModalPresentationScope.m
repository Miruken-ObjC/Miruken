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
    return [[self alloc] initWithDecoratee:handler];
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
    if (_presentationPolicy == nil)
        _presentationPolicy = [MKPresentationPolicy new];
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
    if (_presentationPolicy == nil)
        _presentationPolicy = [MKPresentationPolicy new];
    _presentationPolicy.modalTransitionStyle = transitionStyle;
    return self;
}

- (instancetype)definesPresentationContext
{
    if (_presentationPolicy == nil)
        _presentationPolicy = [MKPresentationPolicy new];
    _presentationPolicy.definesPresentationContext = YES;
    return self;
}

- (instancetype)providesPresentationContextTransition
{
    if (_presentationPolicy == nil)
        _presentationPolicy = [MKPresentationPolicy new];
    _presentationPolicy.providesPresentationContextTransitionStyle = YES;
    return self;
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
{
    if (_presentationPolicy && [callback isKindOfClass:MKPresentationPolicy.class])
    {
        [_presentationPolicy mergeIntoPolicy:callback];
        return YES;
    }
    return [self.decoratee handle:callback greedy:greedy];
}

@end
