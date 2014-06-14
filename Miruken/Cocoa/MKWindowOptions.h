//
//  MKWindowOptions.h
//  Miruken
//
//  Created by Craig Neuwirt on 6/14/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPresentationOptions.h"

@interface MKWindowOptions : MKPresentationOptions

typedef struct
{
    unsigned int windowRoot:1;
    unsigned int newWindow:1;
    unsigned int windowLevel:1;
} MKWindowOptionsSpecified;

@property (assign,   nonatomic)  BOOL                     windowRoot;
@property (assign,   nonatomic)  BOOL                     newWindow;
@property (assign,   nonatomic)  UIWindowLevel            windowLevel;
@property (readonly, nonatomic)  MKWindowOptionsSpecified specified;

@end
