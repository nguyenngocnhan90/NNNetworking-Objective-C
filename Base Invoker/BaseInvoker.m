//
//  AGSBaseService.m
//  AGSCore
//
//  Created by Nhan Nguyen on 9/17/14.
//  Copyright (c) 2014 Nhan Nguyen. All rights reserved.
//

#import "BaseInvoker.h"

@interface BaseInvoker()

@property (strong, nonatomic) NSString *baseUrlApi;

@end

@implementation BaseInvoker

- (id)initWithControllerName:(NSString *)controllerName
{
    self = [super init];
    if (self) {
        self.baseUrlApi = [NSString stringWithFormat:@"%@%@", self.baseUrlApi, controllerName];
    }
    
    return self;
}

- (NSString *)baseUrlApi
{
    if (!_baseUrlApi) {
        _baseUrlApi = WEBSERVICE_API_URL;
    }
    
    return _baseUrlApi;
}

- (RequestInvoker *)createRequestInvokerWithMethodName:(NSString *)methodName requestMethod:(RequestMethod)requestMethod
{
    NSString *url = [NSString stringWithFormat:@"%@/%@", self.baseUrlApi, methodName];
    RequestInvoker *requestInvoker = [RequestInvoker requestInvokerWithUrl:url requestMethod:requestMethod];
    [requestInvoker setContentType:@"application/json; charset=UTF-8"];

    return requestInvoker;
}

- (ServiceError *)handleError:(AFHTTPRequestOperation *)operation
{
    NSString *errorCode = @"DEFAULT_ERROR_CODE";
    if (![AGSNetworking isHavingNetworkConnection]) {
        errorCode = @"NO_CONNECTION";
    }
    
    if (operation.response.statusCode < 500 && operation.responseString) {
        errorCode = operation.responseString;
    }
    
    if ([operation.responseString isEqualToString:@"AUTHORIZATION_ACCESS_DENIED"]) {
        errorCode = @"Username or Password incorrect";
    }
    
    if ([operation.responseObject valueForKeyPath:@"errorCode"]) {
        errorCode = [operation.responseObject valueForKeyPath:@"errorCode"];
    }
    
    ServiceError *serviceError = [[ServiceError alloc] initWithErrorCode:errorCode];
    return serviceError;
}

@end
