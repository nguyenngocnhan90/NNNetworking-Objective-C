//
//  MultiPart.h
//  RESTFULClient
//
//  Created by Nhan Nguyen on 8/12/14.
//  Copyright (c) 2014 Nhan Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JsonSerializable.h"

@interface MultiPart : NSObject

@property (strong, nonatomic) NSString *contentType;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSData *data;

- (id)initWithName:(NSString *)name contentType:(NSString *)contentType andData:(NSData *)data;
- (NSMutableDictionary *)getHeaders;

@end

//////////////////////////////////////////////////

@interface JsonPart : MultiPart

@property (strong, nonatomic) JsonSerializable *model;

- (id)initWithName:(NSString *)name andJsonModel:(JsonSerializable *)model;

@end

//////////////////////////////////////////////////

@interface StringPart : MultiPart

- (id)initWithName:(NSString *)name andString:(NSString *)string;

@end

//////////////////////////////////////////////////

@interface ArrayPart : MultiPart

- (id)initWithName:(NSString *)name andArray:(NSArray *)array;

@end

//////////////////////////////////////////////////

@interface FilePart : MultiPart

@property (strong, nonatomic) NSString *fileName;

- (id)initWithName:(NSString *)name fileName:(NSString *)fileName andData:(NSData *)data;

@end
