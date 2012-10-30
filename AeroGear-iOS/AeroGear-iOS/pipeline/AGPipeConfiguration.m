//
//  AGPipeConfiguration.m
//  AeroGear-iOS
//
//  Created by matzew on 30.10.12.
//  Copyright (c) 2012 JBoss. All rights reserved.
//

#import "AGPipeConfiguration.h"

@implementation AGPipeConfiguration {
    NSMutableDictionary* _config;
}

- (id)init {
    self = [super init];
    if (self) {
        _config = [NSMutableDictionary dictionary];
        
        
        // default values:
        [_config setValue:@"REST" forKey:@"type"];
    }
    return self;
}


-(void) name:(NSString*) name {
    [_config setValue:name forKey:@"name"];
}
-(void) type:(NSString*) type {
    [_config setValue:type forKey:@"type"];
}
-(void) baseURL:(NSURL*) baseURL {
    [_config setValue:baseURL forKey:@"baseURL"];
}
-(void) endpoint:(NSString*) endpoint {
    [_config setValue:endpoint forKey:@"endpoint"];
}
-(void) authModule:(id<AGAuthenticationModule>) authModule {
    [_config setValue:authModule forKey:@"authModule"];
}


// getters...
-(NSString*) name {
    return [_config valueForKey:@"name"];
}
-(NSString*) type {
    return [_config valueForKey:@"type"];
}
-(NSURL*) baseURL {
    return [_config valueForKey:@"baseURL"];
}
-(NSString*) endpoint {
    NSString* endpoint = [_config valueForKey:@"endpoint"];

    // use the name as endpoint, if not specified:
    if (endpoint == nil) {
        endpoint = [self name];
    }
    
    return endpoint;
}
-(id<AGAuthenticationModule>) authModule {
    return [_config valueForKey:@"authModule"];
}

@end
