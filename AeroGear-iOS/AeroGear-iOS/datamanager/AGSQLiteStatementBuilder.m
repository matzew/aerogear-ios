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

#import "AGSQLiteStatementBuilder.h"

@implementation AGSQLiteStatementBuilder
NSString *_storeName = nil;
NSString *_primaryKey = nil;

+ (AGSQLiteStatementBuilder *)sharedInstance {
    static AGSQLiteStatementBuilder *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

-(id)initWithStoreName:(NSString *)storeName andPrimaryKeyName:(NSString *)key {
    self = [super init];
    if (self) {
        _storeName = storeName;
        _primaryKey = key;
    }
    return self;
}

-(NSString *) buildSelectStatementWithPrimaryKeyValue:(NSString*)value {
    NSString *statement = nil;
    if (_primaryKey && value) {
        statement =[ NSString stringWithFormat:@"select value from %@ where %@=%@", _storeName, _primaryKey, value];
    } else {
        statement = [NSString stringWithFormat:@"select value from %@", _storeName];
    }
    return statement;
}

-(NSString *)buildInsertStatementWithData:(NSDictionary *)data {
    NSString *statement = nil;
    
    if([data count] != 0 && _storeName != nil && [_storeName isKindOfClass:[NSString class]]) {
        NSEnumerator *columnNames = [data keyEnumerator];
        NSString* primaryKeyValue = nil;
        for (NSString* col in columnNames) {
            if([col isEqualToString:_primaryKey]) {
                primaryKeyValue = data[col];
            }
        }
        NSData* json = [NSJSONSerialization dataWithJSONObject:data
                                                       options:NO
                                                         error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        
        statement =[NSString stringWithFormat:@"insert into %@ values (%@,'%@')", _storeName, primaryKeyValue, jsonString];
    }
    return statement;
}

-(NSString *)buildUpdateStatementWithData:(NSDictionary *)data {
    NSString *statement = nil;
    
    if([data count] != 0 && _storeName != nil && [_storeName isKindOfClass:[NSString class]]) {
        NSEnumerator *columnNames = [data keyEnumerator];
        NSString* primaryKeyValue = nil;
        for (NSString* col in columnNames) {
            if([col isEqualToString:_primaryKey]) {
                primaryKeyValue = data[col];
            }
        }
        if (primaryKeyValue == nil) {
            return nil;
        }
        
        NSData* json = [NSJSONSerialization dataWithJSONObject:data
                                                       options:NO
                                                         error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        
        statement = [NSString stringWithFormat:@"update %@ set value =  '%@' where id = %@", _storeName, jsonString, primaryKeyValue];
    }
    return statement;
}

-(NSString *)buildCreateStatementWithData:(NSDictionary *)data {
    NSMutableString *statement = nil;
    
    if([data count] != 0 && _storeName != nil && [_storeName isKindOfClass:[NSString class]]) {
        statement = [NSMutableString stringWithFormat:@"create table %@ (", _storeName];
        
        NSEnumerator *columnNames = [data keyEnumerator];
        BOOL primaryKeyFound = NO;
        for (NSString* col in columnNames) {
            if([col isEqualToString:_primaryKey]) {
                [statement appendFormat:@"%@ integer primary key asc, ", col];
                primaryKeyFound = YES;
            }
        }

        if (!primaryKeyFound) {
           [statement appendFormat:@"%@ integer primary key asc, ", _primaryKey];
        }
        [statement appendFormat:@"value text, "];
        
        [statement deleteCharactersInRange:NSMakeRange([statement length]- 2, 2)];
        [statement appendFormat:@");"];
    }
    return statement;
}

-(NSString *) buildDropStatement {
    NSMutableString *statement = nil;
    if(_storeName != nil && [_storeName isKindOfClass:[NSString class]]) {
        statement = [NSMutableString stringWithFormat:@"drop table %@;", _storeName];
    }
    return statement;
}

-(NSString *) buildDeleteStatementForId:(id)record {
    NSMutableString *statement = nil;
    
    if(record != nil && _storeName != nil && [_storeName isKindOfClass:[NSString class]]) {
        statement = [NSMutableString stringWithFormat:@"delete from %@ where %@ = \"%@\"", _storeName, _primaryKey, record];
    }
    return statement;
}

@end
