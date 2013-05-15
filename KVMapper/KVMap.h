//
//  ObjectMap.h
//  JSObjCDemo
//
//  Created by confidence on 10/03/2013.
//  Copyright (c) 2013 confidenceJuice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KVMap : NSObject

@property (nonatomic, copy) NSString *(^keyTransformationBlock)(NSString *);
@property (nonatomic, copy) id (^valueTransformationBlock)(id);
@property (nonatomic) BOOL removeNulls;

-(id)initWithKeyTransformationBlock:(NSString *(^)(NSString *))keyTransformationBlock valueTransformationBlock:(id (^) (id))valueTransformationBlock;
-(id)initWithKeyTransformationBlock:(NSString *(^)(NSString *))keyTransformationBlock valueTransformationBlock:(id (^) (id))valueTransformationBlock removeNulls:(BOOL)removeNulls;

@end
