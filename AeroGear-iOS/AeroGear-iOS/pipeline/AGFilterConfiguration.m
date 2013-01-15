/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
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

@implementation AGFilterConfiguration

@synthesize limit = _limit;
@synthesize offset = _offset;
@synthesize where = _where;
@synthesize name = _name;
@synthesize type = _type;

- (id)init {
    self = [super init];
    if (self) {
        // default values:
        //_name = @"default";
    
        // adding some more (reasonable) defaults:
        _limit = 10;
        _offset = 0;
    }
    
    return self;
}

- (NSDictionary*) dictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithUnsignedInteger:_offset], @"offset",
                        [NSNumber numberWithUnsignedInteger:_limit], @"limit",
                        _where, @"where", nil];
}

@end
