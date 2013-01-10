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

#import "AGPropertyListStorage.h"

@implementation AGPropertyListStorage {
    NSString* _file;
}

@synthesize type = _type;

// ==============================================
// ======== 'factory' and 'init' section ========
// ==============================================

+(id) storeWithConfig:(id<AGStoreConfig>) storeConfig {
    return [[self alloc] initWithConfig:storeConfig];
}

-(id) initWithConfig:(id<AGStoreConfig>) storeConfig {
    self = [super init];
    if (self) {
        // base inits:
        _type = @"PLIST";
        
        AGStoreConfiguration* config = (AGStoreConfiguration*) storeConfig;
        _recordId = config.recordId;
        
        // extract file path
        _file = [self storeFilePathWithName:config.name];
        
        // if file exists initialize store
        if ([[NSFileManager defaultManager] fileExistsAtPath:_file]) {
            _array = [[NSMutableArray alloc] initWithContentsOfFile:_file];
        } else { // create an empty store
            _array = [[NSMutableArray alloc] init];
        }
    }
    
    return self;
}

// =====================================================
// ======== public API (AGStore) ========
// =====================================================

-(void) save:(id) data
     success:(void (^)(id object))success
     failure:(void (^)(NSError *error))failure {

    [super save:data success:^(id object) {
        BOOL saved = [_array writeToFile:_file atomically:YES];
        
        if (saved) {
            if (success)
                success(object);
        } else {
            [self raiseError:@"save" msg:@"error on save" failure:failure];
        }
        
    } failure:failure];
}

-(void) reset:(void (^)())success
      failure:(void (^)(NSError *error))failure {
    
    [super reset:^{
        BOOL saved = [_array writeToFile:_file atomically:YES];
        
        if (saved) {
            if (success)
                success();
        } else {
            [self raiseError:@"reset" msg:@"error on reset" failure:failure];
        }
        
    } failure:failure];
}

-(void) remove:(id) recordId
       success:(void (^)(id object))success
       failure:(void (^)(NSError *error))failure {
    
    [super remove:recordId success:^(id object) {
        BOOL saved = [_array writeToFile:_file atomically:YES];
        
        if (saved) {
            if (success)
                success(object);
        } else {
            [self raiseError:@"remove" msg:@"error on remove" failure:failure];
        }

    } failure:failure];
}

// =====================================================
// =========== private utility methods  ================
// =====================================================

-(NSString*) storeFilePathWithName:(NSString*) name {
    // calculate path
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    // create the Documents directory if it doesn't exist
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory isDirectory:&isDir]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory
                                  withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    // the filename is based on this store name
    return [documentsDirectory stringByAppendingPathComponent:name];
}

@end
