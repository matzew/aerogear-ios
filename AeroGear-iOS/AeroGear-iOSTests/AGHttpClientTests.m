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
    restClient = [AGHttpClient sharedClientFor:@"http://todo-aerogear.rhcloud.com/todo-server/"];
    restClient.parameterEncoding = AFJSONParameterEncoding;
    
    
    _finishedFlag = NO;
}

-(void)tearDown {
    restClient = nil;
}

// =================================================
// CREATE section
// =================================================
-(void) testPostProject {
    // the object, fairly simple...just as a data structure... no object mapping yet..
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    // {"title":"my title","style":"project-232-96-96"}
    [parameters setValue:@"Created from testcase" forKey:@"title"];
    [parameters setValue:@"project-234-255-0" forKey:@"style"];
    
    
    [restClient postPath:@"projects" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Create Project response: %@", responseObject);
        
        
        // signal that the test finished...
        _finishedFlag = YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"An error occured! \n%@", error);
        _finishedFlag = YES;
        STFail(@"Error...");
        
    } ];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

// =================================================
// READ section
// =================================================

-(void) testGetProjects {
    
    [restClient getPath:@"projects" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Projects: %@", responseObject);
        
        
        // signal that the test finished...
        _finishedFlag = YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"An error occured! \n%@", error);
        _finishedFlag = YES;
        STFail(@"Error...");
        
    } ];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

@end