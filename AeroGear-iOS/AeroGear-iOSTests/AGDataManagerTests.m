//
//  AGDataManagerTests.m
//  AeroGear-iOS
//
//  Created by matzew on 20.09.12.
//  Copyright (c) 2012 JBoss. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "AGStore.h"
#import "AGDataManager.h"

@interface AGDataManagerTests : SenTestCase

@end
@implementation AGDataManagerTests

-(void) testCreateDataManager {
    AGDataManager* mgr = [[AGDataManager alloc] init];
    
    NSLog(@"\n\n\n====>>>>>>>>>>>>>>>>>'%@'\n\n", mgr);
    
    
    id<AGStore> store;
    
    
    [store reset:^{
        //adsdsa
    } failure:^(NSError *error) {
        // dsadsa
    }];
    
//    [store reset:^(id responseObject) {
//        //
//    } failure:^(NSError *error) {
//        //
//    }];
    
}

@end
