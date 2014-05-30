//
//  MKModalScope.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKModalScope.h"
#import "MKModalOptions.h"

@implementation MKModalScope

+ (instancetype)for:(MKCallbackHandler *)handler
{
    MKModalScope *scope = [super for:handler];
    [[scope requirePresentationPolicy] addOrMergeOptions:[MKModalOptions new]];
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
    MKModalOptions *modalOptions = [MKModalOptions new];
    modalOptions.modalPresentationStyle = presentationStyle;
    [[self requirePresentationPolicy] addOrMergeOptions:modalOptions];
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
    MKModalOptions *modalOptions = [MKModalOptions new];
    modalOptions.modalTransitionStyle = transitionStyle;
    [[self requirePresentationPolicy] addOrMergeOptions:modalOptions];
    return self;
}

- (instancetype)definesPresentationContext
{
    MKModalOptions *modalOptions = [MKModalOptions new];
    modalOptions.definesPresentationContext = YES;
    [[self requirePresentationPolicy] addOrMergeOptions:modalOptions];
    return self;
}

- (instancetype)providesPresentationContextTransition
{
    MKModalOptions *modalOptions = [MKModalOptions new];
    modalOptions.providesPresentationContextTransitionStyle = YES;
    [[self requirePresentationPolicy] addOrMergeOptions:modalOptions];
    return self;
}

@end
