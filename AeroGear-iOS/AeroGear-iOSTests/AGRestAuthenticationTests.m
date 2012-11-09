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

@interface AGRestAuthenticationTests : SenTestCase

@end

@implementation AGRestAuthenticationTests{
    BOOL _finishedFlag;
    AGRestAuthentication* restAuthModule;
    NSURL* baseURL;
}
-(void)setUp {
    [super setUp];
    // create a shared client for the demo app:
    baseURL = [NSURL URLWithString:@"https://todoauth-aerogear.rhcloud.com/todo-server/"];
    
    AGAuthConfiguration* config = [[AGAuthConfiguration alloc] init];
    [config baseURL:baseURL];
    [config enrollEndpoint:@"auth/register"];
    
    restAuthModule = [AGRestAuthentication moduleWithConfig:config];

    _finishedFlag = NO;
}

-(void)tearDown {
    restAuthModule = nil;
}

///////// this is more an integration test......



-(void) testLoginAndProtectedAccess {
    
    [restAuthModule login:@"john" password:@"123" success:^(id object) {
        //        _finishedFlag = YES;
        
        
        AGPipeline* pipeline = [AGPipeline pipeline];
        id<AGPipe> projects = [pipeline pipe:^(id<AGPipeConfig> config) {
            [config name:@"projects"];
            [config baseURL:baseURL];
            [config authModule:restAuthModule];
        }];

        
        [projects read:^(id responseObject) {
            _finishedFlag = YES;
            NSLog(@"\n%@", responseObject);
        } failure:^(NSError *error) {
            _finishedFlag = YES;
            STFail(@"no access to server resource: %@", error);
        }];
        
        [projects read:^(id responseObject) {
            _finishedFlag = YES;
            NSLog(@"\n%@", responseObject);
        } failure:^(NSError *error) {
            _finishedFlag = YES;
            STFail(@"no access to server resource: %@", error);
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

-(void) testLoginWithProtectedAccessAndLogout {
    
    [restAuthModule login:@"john" password:@"123" success:^(id object) {
        //        _finishedFlag = YES;
        [restAuthModule logout:^{
            AGPipeline* pipeline = [AGPipeline pipeline];
            id<AGPipe> tasks = [pipeline pipe:^(id<AGPipeConfig> config) {
                [config name:@"tasks"];
                [config baseURL:baseURL];
                [config authModule:restAuthModule];
            }];
            
            [tasks read:^(id responseObject) {
                _finishedFlag = YES;
                STFail(@"should have NO access to server resource...");
            } failure:^(NSError *error) {
                _finishedFlag = YES;
            }];
            
            
            
        } failure:^(NSError *error) {
            _finishedFlag = YES;
            STFail(@"wrong login");
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



-(void) testSuccessfulLogin {
    
    [restAuthModule login:@"john" password:@"123" success:^(id object) {
        _finishedFlag = YES;
    } failure:^(NSError *error) {
        _finishedFlag = YES;
        STFail(@"wrong login");
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testUnsuccessfulLogin {

    [restAuthModule login:@"johnny" password:@"likeAboss" success:^(id object) {
        STFail(@"should not work...");
        _finishedFlag = YES;
    } failure:^(NSError *error) {
        _finishedFlag = YES;
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}


-(void) testLogoff {
    
    [restAuthModule login:@"john" password:@"123" success:^(id object) {
        // after initial login, we issue a logout:
        [restAuthModule logout:^{
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


-(void) testWrongLogoff {
    
    // blank logoff....
    [restAuthModule logout:^{
        _finishedFlag = YES;
        STFail(@"this should fail, so no success should be invoked");
    } failure:^(NSError *error) {
        _finishedFlag = YES;
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

// not testing this, need to generate random usernames...
-(void) NotestRegister {
    // {"firstname":"firstname","lastname":"lastname","email":"mei@ooo.de","username":"dsadsasdas","password":"asdasdasdsa","role":"admin"}
    NSMutableDictionary* registerPayload = [NSMutableDictionary dictionary];
    [registerPayload setValue:@"Matthias" forKey:@"firstname"];
    [registerPayload setValue:@"Wessendorf" forKey:@"lastname"];
    [registerPayload setValue:@"emaadsil@mssssse.com" forKey:@"email"];
    [registerPayload setValue:@"usefhrndasame" forKey:@"username"];
    [registerPayload setValue:@"secASDret" forKey:@"password"];
    [registerPayload setValue:@"admin" forKey:@"role"];
    
    [restAuthModule enroll:registerPayload success:^(id object) {
        NSLog(@"\n\n%@", object);
        _finishedFlag = YES;
    } failure:^(NSError *error) {
        NSLog(@"\n\n%@", error);
        _finishedFlag = YES;
        STFail(@"broken register");
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}



@end
