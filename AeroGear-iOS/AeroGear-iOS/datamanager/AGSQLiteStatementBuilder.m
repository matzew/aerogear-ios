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

+ (AGSQLiteStatementBuilder *)sharedInstance {
    static AGSQLiteStatementBuilder *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

-(NSString *)buildInsertStatementWithData:(NSDictionary *)data forStore:(NSString *)storeName {
    NSMutableString *statement = nil;
    
    if([data count] != 0 && storeName != nil && [storeName isKindOfClass:[NSString class]]) {
        statement = [NSMutableString stringWithFormat:@"insert into %@ values (\"", storeName];
        
        
        NSEnumerator *columnNames = [data keyEnumerator];
        NSString *columnName = nil;
        
        while ((columnName = [columnNames nextObject])) {
            [statement appendFormat:@"%@\", \"", data[columnName]];
        }
        
        [statement deleteCharactersInRange:NSMakeRange([statement length]- 3, 3)];
        [statement appendFormat:@");"];
    }
    return statement;
}

-(NSString *)buildCreateStatementWithData:(NSDictionary *)data forStore:(NSString *)storeName {
    NSMutableString *statement = nil;
    
    if([data count] != 0 && storeName != nil && [storeName isKindOfClass:[NSString class]]) {
        statement = [NSMutableString stringWithFormat:@"create table %@ (", storeName];
        
        
        NSEnumerator *columnNames = [data keyEnumerator];
        NSString *columnName = nil;
        
        while ((columnName = [columnNames nextObject])) {
            [statement appendFormat:@"%@ text, ", columnName];
        }
        
        [statement deleteCharactersInRange:NSMakeRange([statement length]- 2, 2)];
        [statement appendFormat:@");"];
    }
    return statement;
}

-(NSString *) buildDropStatementForStore:(NSString *)storeName {
    NSMutableString *statement = nil;
    if(storeName != nil && [storeName isKindOfClass:[NSString class]]) {
        statement = [NSMutableString stringWithFormat:@"drop table %@;", storeName];
    }
    return statement;
}

-(NSString *) buildDeleteStatementForId:(id)record forStore:(NSString *)storeName {
    NSMutableString *statement = nil;
    
    if(record != nil && storeName != nil && [storeName isKindOfClass:[NSString class]]) {
        statement = [NSMutableString stringWithFormat:@"delete from %@ where oid = \"%@\"", storeName, record];
    }
    return statement;
}

@end
