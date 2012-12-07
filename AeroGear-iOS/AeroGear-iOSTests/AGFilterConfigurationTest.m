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

#import <SenTestingKit/SenTestingKit.h>

#import "AGFilterConfiguration.h"

@interface AGFilterConfigurationTest : SenTestCase

@end

@implementation AGFilterConfigurationTest {
    AGFilterConfiguration* _config;
}

-(void)setUp {
    [super setUp];

    _config = [[AGFilterConfiguration alloc] init];
    
    [_config limit:10];
    [_config offset:3];
    [_config where:[NSDictionary dictionaryWithObjectsAndKeys:@"BMV", @"car", nil]];
}

-(void)tearDown {
    [super tearDown];
}

-(void)testFilterConfigurationCreation {
    STAssertNotNil(_config, @"config should not be nil");
}

-(void)testFilterParams {
    STAssertEquals((NSUInteger)10, [_config limit], @"should be equal");
    STAssertEquals((NSUInteger)3, [_config offset], @"should be equal");
    
    NSDictionary *dummyWhere = [NSDictionary dictionaryWithObjectsAndKeys:@"BMV", @"car", nil];
    STAssertEqualObjects(dummyWhere, [_config where], @"should be equal");
}

@end
