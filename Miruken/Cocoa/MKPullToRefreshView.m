//
//  MKPullToRefreshView.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/26/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPullToRefreshView.h"
#import "UIImage+Helpers.h"

@implementation MKPullToRefreshView
{
    MKPullToRefreshMode               _mode;
    CGFloat                           _pullPercent;
    __weak UILabel                   *_refreshLabel;
    __weak UIActivityIndicatorView   *_refreshingIndicator;
    __weak UIImageView               *_leftArrow;
    __weak UIImageView               *_rightArrow;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
        [self initialize];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
        [self initialize];
    return self;
}

- (void)initialize
{
    self.backgroundColor          = [UIColor clearColor];
    UILabel     *refreshLabel     = [[UILabel alloc] initWithFrame:CGRectZero];
    [refreshLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    refreshLabel.font             = [UIFont boldSystemFontOfSize:15.0];
    refreshLabel.textColor        = [UIColor colorWithRed:(105.0/255.0)
                                                    green:(112.0/255.0)
                                                     blue:(123.0/255.0)
                                                    alpha:1.0];
    refreshLabel.backgroundColor  = [UIColor clearColor];
    refreshLabel.textAlignment    = NSTextAlignmentCenter;
    [refreshLabel sizeToFit];
    _refreshLabel                 = refreshLabel;
    [self addSubview:_refreshLabel];
    
    UIImage     *pullToRefreshImg = [[UIImage imageNamed:@"pull_to_refresh"] scaledToHeight:40.0];
    UIImageView *leftArrow        = [[UIImageView alloc] initWithImage:pullToRefreshImg];
    leftArrow.contentMode         = UIViewContentModeScaleAspectFit;
    [leftArrow setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:leftArrow];
    _leftArrow                    = leftArrow;
    UIImageView *rightArrow       = [[UIImageView alloc] initWithImage:pullToRefreshImg];
    rightArrow.contentMode        = UIViewContentModeScaleAspectFit;
    [rightArrow setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:rightArrow];
    _rightArrow                   = rightArrow;
    
    UIActivityIndicatorView *refreshingIndicator = [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [refreshingIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    _refreshingIndicator         = refreshingIndicator;
    [self addSubview:_refreshingIndicator];
    
    self.mode = MKPullToRefreshModePull;
}

- (MKPullToRefreshMode)mode
{
    return _mode;
}

- (void)setMode:(MKPullToRefreshMode)mode
{
    CGFloat arrowAngle = 0.0;
    
    switch (_mode = mode)
    {
        case MKPullToRefreshModePull:
            _refreshLabel.text    = @"Pull to Refresh";
            _refreshLabel.hidden  = NO;
            arrowAngle            = M_PI * 2;
            [_refreshingIndicator stopAnimating];
            break;
            
        case MKPullToRefreshModeRelease:
            _refreshLabel.text   = @"Release to Refresh";
            _refreshLabel.hidden = NO;
            arrowAngle           = M_PI;
            [_refreshingIndicator stopAnimating];
            break;
            
        case MKPullToRefreshModeRefreshing:
            _refreshLabel.hidden = YES;
            self.transform       = CGAffineTransformIdentity;
            self.alpha           = 1.0;
            [_refreshingIndicator startAnimating];
            break;
    }
    
    [_refreshLabel sizeToFit];
    _leftArrow.hidden  = _refreshLabel.hidden;
    _rightArrow.hidden = _refreshLabel.hidden;
    
    if (arrowAngle != 0.0)
        [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
            _leftArrow.layer.transform  = CATransform3DMakeRotation(-arrowAngle, 0, 0, 1);
            _rightArrow.layer.transform = CATransform3DMakeRotation(arrowAngle, 0, 0, 1);
        } completion:NULL];
}

- (CGFloat)pullPercent
{
    return _pullPercent;
}

- (void)setPullPercent:(CGFloat)pullPercent
{
    _pullPercent = pullPercent;
    if (pullPercent == 0.0)
    {
        self.transform = CGAffineTransformIdentity;
        self.alpha     = 1.0;
    }
    else
    {
        self.transform = CGAffineTransformMakeScale(pullPercent, pullPercent);
        self.alpha     = pullPercent;
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    size = [_refreshLabel intrinsicContentSize];
    size.height += 40.0;
    return size;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _refreshLabel.center = ({
        CGPoint center = _refreshLabel.center;
        center.x       = CGRectGetWidth(self.bounds) / 2.0;
        center.y       = CGRectGetHeight(self.bounds) / 2.0;
        center;
    });
    _refreshingIndicator.center = _refreshLabel.center;
    
    _leftArrow.center = ({
        CGPoint center = _refreshLabel.center;
        center.x       = CGRectGetMinX(_refreshLabel.frame) - 20.0;
        center;
    });
    
    _rightArrow.center = ({
        CGPoint center = _refreshLabel.center;
        center.x       = CGRectGetMaxX(_refreshLabel.frame) + 20.0;
        center;
    });
}

@end
