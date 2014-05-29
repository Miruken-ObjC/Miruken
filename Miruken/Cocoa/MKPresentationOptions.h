//
//  MKPresentationOptions.h
//  Miruken
//
//  Created by Craig Neuwirt on 5/25/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MKPresentationOptions <NSObject>

- (void)applyPolicyToViewController:(UIViewController *)viewController;

- (void)mergeIntoOptions:(id<MKPresentationOptions>)otherOptions;

@end

@interface MKPresentationOptions : NSObject <MKPresentationOptions>

@end
