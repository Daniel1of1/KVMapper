//
//  ObjectMapper.h
//  JSObjCDemo
//
//  Created by confidence on 10/03/2013.
//  Copyright (c) 2013 confidenceJuice. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KeyMapping;

@interface KVMapper : NSObject

@property (nonatomic, strong) NSDictionary *objectMaps;

+(NSDictionary *)mappingDictionaryForKeys:(NSArray *)keys defaultKeyTransformer:(NSString *(^)(NSString *))defaultKeyTransformationBlock;
+(NSDictionary *)mappingDictionaryForKeys:(NSArray *)keys defaultKeyTransformer:(NSString *(^)(NSString *))defaultKeyTransformationBlock defaultValueTransformer:(id (^)(id))defaultValueTransformationBlock;

+(NSDictionary *)mappedDictionaryWithInputDictionary:(NSDictionary *)inputDict mappingDictionary:(NSDictionary *)mappingDict;

+(NSDictionary *)dictionaryFromObject:(id)inputObject mappingDictionary:(NSDictionary *)mappingDictionary;

@end