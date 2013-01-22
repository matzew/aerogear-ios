/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
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

#import "AGPipeConfiguration.h"

@implementation AGPipeConfiguration

@synthesize baseURL = _baseURL;
@synthesize endpoint = _endpoint;
@synthesize recordId = _recordId;
@synthesize authModule = _authModule;
@synthesize name = _name;
@synthesize type = _type;

// paging
@synthesize parameterProvider = _parameterProvider;
@synthesize offset = _offset;
@synthesize limit = _limit;
@synthesize metadataLocation = _metadataLocation;
@synthesize pagingLocation = _pagingLocation;
@synthesize nextIdentifier = _nextIdentifier;
@synthesize previousIdentifier = _previousIdentifier;

- (id)init {
    self = [super init];
    if (self) {
        // default values:
        _type = @"REST";
        _recordId = @"id";
        _metadataLocation = @"webLinking";
        _pagingLocation = @"query";
        _nextIdentifier = @"next";
        _previousIdentifier = @"previous";
        _offset = @"0"; //strange APIs like reddit... treat offset as string...
        _limit = [NSNumber numberWithInteger:10];
    }
    return self;
}

// custom getter to return name if no endpoint is specified.
-(NSString*) endpoint {
    return (_endpoint == nil? _name: _endpoint);
}

// custom getter for the prarameter provider...
// If the user does NOT provide a "parameter provider",
// the values for limit/offset are used
-(NSDictionary *)parameterProvider {
    if (_parameterProvider) {
        return _parameterProvider;
    } else {
        return [NSDictionary dictionaryWithObjectsAndKeys:_offset, @"offset", _limit, @"limit", nil];
    }
}

// custom setter to make sure only "header", "body" or "webLinking" is provided:
-(void)setMetadataLocation:(NSString *)metadataLocation {
    
    if ([@"header" isEqualToString:metadataLocation] || [@"body" isEqualToString:metadataLocation] || [@"webLinking" isEqualToString:metadataLocation]) {
        _metadataLocation = metadataLocation;
    } else {
        _metadataLocation = @"webLinking"; // default.....
    }
}
// custom setter to make sure only "header" or "pagingLocation" is provided:
-(void)setPagingLocation:(NSString *)pagingLocation {
    if ([@"header" isEqualToString:pagingLocation] || [@"pagingLocation" isEqualToString:pagingLocation] ) {
        _pagingLocation = pagingLocation;
    } else {
        _pagingLocation = @"query"; // default.....
    }
}
@end
