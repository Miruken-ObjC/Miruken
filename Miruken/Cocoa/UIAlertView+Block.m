//
//  UIAlertView+Block.m
//  Miruken
//
//  Created by Craig Neuwirt on 2/11/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "UIAlertView+Block.h"

@interface MKAlertViewDelegate : NSObject<UIAlertViewDelegate>

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
    if (_block)
        _block(buttonIndex);
}

@end
