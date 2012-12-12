/*
 * JBoss, Home of Professional Open Source.
 * Copyright 2012 Red Hat, Inc., and individual contributors
 * as indicated by the @author tags.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AGRestAdapter.h"
#import "AGFilterConfiguration.h"
#import "AGAuthenticationModuleAdapter.h"

#import "AGHttpClient.h"

@implementation AGRestAdapter {
    id<AGAuthenticationModuleAdapter> _authModule;
    NSString* _recordId;
}

// =====================================================
// ================ public API (AGPipe) ================
// =====================================================

@synthesize type = _type;
@synthesize url = _url;

// ==============================================
// ======== 'factory' and 'init' section ========
// ==============================================

+(id) pipeWithConfig:(id<AGPipeConfig>) pipeConfig {
    return [[self alloc] initWithConfig:pipeConfig];
}

-(id) initWithConfig:(id<AGPipeConfig>) pipeConfig {
    self = [super init];
    if (self) {
        _type = @"REST";

        // set all the things:
        AGPipeConfiguration* config = (AGPipeConfiguration*) pipeConfig;
     
        NSURL* baseURL = [config baseURL];
        NSString* endpoint = [config endpoint];
        // append the endpoint/name and use it as the final URL
        NSURL* finalURL = [self appendEndpoint:endpoint toURL:baseURL];
        
        _url = finalURL.absoluteString;
        _recordId = [config recordId];
        _authModule = (id<AGAuthenticationModuleAdapter>) [config authModule];
        
        _restClient = [AGHttpClient clientFor:finalURL];
        _restClient.parameterEncoding = AFJSONParameterEncoding;
    }
    
    return self;
}

// private helper to append the endpoint
-(NSURL*) appendEndpoint:(NSString*)endpoint toURL:(NSURL*)baseURL {
    if (endpoint == nil) {
        endpoint = @"";
    }
    
    // append the endpoint name and use it as the final URL
    return [baseURL URLByAppendingPathComponent:endpoint];
}

// =====================================================
// ======== public API (AGPipe) ========
// =====================================================

-(void) read:(id)value
    success:(void (^)(id responseObject))success
    failure:(void (^)(NSError *error))failure {

    if ([value isKindOfClass:[NSNull class]]) {
        if (failure) {
            NSError* error = [NSError errorWithDomain:@"org.aerogear.pipes.read"
                                                 code:0
                                             userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"id value was NSNull", NSLocalizedDescriptionKey, nil]];
            
            failure(error);
        }
        
        // return on NSNull
        return;
    }
    
    [self readWithFilter:^(id<AGFilterConfig> config) {
        [config where:[NSDictionary dictionaryWithObjectsAndKeys:value, _recordId, nil]];
    } success:success failure:failure];
}

// read all, via HTTP GET
-(void) read:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure {
    
    // try to add auth.token:
    [self applyAuthToken];
    
    // TODO: better Endpoints....
    [_restClient getPath:_url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success) {
            //TODO: NSLog(@"Invoking successblock....");
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            //TODO: NSLog(@"Invoking failure block....");
            failure(error);
        }
    } ];
}

-(void) readWithFilter:(void (^)(id<AGFilterConfig> config))config
               success:(void (^)(id responseObject))success
               failure:(void (^)(NSError *error))failure {
    // try to add auth.token:
    [self applyAuthToken];
    
    NSDictionary *params;
    
    if (config != nil) {
        AGFilterConfiguration* filterConfig = [[AGFilterConfiguration alloc] init];
        config(filterConfig);
        
        params = [filterConfig dictionary];
    }

    [_restClient getPath:_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success) {
            //TODO: NSLog(@"Invoking successblock....");
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            //TODO: NSLog(@"Invoking failure block....");
            failure(error);
        }
    } ];
}

-(void) save:(NSDictionary*) object
     success:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure {

    // try to add auth.token:
    [self applyAuthToken];
    
    // Does a PUT or POST based on the fact if the object
    // already exists (if there is an 'id').
    
    // the blocks are unique to PUT and POST, so let's define them up-front:
    id successCallback = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            //TODO: NSLog(@"Invoking successblock....");
            success(responseObject);
        }
    };
    
    id failureCallback = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            //TODO: NSLog(@"Invoking failure block....");
            failure(error);
        }
    };
    
    id objectKey = [object objectForKey:_recordId];
    
    // we need to check if the map representation contains the "recordID" and its value is actually set:
    if (objectKey == nil || [objectKey isKindOfClass:[NSNull class]]) {
        //TODO: NSLog(@"HTTP POST to create the given object");
        [_restClient postPath:_url parameters:object success:successCallback failure:failureCallback];
        return;
    } else {
        NSString* updateId;
        if ([objectKey isKindOfClass:[NSString class]]) {
            updateId = objectKey;
        } else {
            updateId = [objectKey stringValue];
        }
        
        //TODO: NSLog(@"HTTP PUT to update the given object");
        [_restClient putPath:[self appendObjectPath:updateId] parameters:object success:successCallback failure:failureCallback];
        return;
    }
}

-(void) remove:(id) key
       success:(void (^)(id responseObject))success
       failure:(void (^)(NSError *error))failure {
    
    // when null was provided we try to invoke the failure block
    if ([key isKindOfClass:[NSNull class]]) {
        
        if (failure) {
            NSError* error = [NSError errorWithDomain:@"org.aerogear.pipes.remove"
                                                 code:0
                                             userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Key was NSNull", NSLocalizedDescriptionKey, nil]];
            
            failure(error);
        }
        
        // return on NSNull
        return;
    }
    

    // try to add auth.token:
    [self applyAuthToken];

    id deleteKey;
    if ([key isKindOfClass:[NSString class]]) {
        deleteKey = key;
    } else {
        deleteKey = [key stringValue];
    }

    [_restClient deletePath:[self appendObjectPath:deleteKey] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success) {
            //TODO: NSLog(@"Invoking successblock....");
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            //TODO: NSLog(@"Invoking failure block....");
            failure(error);
        }
    } ];
}

// appends the path for delete/updates to the URL
-(NSString*) appendObjectPath:(NSString*)path {
    return [NSString stringWithFormat:@"%@/%@", _url, path];
}

// helper method:
-(void) applyAuthToken {
    if ([_authModule isAuthenticated]) {
        [_restClient setDefaultHeader:@"Auth-Token" value:[_authModule authToken]];
    }
}

-(NSString *) description {
    return [NSString stringWithFormat: @"%@ [type=%@, url=%@]", self.class, _type, _url];
}

+ (BOOL) accepts:(NSString *) type {
    return [type isEqualToString:@"REST"];
}

@end