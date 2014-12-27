//
//  MKLoadingIndicatorTableCell.h
//  Miruken
//
//  Created by Craig Neuwirt on 11/1/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKStarting.h"

@interface MKLoadingIndicatorTableCell : UITableViewCell <MKStarting>

@property (copy, nonatomic) NSString *loadingMessage;

@end
