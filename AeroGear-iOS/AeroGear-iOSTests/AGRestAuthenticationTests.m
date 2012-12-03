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
#import "AGRestAuthentication.h"
#import "AGAuthConfiguration.h"
#import "AGPipeline.h"

#import "AGMockURLProtocol.h"

static NSString *const AUTH_TOKEN = @"f36d937c-28d1-4426-98d2-ddab11e954d6";
static NSString *const PASSING_USERNAME = @"john";

static NSString *const FAILING_USERNAME = @"fail";
static NSString *const LOGIN_PASSWORD = @"passwd";
static NSString *const ENROLL_PASSWORD = @"passwd";

static NSString *const LOGIN_SUCCESS_RESPONSE =  @"{\"username\":\"%@\",\"roles\":[\"admin\"],\"logged\":\"true\"}";

@interface AGRestAuthenticationTests : SenTestCase

@end

@implementation AGRestAuthenticationTests {
    BOOL _finishedFlag;

    id<AGPipe> _projects;
    
    AGRestAuthentication* _restAuthModule;
}

-(void)setUp {
    [super setUp];
    
    // register AGFakeURLProtocol to fake HTTP comm.
    [NSURLProtocol registerClass:[AGMockURLProtocol class]];
    [AGMockURLProtocol setStatusCode:200];
	[AGMockURLProtocol setHeaders:nil];
	[AGMockURLProtocol setResponseData:nil];
	[AGMockURLProtocol setError:nil];
    
    // set correct content-type otherwise AFNetworking
    // will complain because it expects JSON response
    [AGMockURLProtocol setHeaders:[NSDictionary
                                   dictionaryWithObject:@"application/json; charset=utf-8" forKey:@"Content-Type"]];
    
    
    NSURL* baseURL = [NSURL URLWithString:@"https://server.com/context/"];
    
    // setup REST Authenticator
    AGAuthConfiguration* config = [[AGAuthConfiguration alloc] init];
    [config baseURL:baseURL];
    [config enrollEndpoint:@"auth/register"];

    _restAuthModule = [AGRestAuthentication moduleWithConfig:config];

    // setup Pipeline
    AGPipeline* pipeline = [AGPipeline pipeline:baseURL];
    _projects = [pipeline pipe:^(id<AGPipeConfig> config) {
        [config name:@"projects"];
        [config authModule:_restAuthModule];
    }];
}

-(void)tearDown {
    [NSURLProtocol unregisterClass:[AGMockURLProtocol class]];
    [AGMockURLProtocol setStatusCode:200];
	[AGMockURLProtocol setHeaders:nil];
	[AGMockURLProtocol setResponseData:nil];
	[AGMockURLProtocol setError:nil];
    
    _projects = nil;
    _restAuthModule = nil;
}

-(void)testRestAuthenticationCreation {
    STAssertNotNil(_restAuthModule, @"module should not be nil");
}

-(void) testLoginSuccess {
    [AGMockURLProtocol addHeader:@"Auth-Token" value:AUTH_TOKEN];
    [AGMockURLProtocol setResponseData:[[NSString stringWithFormat:LOGIN_SUCCESS_RESPONSE, PASSING_USERNAME]
                                        dataUsingEncoding:NSUTF8StringEncoding]];

    [_restAuthModule login:PASSING_USERNAME password:LOGIN_PASSWORD success:^(id responseObject) {
        STAssertEqualObjects(PASSING_USERNAME, [responseObject valueForKey:@"username"], @"should be equal");
        STAssertEqualObjects([responseObject valueForKey:@"logged"], @"true", @"should be true");
        
        _finishedFlag = YES;
    } failure:^(NSError *error) {
        _finishedFlag = YES;
        STFail(@"should have login", error);
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testLoginFails {
    [AGMockURLProtocol setError:[NSError errorWithDomain:NSURLErrorDomain
                                                    code:401 // Unauthorized
                                                userInfo:nil]];
    
    [_restAuthModule login:FAILING_USERNAME password:LOGIN_PASSWORD success:^(id responseObject) {
        STFail(@"should not work");
        _finishedFlag = YES;
    } failure:^(NSError *error) {
        _finishedFlag = YES;
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testLogout {
    [AGMockURLProtocol addHeader:@"Auth-Token" value:AUTH_TOKEN];
    [AGMockURLProtocol setResponseData:[[NSString stringWithFormat:LOGIN_SUCCESS_RESPONSE, PASSING_USERNAME]
                                        dataUsingEncoding:NSUTF8StringEncoding]];
    
    [_restAuthModule login:PASSING_USERNAME password:LOGIN_PASSWORD success:^(id object) {
        // after initial login, we issue a logout:
        [_restAuthModule logout:^{
            _finishedFlag = YES;
        } failure:^(NSError *error) {
            _finishedFlag = YES;
            STFail(@"wrong logout...");
        }];
    } failure:^(NSError *error) {
        _finishedFlag = YES;
        STFail(@"wrong login");
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testEnrollSuccess {
    [AGMockURLProtocol addHeader:@"Auth-Token" value:AUTH_TOKEN];
    [AGMockURLProtocol setResponseData:[[NSString stringWithFormat:LOGIN_SUCCESS_RESPONSE, PASSING_USERNAME]
                                        dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* registerPayload = [NSMutableDictionary dictionary];
    
    [registerPayload setValue:@"John" forKey:@"firstname"];
    [registerPayload setValue:@"Doe" forKey:@"lastname"];
    [registerPayload setValue:@"emaadsil@mssssse.com" forKey:@"email"];
    [registerPayload setValue:PASSING_USERNAME forKey:@"username"];
    [registerPayload setValue:LOGIN_PASSWORD forKey:@"password"];
    [registerPayload setValue:@"admin" forKey:@"role"];

    [_restAuthModule enroll:registerPayload success:^(id responseObject) {
        STAssertEqualObjects(PASSING_USERNAME, [responseObject valueForKey:@"username"], @"should be equal");
        STAssertEqualObjects([responseObject valueForKey:@"logged"], @"true", @"should be true");
        
        _finishedFlag = YES;
    } failure:^(NSError *error) {
        _finishedFlag = YES;
        STFail(@"should have enroll", error);
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}
-(void) testEnrollFails {
    [AGMockURLProtocol setError:[NSError errorWithDomain:NSURLErrorDomain
                                                    code:400 // Bad Request
                                                userInfo:nil]];

    NSMutableDictionary* registerPayload = [NSMutableDictionary dictionary];
    
    [registerPayload setValue:@"John" forKey:@"firstname"];
    [registerPayload setValue:@"Doe" forKey:@"lastname"];
    [registerPayload setValue:@"emaadsil@mssssse.com" forKey:@"email"];
    [registerPayload setValue:PASSING_USERNAME forKey:@"username"];
    [registerPayload setValue:LOGIN_PASSWORD forKey:@"password"];
    [registerPayload setValue:@"admin" forKey:@"role"];
    
    [_restAuthModule enroll:registerPayload success:^(id responseObject) {
        STFail(@"should not work");        
        _finishedFlag = YES;
    } failure:^(NSError *error) {
        _finishedFlag = YES;
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

@end
