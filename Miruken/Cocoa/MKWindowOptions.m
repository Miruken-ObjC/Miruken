//
//  MKWindowOptions.m
//  Miruken
//
//  Created by Craig Neuwirt on 6/14/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKWindowOptions.h"

@implementation MKWindowOptions
{
    MKWindowOptionsSpecified _specified;
}

- (void)setWindowRoot:(BOOL)windowRoot
{
    _windowRoot           = windowRoot;
    _specified.windowRoot = YES;
}

- (void)setNewWindow:(BOOL)newWindow
{
    _newWindow           = newWindow;
    _specified.newWindow = YES;
}

- (void)setWindowLevel:(UIWindowLevel)windowLevel
{
    _windowLevel           = windowLevel;
    _specified.windowLevel = YES;
}

- (MKWindowOptionsSpecified)specified
{
    return _specified;
}

- (void)mergeIntoOptions:(id<MKPresentationOptions>)otherOptions
{
    if ([otherOptions isKindOfClass:self.class] == NO)
        return;
    
    MKWindowOptions *windowOptions = otherOptions;
    
    if (_specified.windowRoot && (windowOptions->_specified.windowRoot == NO))
        windowOptions.windowRoot = _windowRoot;
    
    if (_specified.newWindow && (windowOptions->_specified.newWindow == NO))
        windowOptions.newWindow = _newWindow;
    
    if (_specified.windowLevel && (windowOptions->_specified.windowLevel == NO))
        windowOptions.windowLevel = _windowLevel;
}

@end
