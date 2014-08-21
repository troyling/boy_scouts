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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error.." message:@"Unable to connect with the server. Please check your network connection and try again." delegate:nil cancelButtonTitle:@"Dimiss" otherButtonTitles:nil, nil];
    return alert;
}

/**
 * Return a alert view indicating network service is disabled
 */
+ (UIAlertView *)getLocationErrorAlertView:(NSString *)causeStr
{
    NSString *alertMessage = [NSString stringWithFormat:@"You currently have location services disabled for this %@. Please refer to \"Settings\" app to turn on Location Services.", causeStr];
    
    UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                                    message:alertMessage
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
    return servicesDisabledAlert;
}


@end
