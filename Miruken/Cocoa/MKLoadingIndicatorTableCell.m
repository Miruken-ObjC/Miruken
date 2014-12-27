//
//  MKLoadingIndicatorTableCell.m
//  Miruken
//
//  Created by Craig Neuwirt on 11/1/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKLoadingIndicatorTableCell.h"

@implementation MKLoadingIndicatorTableCell

{
    __weak IBOutlet UILabel                 *_loadingLabel;
    __weak IBOutlet UIActivityIndicatorView *_activityIndicator;
    __weak IBOutlet UIView                  *_separator;
    __weak IBOutlet NSLayoutConstraint      *_heightConstraint;
    __weak IBOutlet NSLayoutConstraint      *_separatorLeftInsetConstraint;
}

- (void)awakeFromNib
{
    _heightConstraint.constant = 1.0 / [UIScreen mainScreen].scale;
}

- (NSString *)loadingMessage
{
    return _loadingLabel.text;
}

- (void)setLoadingMessage:(NSString *)loadingMessage
{
    _loadingLabel.text = loadingMessage;
}

- (void)setSeparatorInset:(UIEdgeInsets)separatorInset
{
    [super setSeparatorInset:separatorInset];
    
    _separatorLeftInsetConstraint.constant = separatorInset.left;
    [self setNeedsUpdateConstraints];
}

- (void)start
{
    [_activityIndicator startAnimating];
}

- (void)stop
{
    [_activityIndicator stopAnimating];
}

//- (void)willTransitionToState:(UITableViewCellStateMask)state
//{
//    [super willTransitionToState:state];
//    
//    CGFloat leftInset = self.tableView.separatorInset.left;
//    if ((state & UITableViewCellStateShowingEditControlMask))
//        leftInset += 38.0;
//    self.separatorInset = UIEdgeInsetsMake(0.0, leftInset, 0.0, 0.0);
//}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self stop];
}

@end
