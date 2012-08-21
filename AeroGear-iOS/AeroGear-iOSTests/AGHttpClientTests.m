//
//  AGHttpClientTests.m
//  AeroGear-iOS
//
//  Created by matzew on 21.08.12.
//  Copyright (c) 2012 JBoss. All rights reserved.
//

#import "AGHttpClientTests.h"
#import "AGHttpClient.h"

@implementation AGHttpClientTests{
    BOOL _finishedFlag;
    AGHttpClient* restClient;
}

-(void)setUp {
    [super setUp];
    // create a shared client for the demo app:
    restClient = [AGHttpClient sharedClientFor:@"http://html5-aerogear.rhcloud.com/rest/"];
    restClient.parameterEncoding = AFJSONParameterEncoding;
    
    
    _finishedFlag = NO;
}

-(void)tearDown {
    restClient = nil;
}



-(void) testExternalJsonCall {
    [restClient getPath:@"members" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Projects: %@", responseObject);
        
        
        // signal that the test finished...
        _finishedFlag = YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // noop
        
        NSLog(@"%@", error);
        
    } ];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
}

@end
