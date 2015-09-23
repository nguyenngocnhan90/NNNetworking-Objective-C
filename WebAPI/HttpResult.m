 //
//  HttpResult.m
//  RESTFULClient
//
//  Created by Nhan Nguyen on 8/11/14.
//  Copyright (c) 2014 Nhan Nguyen. All rights reserved.
//

#import "HttpResult.h"
#import "JsonSerializable.h"

@implementation HttpResult

- (id)initWithRequestOperation:(AFHTTPRequestOperation *)requestOperation
{
    self = [super init];
    if (self) {
        self.requestOperation = requestOperation;
    }
    
    return self;
}

- (BOOL)isSuccess
{
    return self.requestOperation.response.statusCode == 200;
}

- (id)parse:(Class)class
{
    if (self.requestOperation.responseObject) {
        return [self parseFromDictionary:self.requestOperation.responseObject class:class];
    }
    
    return nil;
}

- (id)parseFromDictionary:(NSDictionary *)dictionary class:(Class)class
{
    JsonSerializable *obj = nil;
    if ([class isSubclassOfClass:[JsonSerializable class]]) {
        NSError *error = nil;
        obj = [[class alloc] initWithDictionary:dictionary error:&error];
        
        if (error) {
            NSLog(@"Parse json failed: %@", error);
        }
    }
    
    return obj;
}

- (BOOL)toBoolean
{
    NSString *responeString = [self toString];
    if (responeString) {
        [[responeString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        
        return [responeString isEqualToString:@"true"] || [responeString isEqualToString:@"1"];
    }
    
    return NO;
}

- (NSString *)toString
{
    return self.requestOperation.responseString;
}

- (NSInteger)toInteger
{
    return [[self toString] integerValue];
}

- (CGFloat)toFloat
{
    return [[self toString] floatValue];
}

- (NSNumber *)toNumber
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    return [formatter numberFromString:[self toString]];
}

- (NSArray *)toArray:(Class)class
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSDictionary *json in self.requestOperation.responseObject) {
        JsonSerializable *model = [self parseFromDictionary:json class:class];
        if (model) {
            [result addObject:model];
        }
    }
    
    return result;
}

- (NSDictionary *)toDictionary
{
    return self.requestOperation.responseObject;
}

@end
