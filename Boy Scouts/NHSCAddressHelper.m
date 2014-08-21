//
//  NHSCAddressHelper.m
//  Boy Scouts
//
//  Created by Troy Ling on 5/17/14.
//  Copyright (c) 2014 Daniel Webster Council Boy Scouts of America. All rights reserved.
//

#import "NHSCAddressHelper.h"
#import "NHSCAlertViewHelper.h"

@implementation NHSCAddressHelper


/*
 * get the address from location
 */
+(NSString *)getAddressFromLatLon:(double)pdblLatitude withLongitude:(double)pdblLongitude
{
    NSString *address = nil;
    NSError* error;
    
    // retrieve the name for the location
    // ****************************** This URL is for the Google Map API *******************************
    // For future application, please use official api key
    NSString *urlString = [NSString stringWithFormat: @"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true", pdblLatitude, pdblLongitude];
    NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSASCIIStringEncoding error:&error];
    
    if (error){
        // network is not available
        [[NHSCAlertViewHelper getNetworkErrorAlertView] show];
        
    } else {
        // parse jason object
        NSData *data = [locationString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        address = [[json objectForKey:@"results"] valueForKey:@"formatted_address"][0];
    }
    
    return address;
}

@end
