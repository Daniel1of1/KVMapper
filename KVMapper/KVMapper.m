//
//  ObjectMapper.m
//  JSObjCDemo
//
//  Created by confidence on 10/03/2013.
//  Copyright (c) 2013 confidenceJuice. All rights reserved.
//

#import "KVMapper.h"
#import "KVMap.h"
#import "NSObject+introspect.h"

@implementation KVMapper

+(NSDictionary *)mappingDictionaryForKeys:(NSArray *)keys defaultKeyTransformer:(NSString *(^)(NSString *))defaultKeyTransformationBlock{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    for (NSString *key in keys) {
        KVMap *kvMap=[[KVMap alloc] init];
        kvMap.keyTransformationBlock=defaultKeyTransformationBlock;
        [dict setValue:kvMap forKey:key];
    }
    return dict;
}

+(NSDictionary *)mappingDictionaryForKeys:(NSArray *)keys defaultKeyTransformer:(NSString *(^)(NSString *))defaultKeyTransformationBlock defaultValueTransformer:(id (^)(id))defaultValueTransformationBlock{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    for (NSString *key in keys) {
        KVMap *kvMap=[[KVMap alloc] init];
        kvMap.keyTransformationBlock=defaultKeyTransformationBlock;
        kvMap.valueTransformationBlock=defaultValueTransformationBlock;
        [dict setValue:kvMap forKey:key];
    }
    return dict;
}

+(NSDictionary *)mappedKey:(NSString *)key andValue:(id)value withMapping:(KVMap *)objectMap{
    NSString *mappedKey=objectMap.keyTransformationBlock ?objectMap.keyTransformationBlock(key): key;
    id mappedValue=objectMap.valueTransformationBlock ?objectMap.valueTransformationBlock(value): value;
    
    NSDictionary *dict=@{mappedKey : mappedValue};
    
    return dict;
}

+(NSDictionary *)mappedDictionaryWithInputDictionary:(NSDictionary *)inputDict mappingDictionary:(NSDictionary *)mappingDict{
    
    NSMutableDictionary *mappedDict=[NSMutableDictionary dictionary];
    
    [inputDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        //create the new key-value pair
        NSDictionary *mappedKVPair=[self mappedKey:key andValue:obj withMapping:mappingDict[key]];
        // add the new value to our new dictionary
        [mappedDict addEntriesFromDictionary:mappedKVPair];
        
    }];
    
    return mappedDict;
}

+(NSDictionary *)dictionaryFromObject:(id)inputObject mappingDictionary:(NSDictionary *)mappingDictionary{
    NSDictionary *dict=[inputObject propertiesDict];
    
    return [self mappedDictionaryWithInputDictionary:dict mappingDictionary:mappingDictionary];

}

+(id)objectFromDictionary:(NSDictionary *)inputDictionay mappingDictionary:(NSDictionary *)mappingDict class:(__unsafe_unretained Class)class{
    NSDictionary *mappedDict=[self mappedDictionaryWithInputDictionary:inputDictionay mappingDictionary:mappingDict];
    id object=[[class alloc] init];
    [object setValuesForKeysWithDictionary:mappedDict];
    return object;
}

@end
