//
//  BaseInvoker.h
//  AGSCore
//
//  Created by Nhan Nguyen on 9/17/14.
//  Copyright (c) 2014 Nhan Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestInvoker.h"
#import "ServiceError.h"

@interface BaseInvoker : NSObject

- (id)initWithControllerName:(NSString *)controllerName;
- (RequestInvoker *)createRequestInvokerWithMethodName:(NSString *)methodName requestMethod:(RequestMethod)requestMethod;
- (ServiceError *)handleError:(AFHTTPRequestOperation *)operation;

@end
