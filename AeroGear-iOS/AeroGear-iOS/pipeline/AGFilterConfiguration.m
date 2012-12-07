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

#import "AGFilterConfiguration.h"

@implementation AGFilterConfiguration {
    NSMutableDictionary* _config;
}

- (id)init {
    self = [super init];
    if (self) {
        _config = [NSMutableDictionary dictionary];
    }
    return self;
}


-(void) name:(NSString*) name {
    [_config setValue:name forKey:@"name"];
}

-(void) limit:(NSUInteger) limit {
    [_config setValue:[NSNumber numberWithUnsignedInteger:limit] forKey:@"limit"];
}

-(void) offset:(NSUInteger) offset {
    [_config setValue:[NSNumber numberWithUnsignedInteger:offset] forKey:@"offset"];
}

-(void) where:(NSDictionary*) where {
    [_config setValue:where forKey:@"where"];
}

-(void) type:(NSString*) type {
    [_config setValue:type forKey:@"type"];
}

// getters...
-(NSString*) name {
    return [_config valueForKey:@"name"];
}

-(NSUInteger) limit {
    return [[_config valueForKey:@"limit"] unsignedIntegerValue];
}

-(NSUInteger) offset {
    return [[_config valueForKey:@"offset"] unsignedIntegerValue];
}

-(NSDictionary*) where {
    return [_config valueForKey:@"where"];
}

-(NSString*) type {
    return [_config valueForKey:@"type"];
}

- (NSDictionary*) dictionary {
    return [_config copy];
}

@end
