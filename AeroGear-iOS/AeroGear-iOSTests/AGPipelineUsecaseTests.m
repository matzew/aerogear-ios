//
//  AGPipelineUsecaseTests.m
//  AeroGear-iOS
//
//  Created by matzew on 24.08.12.
//  Copyright (c) 2012 JBoss. All rights reserved.
//

#import "AGPipelineUsecaseTests.h"
#import "AGPipeline.h"
#import "AGPipe.h"

@implementation AGPipelineUsecaseTests {
    BOOL _finishedFlag;
    
    id<AGPipe> projects;
}

// TODO: static hack...
NSMutableDictionary* projectEntity;

-(void)setUp {
    [super setUp];
    _finishedFlag = NO;
    
    // basic setup, for every test:
    // create the 'todo' pipeline;
    NSURL* projectsURL = [NSURL URLWithString:@"http://todo-aerogear.rhcloud.com/todo-server/projects/"];
    AGPipeline* todo = [AGPipeline pipelineWithPipe:@"projects" url:projectsURL type:@"REST"];
    
    // get access to the projects pipe
    projects = [todo get:@"projects"];

    
}

-(void)tearDown {
    projects = nil;
    [super tearDown];
}

-(void) testCreateTodoPipelineAndCreateProject{
    // PIPELINE is created in setup


    // create a 'new' project entity...
    // using NS(Mutable)Dictionary, for now..........
    
    projectEntity = [NSMutableDictionary dictionary];
    [projectEntity setValue:@"Hello World" forKey:@"title"];
    
    
    // save the 'new' project:
    [projects save:projectEntity success:^(id responseObject) {
        NSLog(@"CREATE RESPONSE\n%@", [responseObject description]);
        
        // get the id of the new project:
        id resourceId = [responseObject valueForKey:@"id"];
        // update the 'object'.....
        [projectEntity setValue:[resourceId stringValue] forKey:@"id"];
        
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        
        NSLog(@"SAVE: An error occured! \n%@", error);
    }];


    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}


-(void) testCreateTodoPipelineAndUpdateProject{

    // change the title of the project:
    [projectEntity setValue:@"Hello Update World!" forKey:@"title"];
    
    
    [projects save:projectEntity success:^(id responseObject) {
        NSLog(@"UPDATE RESPONSE\n%@", [responseObject description]);
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        
        NSLog(@"UPDATE: An error occured! \n%@", error);
    }];


    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testCreateTodoPipelineAnd_RemoveProject{
    // just remove this project:
    [projects remove:[projectEntity objectForKey:@"id"] success:^(id responseObject) {
        NSLog(@"DELETE RESPONSE\n%@", [responseObject description]);
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        
        NSLog(@"DELETE: An error occured! \n%@", error);
    }];
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}


@end
