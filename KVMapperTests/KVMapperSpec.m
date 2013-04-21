//
//  NewKiwiSpec.m
//  KVMapper
//
//  Created by confidence on 02/04/2013.
//  Copyright 2013 confidenceJuice. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "KVMapper.h"
#import "KVMap.h"
#import "TestPerson.h"
#import "TestAddress.h"
#import "NSObject+introspect.h"
#import "Transformers.h"

@interface NSObject (constructors)

+(instancetype)objectWithDictionary:(NSDictionary *)dictionary;

@end

@implementation NSObject (constructors)

#pragma mark +construct

+(instancetype)objectWithDictionary:(NSDictionary *)dictionary{
    return [[self alloc] initWithDictionary:dictionary];
}

#pragma mark -initialise
-(id)initWithDictionary:(NSDictionary *)dictionary{
    if (self ==[self init]) {
        [self populateWithDictionary:dictionary];
    }
    return self;
}

#pragma mark -init

-(NSDictionary *)objectAsDictionary{
    return [self propertiesDict];
}

#pragma mark -update values
-(void)populateWithDictionary:(NSDictionary *)dictionary{
    [self setValuesForKeysWithDictionary:dictionary];
}

-(void)populateWithDictionary:(NSDictionary *)dictionary map:(NSDictionary *)objectMap{
    
    NSDictionary *amappedDict=[KVMapper mappedDictionaryWithDictionary:dictionary ObjectMap:objectMap];
    
    [self setValuesForKeysWithDictionary:amappedDict];
}

-(void)updateWithObject:(NSObject *)object{
    [self setValuesForKeysWithDictionary:[object propertiesDict]];
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

@end

SPEC_BEGIN(KVMapperSpec)

describe(@"object mapper", ^{
    
    NSDictionary *correctDict=@{@"firstName" : @"bob", @"LastName" : @"smith", @"middle_name" : @"middle" , @"mySUPERmiddleNaMe" : @"super-middley", @"address" : @{@"street_name" : @"love street", @"house_number" : @123} , @"arrayOfStuff" : @[@1,@2,@3,@4], @"array_of_addresses":@[@{@"street_name" : @"love street", @"house_number" : @14354},@{@"street_name" : @"love street", @"house_number" : @123}]};
    
    NSDictionary *addressDict=@{@"street_name" : @"love street", @"house_number" : @123};
    
    TestPerson *correctPerson=[[TestPerson alloc] init];
    TestAddress *testAddy=[TestAddress objectWithDictionary:addressDict];
    correctPerson.firstName=@"bob";
    correctPerson.lastName=@"smith";
    correctPerson.address=testAddy;
    
    it(@"creates correct key transformation kvmaps", ^{
        NSString *(^correctKeyTransformerBlock)(NSString *)=^(NSString *inKey){
            return [Transformers normalizedKey:inKey];
        };
        
        NSDictionary *personMappingDict=[KVMapper KVMapsForKeys:correctDict.allKeys defaultKeyTransformer:correctKeyTransformerBlock];
        
        //we get the right keys
        [[correctDict.allKeys should] equal:personMappingDict.allKeys];
        
        //it sets the right mapping
        for(NSString *key in personMappingDict){
            KVMap *kvMap=personMappingDict[key];
            [[kvMap.keyTransformationBlock(key) should] equal:correctKeyTransformerBlock(key)];
        }
    });
    
    it(@"applies kvMap keyValue transformations", ^{
        NSDictionary *dictToBeMapped=@{
        @"firstThing" : @4,
        @"secondThing": @"blah"
        };
        
        NSDictionary *correctDict=@{
        @"firstThingabc" : @5,
        @"secondThingdef": @[@1,@"asdf"]
        };
        
        KVMap *mapForFirstThing=[[KVMap alloc] init];
        mapForFirstThing.valueTransformationBlock=(id)^(NSNumber *value){
            return [NSNumber numberWithInteger:value.integerValue+1];
        };
        mapForFirstThing.keyTransformationBlock=^(NSString *inKey){
            return [NSString stringWithFormat:@"%@abc",inKey];
        };
        
        KVMap *mapForSecondThing=[[KVMap alloc] init];
        mapForSecondThing.valueTransformationBlock=(id)^(NSNumber *value){
            return @[@1,@"asdf"];
        };
        mapForSecondThing.keyTransformationBlock=^(NSString *inKey){
            return [NSString stringWithFormat:@"%@def",inKey];
        };
        
        NSDictionary *kvMappingsDict=@{
        @"firstThing" : mapForFirstThing,
        @"secondThing" : mapForSecondThing
        };
        
        NSDictionary *testDict=[KVMapper mappedDictionaryWithDictionary:dictToBeMapped ObjectMap:kvMappingsDict];
        
        [[testDict should] equal:correctDict];
    });
    
    it(@"should correctly map a dictionary to a dictionary", ^{
        //this is the dict you'll get from the json
        NSDictionary *dictToMap=@{@"firstName" : @"bob", @"LastName" : @"smith", @"middle_name" : @"middle" , @"mySUPERmiddleNaMe" : @"super-middley", @"address" : @{@"street_name" : @"love street", @"house_number" : @123} , @"arrayOfStuff" : @[@1,@2,@3,@4], @"array_of_addresses":@[@{@"street_name" : @"love street", @"house_number" : @14354},@{@"street_name" : @"love street", @"house_number" : @123}]};
        
        //basic mapping
        NSMutableDictionary *personMapping=[[KVMapper KVMapsForKeys:dictToMap.allKeys defaultKeyTransformer:^NSString *(NSString *inKey) {
            return [Transformers normalizedKey:inKey];
        }] mutableCopy];
        
        //mappingDict for address class
        NSMutableDictionary *addressMappingDict=[[KVMapper KVMapsForKeys:@[@"street_name",@"house_number"] defaultKeyTransformer:^NSString *(NSString *inKey) {
            return [Transformers normalizedKey:inKey];
        }] mutableCopy];
        
        //map for address key
        KVMap *addressMap=[[KVMap alloc] init];
        addressMap.valueTransformationBlock=(id)^(NSDictionary *inputDict){
            NSDictionary *properAddressDict=[KVMapper mappedDictionaryWithDictionary:inputDict ObjectMap:addressMappingDict];
            return [TestAddress objectWithDictionary:properAddressDict];
        };
        
        //mapping for superMiddleName
        KVMap *superMiddleNameMap=[[KVMap alloc] init];
        superMiddleNameMap.keyTransformationBlock=^(NSString *inputKey){return @"mySuperMiddleName";};
        
        //mapping for addrassArray
        KVMap *addressArrayMap=[[KVMap alloc] init];
        addressArrayMap.keyTransformationBlock=^(NSString *inputKey){return [Transformers normalizedKey:inputKey];};
        
        addressArrayMap.valueTransformationBlock=(id)^(NSArray *input){
            NSMutableArray *newArray=[NSMutableArray array];
            for (id object in input) {
                [newArray addObject:[TestAddress objectWithDictionary:[KVMapper mappedDictionaryWithDictionary:object ObjectMap:addressMappingDict]]];
            }
            return newArray;
        };
        
        
        NSDictionary *objectMapperDict=@{
        @"mySUPERmiddleNaMe" : superMiddleNameMap,
        @"address" : addressMap,
        @"array_of_addresses" : addressArrayMap
        };
        
        [personMapping addEntriesFromDictionary:objectMapperDict];
        
        
        NSDictionary *correctDict=@{@"firstName" : @"bob", @"lastName" : @"smith", @"middleName" : @"middle" , @"mySuperMiddleName" : @"super-middley", @"address" :[TestAddress objectWithDictionary:@{@"streetName" : @"love street", @"houseNumber" : @123}]  , @"arrayOfStuff" : @[@1,@2,@3,@4], @"arrayOfAddresses":@[[TestAddress objectWithDictionary:@{@"streetName" : @"love street", @"houseNumber" : @14354}],[TestAddress objectWithDictionary:@{@"streetName" : @"love street", @"houseNumber" : @123}]]};
        
        NSDictionary *mappedDict=[KVMapper mappedDictionaryWithDictionary:dictToMap ObjectMap:personMapping];
        
        for(NSString *key in correctDict){
            id obj1=mappedDict[key];
            id obj2=correctDict[key];
            [[obj1 should] equal:obj2];
        }
    });
});


SPEC_END


