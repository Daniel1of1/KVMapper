//
//  ObjectMap.h
//  JSObjCDemo
//
//  Created by confidence on 10/03/2013.
//  Copyright (c) 2013 confidenceJuice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KVMap : NSObject

//@property (nonatomic, strong) NSString *externalKey;
//@property (nonatomic, strong) NSString *internalKey;
@property (nonatomic, copy) NSString *(^keyTransformationBlock)(NSString *);
@property (nonatomic, copy) id (^valueTransformationBlock)(id);

@end
