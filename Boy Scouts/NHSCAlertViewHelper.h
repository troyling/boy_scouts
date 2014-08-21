//
//  NHSCAlertViewHelper.h
//  Boy Scouts
//
//  Created by Troy Ling on 8/21/14.
//  Copyright (c) 2014 Daniel Webster Council Boy Scouts of America. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NHSCAlertViewHelper : NSObject

+ (UIAlertView *)getNetworkErrorAlertView;
+ (UIAlertView *)getLocationErrorAlertView:(NSString *)causeStr;

@end
