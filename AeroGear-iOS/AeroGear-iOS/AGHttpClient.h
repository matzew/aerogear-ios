//
//  AGHttpClient.h
//  AeroGear-iOS
//
//  Created by matzew on 21.08.12.
//  Copyright (c) 2012 JBoss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface AGHttpClient : AFHTTPClient

+ (AGHttpClient *)sharedClientFor:(NSURL *)url;

@end
