//
//  UIAlertView+Block.m
//  Miruken
//
//  Created by Craig Neuwirt on 2/11/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "UIAlertView+Block.h"
#import "MKAlertViewMixin.h"
#import "MKMixingIn.h"

@interface MKAlertViewDelegate : NSObject <UIAlertViewDelegate, MKAlertViewDelegate>

@property (strong, atomic) MKAlertViewBlock block;

+ (void)show:(UIAlertView *)alertView withBlock:(MKAlertViewBlock)block;

@end


@implementation UIAlertView (UIAlertView_Block)

- (void)showUsingBlock:(MKAlertViewBlock)block
{
    [MKAlertViewDelegate show:self withBlock:block];
}

@end


@implementation MKAlertViewDelegate

+ (void)initialize
{
    if (self == MKAlertViewDelegate.class)
        [MKAlertViewMixin mixInto:self];
}

+ (void)show:(UIAlertView *)alertView withBlock:(MKAlertViewBlock)block
{
    __block MKAlertViewDelegate *delegate = [MKAlertViewDelegate new];
    
    alertView.delegate = delegate;
    delegate.block     = ^(NSInteger buttonIndex) {
        if (block)
            block(buttonIndex);
        alertView.delegate = nil;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        delegate           = nil;
#pragma clang diagnostic pop
    };
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.alertView = nil;
    
    if (_block)
        _block(buttonIndex);
}

@end
