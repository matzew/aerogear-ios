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

#import "AGSQLiteStorage.h"
#import "AGSQLiteStatementBuilder.h"

@implementation AGSQLiteStorage {
    NSString* _databaseName;
    NSString* _path;
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
        _type = @"SQLITE";
        
        AGStoreConfiguration* config = (AGStoreConfiguration*) storeConfig;
        _recordId = config.recordId;
        
        // extract file path
        _path = [self getFilePath];
        _databaseName = config.name;

        // if file exists open DB, if file not exist create an empty one
        _database = [FMDatabase databaseWithPath:[NSString stringWithFormat:@"%@.sqlite3", [_path stringByAppendingPathComponent:_databaseName]]];
        NSLog(@"Database in %@",[_path stringByAppendingPathComponent:_databaseName]);
    }
    
    return self;
}

-(NSError *) constructError:(NSString*) domain
                        msg:(NSString*) msg {
    
    NSError* error = [NSError errorWithDomain:[NSString stringWithFormat:@"org.aerogear.stores.%@", domain]
                                         code:0
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:msg,
                                               NSLocalizedDescriptionKey, nil]];
    
    return error;
}

// =====================================================
// ======== public API (AGStore)                ========
// =====================================================

-(NSArray*) readAll {
    NSString *query = [NSString stringWithFormat:@"select oid, * from %@", _databaseName];
    NSArray* results = [self readWithQuery:query];
    return results;
}

-(id) read:(id)recordId {
    NSString *query = [NSString stringWithFormat:@"select oid, * from %@ where oid=%@", _databaseName, recordId];
    NSArray* results = [self readWithQuery:query];
    if ([results count] == 0) {
        return nil;
    } else {
        return results[0];
    }
}

-(NSArray*) filter:(NSPredicate*)predicate {
    NSArray* results = [self readAll];
    return [results filteredArrayUsingPredicate:predicate];
}


-(BOOL) save:(id)data error:(NSError**)error {
    BOOL statusCode = YES;
    // a 'collection' of objects:
    if ([data isKindOfClass:[NSArray class]]) {
        // fail fast if the array contains non-dictionary objects
        for (id record in data) {
            if (![record isKindOfClass:[NSDictionary class]]) {
                if (error) {
                    *error = [self constructError:@"save" msg:@"array contains non-dictionary objects!"];
                    return NO;
                }
            }
        }

        if ([data count] != 0) {
            statusCode = [self createTableWith: data[0]];
        } else {
            if (error) {
                *error = [self constructError:@"save" msg:@"create table failed"];
            }
        }
        for (id record in data) {
            statusCode = [self saveOne:record];
            if (!statusCode && error) {
                *error = [self constructError:@"save" msg:@"insert into table failed"];
            }
        }
        
    } else if([data isKindOfClass:[NSDictionary class]]) {
        // single obj:
        statusCode = [self createTableWith: data];
        if (statusCode) {
            statusCode = [self saveOne:data];
            if (!statusCode && error) {
                *error = [self constructError:@"save" msg:@"insert into table failed"];
            }
        } else {
            if (error) {
                *error = [self constructError:@"save" msg:@"create table failed"];
            }
        }
        
    } else { // not a dictionary, fail back
        if (error) {
            *error = [self constructError:@"save" msg:@"dictionary objects are supported only"];
            return NO;
        }
    }
    
    return statusCode;
}

//private save for one item:
-(BOOL) saveOne:(NSDictionary*)data {
    BOOL statusCode = YES;
    NSString *insertStatement = [[AGSQLiteStatementBuilder sharedInstance] buildInsertStatementWithData:data forStore:_databaseName];
       
    [_database open];
    statusCode = [_database executeUpdate:insertStatement];
    
    int lastId = [_database lastInsertRowId];
    [data setValue:[NSString stringWithFormat:@"%d", lastId] forKey:_recordId];
    [_database close];
    return statusCode;
}

// create if not exist
-(BOOL) createTableWith:(NSDictionary*)data {
    BOOL statusCode = YES;
    NSString *createStatement = [[AGSQLiteStatementBuilder sharedInstance] buildCreateStatementWithData:data forStore:_databaseName];
    [_database open];
    if (createStatement != nil) {
        [_database executeUpdate:createStatement];
    } else {
        statusCode = NO;
    }
    [_database close];
    return statusCode;
}


-(BOOL) reset:(NSError**)error {
    BOOL statusCode = YES;
    NSString *dropStatement = [[AGSQLiteStatementBuilder sharedInstance] buildDropStatementForStore:_databaseName];
    [_database open];
    if (dropStatement != nil) {
         [_database executeUpdate:dropStatement];
    } else {
        statusCode = NO;
        if (!statusCode && error) {
            *error = [self constructError:@"reset" msg:@"drop table failed"];
        }
    }
    [_database close];
    return statusCode;
}

-(BOOL) isEmpty {
    NSArray *all = [self readAll];
    if ([all count] == 0) {
        return YES;
    }
    return NO;
}

-(BOOL) remove:(id)record error:(NSError**)error {
    BOOL statusCode = YES;
    NSString *deleteStatement = [[AGSQLiteStatementBuilder sharedInstance] buildDeleteStatementForId:record forStore:_databaseName];
    [_database open];
    if (deleteStatement != nil) {
        [_database executeUpdate:deleteStatement];
    } else {
        statusCode = NO;
        if (!statusCode && error) {
            *error = [self constructError:@"reset" msg:@"drop table failed"];
        }
    }
    [_database close];
    return statusCode;
}


//-(BOOL) remove:(id)record error:(NSError**)error {
    
//    BOOL success = [super remove:record error:error];
//    
//    if (!success)
//        return FALSE;
//    
//    if (![_array writeToFile:_file atomically:YES]) {
//        if (error) {
//            *error = [self constructError:@"remove" msg:@"error on remove"];
//            return FALSE;
//        }
//    }
    
//    return YES;
//}

// =====================================================
// =========== private utility methods  ================
// =====================================================

// TODO common part with AGPropertyListStorage::storeFilePathWithName
-(NSString*) getFilePath {
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
    return documentsDirectory;
    
}

-(NSArray*) readWithQuery:(NSString*) query {
    [_database open];
    
    NSMutableArray *results = [NSMutableArray array];
    FMResultSet *myResults = [_database executeQuery:query];
    while ([myResults next]) {
        [results addObject:[myResults resultDictionary]];
    }
    
    [_database close];
    return results;
}

@end
