//
//  ServiceError.m
//  TuoiThoDuDoi
//
//  Created by Nhan Nguyen on 11/13/14.
//  Copyright (c) 2014 Nhan Nguyen. All rights reserved.
//

#import "ServiceError.h"

@implementation ServiceError

- (id)initWithErrorCode:(NSString *)errorCode
{
    self = [super init];
    if (self) {
        self.errorMessage = ERROR_MESSAGE(errorCode);
    }
    
    return self;
}

@end
