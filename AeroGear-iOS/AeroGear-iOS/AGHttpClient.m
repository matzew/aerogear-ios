//
//  AGHttpClient.m
//  AeroGear-iOS
//
//  Created by matzew on 21.08.12.
//  Copyright (c) 2012 JBoss. All rights reserved.
//

#import "AGHttpClient.h"


@implementation AGHttpClient

+ (AGHttpClient *)sharedClientFor:(NSString *)url {
    static AGHttpClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AGHttpClient alloc] initWithBaseURL:[NSURL URLWithString:url]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}


@end
