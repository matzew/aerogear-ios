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
#import "AGAuthenticator.h"

@interface AGAuthenticatorTests : SenTestCase

@end

@implementation AGAuthenticatorTests

-(void) testCreateEmptyAuthenticator {
    AGAuthenticator* authenticator = [AGAuthenticator authenticator];
    STAssertNotNil(authenticator, @"authenticator not nil");
}

-(void) testCreateAuthenticatorWithOneModule {
    AGAuthenticator* authenticator = [AGAuthenticator authenticator];
    STAssertNotNil(authenticator, @"authenticator not nil");
    
    id<AGAuthenticationModule> module = [authenticator add:@"SomeModule" baseURL:[NSURL URLWithString:@"https://server:8080/application/"]];
    STAssertNotNil(module, @"module not nil");

    // check endpoint URLs:
    STAssertEqualObjects(@"https://server:8080/application/auth/login", [module loginEndpoint], @"has expected login endpoint URL");
    STAssertEqualObjects(@"https://server:8080/application/auth/logout", [module logoutEndpoint], @"has expected login endpoint URL");
    STAssertEqualObjects(@"https://server:8080/application/auth/register", [module enrollEndpoint], @"has expected login endpoint URL");
    
    
    module = [authenticator get:@"SomeModule"];
    STAssertNotNil(module, @"module not nil");
    
    module = [authenticator get:@"SomeOtherModule"];
    STAssertNil(module, @"module should be nil");

}

-(void) testEndpointURLs {
    AGAuthenticator* authenticator = [AGAuthenticator authenticator];
    STAssertNotNil(authenticator, @"authenticator not nil");
    
    id<AGAuthenticationModule> module = [authenticator add:@"SomeModule" baseURL:[NSURL URLWithString:@"https://server:8080/application/subcontext/"]];
    STAssertNotNil(module, @"module not nil");
    // check endpoint URLs:
    STAssertEqualObjects(@"https://server:8080/application/subcontext/auth/login", [module loginEndpoint], @"has expected login endpoint URL");
    STAssertEqualObjects(@"https://server:8080/application/subcontext/auth/logout", [module logoutEndpoint], @"has expected login endpoint URL");
    STAssertEqualObjects(@"https://server:8080/application/subcontext/auth/register", [module enrollEndpoint], @"has expected login endpoint URL");
    
}

-(void) testCreateAuthenticatorAndAddModules {
    AGAuthenticator* authenticator = [AGAuthenticator authenticator];
    STAssertNotNil(authenticator, @"authenticator not nil");
    
    id<AGAuthenticationModule> module = [authenticator add:@"SomeModule" baseURL:[NSURL URLWithString:@"https://server:8080/application/"]];
    STAssertNotNil(module, @"module not nil");
    // check endpoint URLs:
    STAssertEqualObjects(@"https://server:8080/application/auth/login", [module loginEndpoint], @"has expected login endpoint URL");
    STAssertEqualObjects(@"https://server:8080/application/auth/logout", [module logoutEndpoint], @"has expected login endpoint URL");
    STAssertEqualObjects(@"https://server:8080/application/auth/register", [module enrollEndpoint], @"has expected login endpoint URL");
    
    
    id<AGAuthenticationModule> otherModule = [authenticator add:@"OtherModule" baseURL:[NSURL URLWithString:@"https://server:8080/other-application/"]];
    STAssertNotNil(otherModule, @"module not nil");
    // check endpoint URLs:
    STAssertEqualObjects(@"https://server:8080/other-application/auth/login", [otherModule loginEndpoint], @"has expected login endpoint URL");
    STAssertEqualObjects(@"https://server:8080/other-application/auth/logout", [otherModule logoutEndpoint], @"has expected login endpoint URL");
    STAssertEqualObjects(@"https://server:8080/other-application/auth/register", [otherModule enrollEndpoint], @"has expected login endpoint URL");
    
    // look em up:
    STAssertNotNil([authenticator get:@"SomeModule"], @"module not nil");
    STAssertNotNil([authenticator get:@"OtherModule"], @"module not nil");
}

-(void) testCreateAuthenticatorAndAddAndRemoveModules {
    AGAuthenticator* authenticator = [AGAuthenticator authenticator];
    STAssertNotNil(authenticator, @"authenticator not nil");
    
    id<AGAuthenticationModule> module = [authenticator add:@"SomeModule" baseURL:[NSURL URLWithString:@"https://server:8080/application/"]];
    STAssertNotNil(module, @"module not nil");
    
    // look it up:
    STAssertNotNil([authenticator get:@"SomeModule"], @"module not nil");
    
    [authenticator remove:@"SomeModule"];
    
    // look it up:
    STAssertNil([authenticator get:@"SomeModule"], @"module was already removed");
}

-(void) testCreateAuthenticatorAndAddWrongModuleType {
    AGAuthenticator* authenticator = [AGAuthenticator authenticator];
    STAssertNotNil(authenticator, @"authenticator not nil");
    
    id<AGAuthenticationModule> module = [authenticator add:@"SomeModule" baseURL:[NSURL URLWithString:@"https://server:8080/application/"] type:@"INVALID"];
    STAssertNil(module, @"module should be nil");
}


@end
