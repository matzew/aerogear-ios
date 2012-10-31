//
//  AGPipeConfiguration.h
//  AeroGear-iOS
//
//  Created by matzew on 30.10.12.
//  Copyright (c) 2012 JBoss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGPipeConfig.h"

/**
 * The internal implementation of the AGPipeConfig to configure AGPipe objects.
 */
@interface AGPipeConfiguration : NSObject <AGPipeConfig>


// private getters...
-(NSString*) name;
-(NSString*) type;
-(NSURL*) baseURL;
-(NSString*) endpoint;
-(id<AGAuthenticationModule>) authModule;

@end
