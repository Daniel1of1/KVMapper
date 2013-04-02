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

@property (nonatomic, strong) NSString *(^defaultKeyTransformationBlock)(NSString *);
@property (nonatomic, strong) id (^defaultValueTransformerBlock)(id);
@property (nonatomic, strong) NSDictionary *objectMaps;

-(NSDictionary *)mappedDictionary:(NSDictionary *)externalDict withKeyMappings:(NSDictionary *)keyMapppings;

-(NSDictionary *)mappedKey:(NSString *)key andValue:(id)value withMapping:(KeyMapping *)keyMapThing;

-(NSDictionary *)mappedDictionaryWithDictionary:(NSDictionary *)externalDict ObjectMap:(NSDictionary *)objectMapsDict;

+(NSDictionary *)KVMapsForKeys:(NSArray *)keys defaultKeyTransformer:(NSString *(^)(NSString *))defaultKeyTransformationBlock;

+(NSDictionary *)mappedDictionaryWithDictionary:(NSDictionary *)externalDict ObjectMap:(NSDictionary *)objectMapsDict;

+(void)applyMap:(NSDictionary *)map toDictionary:(NSDictionary *)dictionary;
@end