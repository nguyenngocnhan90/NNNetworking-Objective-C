//
//  RequestInvoker.h
//  RESTFULClient
//
//  Created by Nhan Nguyen on 8/11/14.
//  Copyright (c) 2014 Nhan Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JsonSerializable.h"
#import "HttpResult.h"

typedef enum {
	GET,
	POST,
	PUT,
	DELETE
} RequestMethod;

@interface RequestInvoker : NSObject

- (void)addParameter:(NSString *)parameter withIntegerValue:(NSInteger)value;
- (void)addParameter:(NSString *)parameter withNSNumberValue:(NSNumber *)value;
- (void)addParameter:(NSString *)parameter withBooleanValue:(BOOL)value;
- (void)addParameter:(NSString *)parameter withStringValue:(NSString *)value;
- (void)addParameter:(NSString *)parameter withArray:(NSArray *)array;

- (void)addHeader:(NSString *)key withValue:(NSString *)value;
- (void)setContentType:(NSString *)contentType;
- (void)setAccept:(NSString *)accept;
- (void)setAuthorization:(NSString *)authorization;

- (void)addPartJson:(JsonSerializable *)model name:(NSString *)name;
- (void)addPartFile:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName;
- (void)addPartString:(NSString *)string name:(NSString *)name;
- (void)addPartArray:(NSArray *)array name:(NSString *)name;

- (void)setObjectBody:(JsonSerializable *)objectBody;
- (void)setArrayBody:(NSArray *)arrayBody;

- (void)invokeWithSuccess:(void (^)(HttpResult *httpResult))success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (RequestInvoker *)requestInvokerWithUrl:(NSString *)url requestMethod:(RequestMethod)requestMethod;

@end
