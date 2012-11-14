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
#import "AGAuthenticationModuleAdapter.h"
#import "AGHttpClient.h"

@implementation AGRestAdapter {
    AGHttpClient* _restClient;
    id<AGAuthenticationModuleAdapter> _authModule;
    
    NSString* _recordId;
}

@synthesize type = _type;
@synthesize url = _url;

- (id)init {
    self = [super init];
    if (self) {
        // base inits:
        _type = @"REST";
    }
    return self;
}

-(id) initForURL:(NSURL*) url recordId:(NSString*) recordId authModule:(id<AGAuthenticationModule>) authModule{
    self = [self init];
    if (self) {
        _url = url.absoluteString;
        _restClient = [AGHttpClient clientFor:url];
        _restClient.parameterEncoding = AFJSONParameterEncoding;
        
        _recordId = recordId;
        _authModule = (id<AGAuthenticationModuleAdapter>) authModule;
    }
    return self;
}

+(id) pipeForURL:(NSURL*) url recordId:(NSString*)recordId authModule:(id<AGAuthenticationModule>) authModule{
    return [[self alloc] initForURL:url recordId:recordId authModule:authModule];
}

// read all, via HTTP GET
-(void) read:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure {
    
    // try to add auth.token:
    [self applyAuthToken];
    

    // TODO: better Endpoints....
    [_restClient getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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

-(void) readWithFilter:(id)filterObject
               success:(void (^)(id responseObject))success
               failure:(void (^)(NSError *error))failure {
//    // try to add auth.token:
//    [self applyAuthToken];
// TODO...
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
    
    
    if ([object objectForKey:_recordId]) {
        //TODO: NSLog(@"HTTP PUT to update the given object");
        
        id key = [object objectForKey:_recordId];
        
        NSString* updateIdPath;
        if ([key isKindOfClass:[NSString class]]) {
            updateIdPath = key;
        } else {
            updateIdPath = [key stringValue];
        }
        
        [_restClient putPath:updateIdPath parameters:object success:successCallback failure:failureCallback];
        return;
    }
    else {
        //TODO: NSLog(@"HTTP POST to create the given object");
        [_restClient postPath:@"" parameters:object success:successCallback failure:failureCallback];
        return;
    }
}

-(void) remove:(id) key
       success:(void (^)(id responseObject))success
       failure:(void (^)(NSError *error))failure {

    // try to add auth.token:
    [self applyAuthToken];

    id deleteKey;
    if ([key isKindOfClass:[NSString class]]) {
        deleteKey = key;
    } else {
        deleteKey = [key stringValue];
    }

    [_restClient deletePath:deleteKey parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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