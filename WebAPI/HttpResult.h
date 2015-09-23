//
//  HttpResult.h
//  RESTFULClient
//
//  Created by Nhan Nguyen on 8/11/14.
//  Copyright (c) 2014 Nhan Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"

@interface HttpResult : NSObject

@property (strong, nonatomic) AFHTTPRequestOperation *requestOperation;

// methods

- (id)initWithRequestOperation:(AFHTTPRequestOperation *)requestOperation;
- (id)parseFromDictionary:(NSDictionary *)dictionary class:(Class)class;

- (BOOL)isSuccess;

- (id)parse:(Class)class;
- (BOOL)toBoolean;
- (NSString *)toString;
- (NSInteger)toInteger;
- (CGFloat)toFloat;
- (NSNumber *)toNumber;
- (NSArray *)toArray:(Class)class;
- (NSDictionary *)toDictionary;

@end
