//
//  ObjectMap.m
//  JSObjCDemo
//
//  Created by confidence on 10/03/2013.
//  Copyright (c) 2013 confidenceJuice. All rights reserved.
//

#import "KVMap.h"

@implementation KVMap

-(id)initWithKeyTransformationBlock:(NSString *(^)(NSString * inputString))keyTransformationBlock valueTransformationBlock:(id (^)(id inputObject))valueTransformationBlock{
    return [self initWithKeyTransformationBlock:keyTransformationBlock valueTransformationBlock:valueTransformationBlock removeNulls:FALSE];
}

-(id)initWithKeyTransformationBlock:(NSString *(^)(NSString *inputString))keyTransformationBlock valueTransformationBlock:(id (^) (id inputObject))valueTransformationBlock removeNulls:(BOOL)removeNulls{
    if (self=[super init]) {
        _keyTransformationBlock=keyTransformationBlock;
        _valueTransformationBlock=valueTransformationBlock;
        _removeNulls=removeNulls;
    }
    return self;
}

@end
