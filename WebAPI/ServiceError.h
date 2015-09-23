//
//  ServiceError.h
//  TuoiThoDuDoi
//
//  Created by Nhan Nguyen on 11/13/14.
//  Copyright (c) 2014 Nhan Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceError : NSError

@property (strong, nonatomic) NSString *errorMessage;

- (id)initWithErrorCode:(NSString *)errorCode;

@end
