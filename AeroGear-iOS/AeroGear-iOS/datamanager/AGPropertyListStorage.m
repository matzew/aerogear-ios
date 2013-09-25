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

#import "AGPropertyListStorage.h"

/**
  Provides a common interface around NSPropertyListSerialization and NSJSONSerialization
  plist output formats.
 */
@protocol AGEncoder <NSObject>

-(NSData *) encode:(id)plist error:(NSError **)error;
-(id)       decode:(NSData *)data error:(NSError **)error;

-(BOOL) isValid:(id)plist;

@end

/**
  An encoder backed by a NSPropertyListSerialization
 */
@interface AGPListEncoder : NSObject <AGEncoder>
@end

@implementation AGPListEncoder

-(NSData *) encode:(id)plist error:(NSError **)error {
    return [NSPropertyListSerialization dataWithPropertyList:plist format:NSPropertyListXMLFormat_v1_0
                                                             options:0 error:error];
}

-(id) decode:(NSData *)data error:(NSError **)error {
    NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;
    
    return [NSPropertyListSerialization propertyListWithData:data
                                                     options:NSPropertyListMutableContainersAndLeaves
                                                      format:&format error:error];
}

-(BOOL) isValid:(id)plist {
    return [NSPropertyListSerialization propertyList:plist isValidForFormat:NSPropertyListXMLFormat_v1_0];
}

@end

/**
  An encoder backed by a NSJSONSerialization
 */
@interface AGJsonEncoder : NSObject <AGEncoder>
@end

@implementation AGJsonEncoder

-(NSData *) encode:(id)plist error:(NSError **)error {
    return [NSJSONSerialization dataWithJSONObject:plist
                                    options:NSJSONWritingPrettyPrinted
                                      error:error];
}

-(id) decode:(NSData *)data error:(NSError **)error {
    return [NSJSONSerialization JSONObjectWithData:data
                                    options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves
                                      error:error];
}

-(BOOL) isValid:(id)plist {
    return [NSJSONSerialization isValidJSONObject:plist];
}

@end

@implementation AGPropertyListStorage {
    NSURL* _file;
    
    id<AGEncoder> _encoder;
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
        
        AGStoreConfiguration* config = (AGStoreConfiguration*) storeConfig;
        _recordId = config.recordId;
        _type = config.type;
        
        if ([_type isEqualToString:@"PLISTJ"])
            _encoder = [[AGJsonEncoder alloc] init];
        else  // if not specified use PLIST encoder
            _encoder = [[AGPListEncoder alloc] init];

        // extract file path
        _file = [self storeURLWithName:config.name];
        
        // if plist file exists initialize store from it
        if ([[NSFileManager defaultManager] fileExistsAtPath:[_file path]]) {
            // load file
            NSData *data = [NSData dataWithContentsOfURL:_file];

            NSError *error;
            
            // decode structure
            _array = [_encoder decode:data error:&error];
            
            if (error) {  // if there was an error during convert log it
                NSLog(@"%@ %@: %@", [self class], NSStringFromSelector(_cmd), error);
            }
        }
        
        if (!_array) // always create an empty store
            _array = [[NSMutableArray alloc] init];
    }
    
    return self;
}

// =====================================================
// ======== public API (AGStore) ========
// =====================================================

-(BOOL) save:(id)data error:(NSError**)error {
    // fail eager if not valid object
    if (![_encoder isValid:data]) {
        if (error)
            *error = [self constructError:@"save" msg:@"not a valid format for the type specified"];
        
        return NO;
    }
    
    return [super save:data error:error] && [self updateStore:error];
}

-(BOOL) reset:(NSError**)error {
    return [super reset:error] && [self updateStore:error];
}

-(BOOL) remove:(id)record error:(NSError**)error {
    return [super remove:record error:error] && [self updateStore:error];
}

// =====================================================
// =========== private utility methods  ================
// =====================================================

-(BOOL) updateStore:(NSError **)error {
    NSData *plist = [_encoder encode:_array error:error];
    
    if (!plist)
        return NO;
    
    // since 'NSData:writeToFile' fails silently, constuct an
    // error object to inform client
    if (![plist writeToURL:_file atomically:YES]) {
        if (error)
            *error = [self constructError:@"save" msg:@"an error occurred during save!"];

        return NO;
    }
    
    // if we reach here, file was saved successfully
    return YES;
}

-(NSURL*) storeURLWithName:(NSString*) name {
    // access 'Application Support' directory
    NSURL *supportURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                               inDomain:NSUserDomainMask appropriateForURL:nil
                                                                 create:YES error:nil];
    // the filename is based on this store name
    return [supportURL URLByAppendingPathComponent:name];
}

@end
