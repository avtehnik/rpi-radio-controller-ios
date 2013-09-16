//
//  RCStation.h
//  Radio controller
//
//  Created by av_tehnik on 9/15/13.
//  Copyright (c) 2013 vitaliy pitvalo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCStation : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *frequency;
@property (strong, nonatomic) NSString *type;

@end
