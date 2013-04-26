//
//  ObjectMap.m
//  JSObjCDemo
//
//  Created by confidence on 10/03/2013.
//  Copyright (c) 2013 confidenceJuice. All rights reserved.
//

#import "KVMap.h"

@implementation KVMap

-(id)initWithKeyTransformationBlock:(NSString *(^)(NSString *))keyTransformationBlock valueTransformationBlock:(id (^)(id))valueTransformationBlock{
    
    if (self==[super init]) {
        self.keyTransformationBlock=keyTransformationBlock;
        self.valueTransformationBlock=valueTransformationBlock;
    }
    return self;
}

@end
