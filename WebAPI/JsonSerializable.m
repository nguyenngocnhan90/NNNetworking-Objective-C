//
//  JsonSerializable.m
//  RESTFULClient
//
//  Created by Nhan Nguyen on 8/11/14.
//  Copyright (c) 2014 Nhan Nguyen. All rights reserved.
//

#import "JsonSerializable.h"

@implementation JsonSerializable

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *map = [self customMapping];
    if (map) {
        return [[JSONKeyMapper alloc] initWithDictionary:map];
    }
    
    return [super keyMapper];
}

+ (NSMutableDictionary *)customMapping
{
    // abstract method
    
    return nil;
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end
