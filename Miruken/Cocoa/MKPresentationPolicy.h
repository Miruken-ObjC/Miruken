//
//  MKPresentationPolicy.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/22/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKPresentationPolicy : NSObject <NSCopying>

@property (assign, nonatomic) BOOL                     modal;
@property (assign, nonatomic) UIModalTransitionStyle   modalTransitionStyle;
@property (assign, nonatomic) UIModalPresentationStyle modalPresentationStyle;
@property (assign, nonatomic) BOOL                     definesPresentationContext;
@property (assign, nonatomic) BOOL                     providesPresentationContextTransitionStyle;

- (void)applyToViewController:(UIViewController *)viewController;

- (void)mergeIntoPolicy:(MKPresentationPolicy *)otherPolicy;

@end
