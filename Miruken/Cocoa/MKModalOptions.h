//
//  MKModalOptions.h
//  Miruken
//
//  Created by Craig Neuwirt on 5/25/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPresentationOptions.h"

@interface MKModalOptions : MKPresentationOptions

@property (assign, nonatomic) UIModalTransitionStyle   modalTransitionStyle;
@property (assign, nonatomic) UIModalPresentationStyle modalPresentationStyle;
@property (assign, nonatomic) BOOL                     definesPresentationContext;
@property (assign, nonatomic) BOOL                     providesPresentationContextTransitionStyle;

@end
