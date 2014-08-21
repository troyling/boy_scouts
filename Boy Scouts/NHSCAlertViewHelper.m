//
//  NHSCAlertViewHelper.m
//  Boy Scouts
//
//  Created by Troy Ling on 8/21/14.
//  Copyright (c) 2014 Daniel Webster Council Boy Scouts of America. All rights reserved.
//

#import "NHSCAlertViewHelper.h"

@implementation NHSCAlertViewHelper


/**
 * Return a alert view indicating network problem
 */
+ (UIAlertView *)getNetworkErrorAlertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error.." message:@"Unable to connect to server. Please check your network connection and try it again." delegate:nil cancelButtonTitle:@"Dimiss" otherButtonTitles:nil, nil];
    return alert;
}


@end
