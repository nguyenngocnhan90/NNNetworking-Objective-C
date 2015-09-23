
//
//  RequestInvoker.m
//  RESTFULClient
//
//  Created by Nhan Nguyen on 8/11/14.
//  Copyright (c) 2014 Nhan Nguyen. All rights reserved.
//

#import "RequestInvoker.h"
#import "MultiPart.h"

#define RequestMethodName(medthod) [@[@"GET",@"POST",@"PUT", @"DELETE"] objectAtIndex:medthod]

@interface RequestInvoker()

@property (strong, nonatomic) NSString *parameterString;

@property (strong, nonatomic) NSMutableDictionary *parameters;
@property (strong, nonatomic) NSMutableDictionary *headers;
@property (strong, nonatomic) NSMutableArray *multiparts;
@property (strong, nonatomic) JsonSerializable *objectBody;
@property (strong, nonatomic) NSArray *arrayBody;

@property (nonatomic) RequestMethod requestMethod;

@property (strong, nonatomic) NSString *baseUrl;

#define REQUEST_TIMEOUT 120

@end

@implementation RequestInvoker

#pragma mark - Init

- (id)initWithUrl:(NSString *)url requestMethod:(RequestMethod)requestMethod
{
    self = [super init];
    if (self) {
        self.baseUrl = url;
        self.requestMethod = requestMethod;
    }
    
    return self;
}

#pragma mark - Constructors

- (NSMutableDictionary *)headers
{
    if (!_headers) {
        _headers = [[NSMutableDictionary alloc] init];
    }
    
    return _headers;
}

- (NSMutableDictionary *)parameters
{
    if (!_parameters) {
        _parameters = [[NSMutableDictionary alloc] init];
    }
    
    return _parameters;
}

- (NSMutableArray *)multiparts
{
    if (!_multiparts) {
        _multiparts = [[NSMutableArray alloc] init];
    }
    
    return _multiparts;
}

#pragma mark - Add parameters

- (void)addParameter:(NSString *)parameter withIntegerValue:(NSInteger)value
{
    [self addParameter:parameter withStringValue:[NSString stringWithFormat:@"%ld", (long)value]];
}

- (void)addParameter:(NSString *)parameter withNSNumberValue:(NSNumber *)value
{
    [self addParameter:parameter withStringValue:[NSString stringWithFormat:@"%@", value]];
}

- (void)addParameter:(NSString *)parameter withBooleanValue:(BOOL)value
{
    [self addParameter:parameter withStringValue:[NSString stringWithFormat:@"%@", (value ? @"true" : @"false")]];
}

- (void)addParameter:(NSString *)parameter withStringValue:(NSString *)value
{
    [self.parameters setObject:value forKey:parameter];
}

- (void)addParameter:(NSString *)parameter withArray:(NSArray *)array
{
    if (array && array.count > 0) {
        NSString *stringValues = [NSString stringWithFormat:@"%@",
                               [array firstObject]];
        
        if (array.count > 1) {
            for (NSInteger idx = 1; idx < array.count; ++idx) {
                stringValues = [stringValues stringByAppendingString:[NSString stringWithFormat:@",%@", [array objectAtIndex:idx]]];
            }
        }
        
        [self addParameter:parameter withStringValue:stringValues];
    }
}

#pragma mark - Add headers

- (void)addHeader:(NSString *)key withValue:(NSString *)value
{
    if (key && value) {
        [self.headers setObject:value forKey:key];
    }
}

- (void)setContentType:(NSString *)contentType
{
    [self addHeader:@"Content-Type" withValue:contentType];
}

- (void)setAccept:(NSString *)accept
{
    [self addHeader:@"Accept" withValue:accept];
}

- (void)setAuthorization:(NSString *)authorization
{
    if (authorization && ![authorization isEqualToString:@""]) {
        [self addHeader:@"Authorization" withValue:authorization];
    }
}

#pragma mark - Add multipart

- (void)addPartJson:(JsonSerializable *)model name:(NSString *)name
{
    MultiPart *part = [[JsonPart alloc] initWithName:name andJsonModel:model];
    if (part) {
        [self.multiparts addObject:part];
    }
}

- (void)addPartFile:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName
{
    MultiPart *part = [[FilePart alloc] initWithName:name fileName:fileName andData:data];
    if (part) {
        [self.multiparts addObject:part];
    }
}

- (void)addPartString:(NSString *)string name:(NSString *)name
{
    MultiPart *part = [[StringPart alloc] initWithName:name andString:string];
    if (part) {
        [self.multiparts addObject:part];
    }
}

- (void)addPartArray:(NSArray *)array name:(NSString *)name
{
    MultiPart *part = [[ArrayPart alloc] initWithName:name andArray:array];
    if (part) {
        [self.multiparts addObject:part];
    }
}

#pragma mark - Set object body

- (void)setObjectBody:(JsonSerializable *)objectBody
{
    _objectBody = objectBody;
}

- (void)setArrayBody:(NSArray *)arrayBody
{
    _arrayBody = arrayBody;
}

#pragma mark - Invoke

- (void)invokeWithSuccess:(void (^)(HttpResult *httpResult))success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    // set timeout
    [manager.requestSerializer setTimeoutInterval:REQUEST_TIMEOUT];
    
    if ([AGSCache getToken]) {
        [self.headers setValue:[AGSCache getToken] forKey:@"Authorization"];
    }
    
    // set headers
    for (NSString *key in self.headers.allKeys) {
        [manager.requestSerializer setValue:[self.headers valueForKey:key] forHTTPHeaderField:key];
    }
    
    NSInteger method = self.requestMethod;
    switch (method) {
        case GET:
            [self invokeGET:manager success:success failure:failure];
            
            break;
            
        case POST:
            if (self.multiparts.count > 0) {
                [self invokePOSTMultiPart:manager success:success failure:failure];
            }
            else {
                [self invokePOST:manager success:success failure:failure];
            }
            
            break;
        case PUT:
            [self invokePUT:manager success:success failure:failure];
            
            break;
            
            case DELETE:
            [self invokeDELETE:manager success:success failure:failure];
            
            break;
    }
}

- (void)invokeGET:(AFHTTPRequestOperationManager *)manager
                                     success:(void (^)(HttpResult *httpResult))success
                                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [manager GET:self.baseUrl parameters:self.parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        HttpResult *result = [[HttpResult alloc] initWithRequestOperation:operation];
        success(result);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure(operation ,error);
        
    }];
}

- (void)invokeDELETE:(AFHTTPRequestOperationManager *)manager
          success:(void (^)(HttpResult *httpResult))success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [manager DELETE:self.baseUrl parameters:self.parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        HttpResult *result = [[HttpResult alloc] initWithRequestOperation:operation];
        success(result);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure(operation ,error);
        
    }];
}

- (void)invokePUT:(AFHTTPRequestOperationManager *)manager
           success:(void (^)(HttpResult *httpResult))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    self.baseUrl = [NSString stringWithFormat:@"%@%@", self.baseUrl, [self createQueryParameter]];
    
    // POST normal
    id parameters = nil;
    if (self.objectBody) {
        // POST with json body
        parameters = [self.objectBody toDictionary];
    } else if (self.arrayBody) {
        parameters = [[NSMutableArray alloc] init];
        for (JsonSerializable *obj in self.arrayBody) {
            [parameters addObject:[obj toDictionary]];
        }
    }
    
    [manager PUT:self.baseUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        HttpResult *result = [[HttpResult alloc] initWithRequestOperation:operation];
        success(result);
        NSString *token = [[[(NSDictionary *)operation valueForKey:@"response"]valueForKey:@"allHeaderFields"] valueForKeyPath:@"Authorization"];
        if (token) {
            [AGSCache setToken:token];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure(operation ,error);
        
    }];
    
}

- (void)invokePOST:(AFHTTPRequestOperationManager *)manager
                                     success:(void (^)(HttpResult *httpResult))success
                                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    self.baseUrl = [NSString stringWithFormat:@"%@%@", self.baseUrl, [self createQueryParameter]];
    
    // POST normal
    id parameters = nil;
    if (self.objectBody) {
        // POST with json body
        parameters = [self.objectBody toDictionary];
    } else if (self.arrayBody) {
        parameters = [[NSMutableArray alloc] init];
        for (JsonSerializable *obj in self.arrayBody) {
            [parameters addObject:[obj toDictionary]];
        }
    }
    
    [manager POST:self.baseUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        HttpResult *result = [[HttpResult alloc] initWithRequestOperation:operation];
        success(result);
        NSString *token = [[[(NSDictionary *)operation valueForKey:@"response"]valueForKey:@"allHeaderFields"] valueForKeyPath:@"Authorization"];
        if (token) {
            [AGSCache setToken:token];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure(operation ,error);
        
    }];
    
}

- (void)invokePOSTMultiPart:(AFHTTPRequestOperationManager *)manager
           success:(void (^)(HttpResult *httpResult))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    self.baseUrl = [NSString stringWithFormat:@"%@%@", self.baseUrl, [self createQueryParameter]];
    
    // POST with multipart
    if (self.multiparts.count > 0) {
        
        [manager POST:self.baseUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            for (MultiPart *part in self.multiparts) {
                [formData appendPartWithHeaders:[part getHeaders] body:part.data];
            }
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            HttpResult *result = [[HttpResult alloc] initWithRequestOperation:operation];
            success(result);
            NSString *token = [[[(NSDictionary *)operation valueForKey:@"response"]valueForKey:@"allHeaderFields"] valueForKeyPath:@"Authorization"];
            if (token) {
                [AGSCache setToken:token];
            }

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            failure(operation ,error);
            
        }];
    }
    
}

#pragma mark - Create query parameter

- (NSString *)createQueryParameter
{
    NSString *query = @"";
    for (NSString *key in self.parameters.allKeys) {
        if (query.length == 0) {
            //query += "?"
            query = @"?";
        }
        else {
            //query += "&"
            query = [NSString stringWithFormat:@"%@&", query];
        }
        
        //query += "key=value"
        query = [NSString stringWithFormat:@"%@%@=%@", query, key, [self.parameters valueForKey:key]];
    }
    
    return query;
}

#pragma mark - Factory

+ (RequestInvoker *)requestInvokerWithUrl:(NSString *)url requestMethod:(RequestMethod)requestMethod
{
    return [[RequestInvoker alloc] initWithUrl:url requestMethod:requestMethod];
}

@end
