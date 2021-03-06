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
    
    NSDictionary *amappedDict=[KVMapper mappedDictionaryWithInputDictionary:dictionary mappingDictionary:objectMap];
    
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
            return [Transformers snakeToLlamaCase:inKey];
        };
        
        NSDictionary *personMappingDict=[KVMapper mappingDictionaryForKeys:correctDict.allKeys defaultKeyTransformer:correctKeyTransformerBlock];
        
        //we get the right keys
        [[correctDict.allKeys should] equal:personMappingDict.allKeys];
        
        //it sets the right mapping
        for(NSString *key in personMappingDict){
            KVMap *kvMap=personMappingDict[key];
            [[kvMap.keyTransformationBlock(key) should] equal:correctKeyTransformerBlock(key)];
        }
    });
    
    it(@"creates correct key and value transformation kvmaps", ^{
        NSString *(^correctKeyTransformerBlock)(NSString *)=^(NSString *inKey){
            return [Transformers snakeToLlamaCase:inKey];
        };
        
        id (^correctValueTransformationBlock)(id)=^(id inValue){
            NSURL *url=[NSURL URLWithString:inValue];
            return url;
        };
        
        NSDictionary *testDict=@{
                                 @"some_key_one": @"https://thishouldbeaurlone.com",
                                 @"some_key_two": @"https://thishouldbeaurltwo.com",
                                 @"some_key_three": @"https://thishouldbeaurlthree.com",
                                 @"some_key_four": @"https://thishouldbeaurlfour.com"
                                 };
        
        NSDictionary *personMappingDict=[KVMapper mappingDictionaryForKeys:testDict.allKeys defaultKeyTransformer:correctKeyTransformerBlock defaultValueTransformer:correctValueTransformationBlock];
        
        //we get the right keys
        [[testDict.allKeys should] equal:personMappingDict.allKeys];
        
        //it sets the right mapping
        for(NSString *key in personMappingDict){
            KVMap *kvMap=personMappingDict[key];
            [[kvMap.keyTransformationBlock(key) should] equal:correctKeyTransformerBlock(key)];
            id transformedVal=kvMap.valueTransformationBlock(testDict[key]);
            id correctVal=correctValueTransformationBlock(testDict[key]);
            [[transformedVal should] equal:correctVal];
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
        
        NSDictionary *testDict=[KVMapper mappedDictionaryWithInputDictionary:dictToBeMapped mappingDictionary:kvMappingsDict];
        
        [[testDict should] equal:correctDict];
    });
    
    it(@"should correctly map a dictionary to a dictionary", ^{
        //this is the dict you'll get from the json
        NSDictionary *dictToMap=@{@"firstName" : @"bob", @"LastName" : @"smith", @"middle_name" : @"middle" , @"mySUPERmiddleNaMe" : @"super-middley", @"address" : @{@"street_name" : @"love street", @"house_number" : @123} , @"arrayOfStuff" : @[@1,@2,@3,@4], @"array_of_addresses":@[@{@"street_name" : @"love street", @"house_number" : @14354},@{@"street_name" : @"love street", @"house_number" : @123}]};
        
        //basic mapping
        NSMutableDictionary *personMapping=[[KVMapper mappingDictionaryForKeys:dictToMap.allKeys defaultKeyTransformer:^NSString *(NSString *inKey) {
            return [Transformers snakeToLlamaCase:inKey];
        }] mutableCopy];
        
        //mappingDict for address class
        NSMutableDictionary *addressMappingDict=[[KVMapper mappingDictionaryForKeys:@[@"street_name",@"house_number"] defaultKeyTransformer:^NSString *(NSString *inKey) {
            return [Transformers snakeToLlamaCase:inKey];
        }] mutableCopy];
        
        //map for address key
        KVMap *addressMap=[[KVMap alloc] init];
        addressMap.valueTransformationBlock=(id)^(NSDictionary *inputDict){
            NSDictionary *properAddressDict=[KVMapper mappedDictionaryWithInputDictionary:inputDict mappingDictionary:addressMappingDict];
            return [TestAddress objectWithDictionary:properAddressDict];
        };
        
        //mapping for superMiddleName
        KVMap *superMiddleNameMap=[[KVMap alloc] init];
        superMiddleNameMap.keyTransformationBlock=^(NSString *inputKey){return @"mySuperMiddleName";};
        
        //mapping for addrassArray
        KVMap *addressArrayMap=[[KVMap alloc] init];
        addressArrayMap.keyTransformationBlock=^(NSString *inputKey){return [Transformers snakeToLlamaCase:inputKey];};
        
        addressArrayMap.valueTransformationBlock=(id)^(NSArray *input){
            NSMutableArray *newArray=[NSMutableArray array];
            for (id object in input) {
                [newArray addObject:[TestAddress objectWithDictionary:[KVMapper mappedDictionaryWithInputDictionary:object mappingDictionary:addressMappingDict]]];
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
        
        NSDictionary *mappedDict=[KVMapper mappedDictionaryWithInputDictionary:dictToMap mappingDictionary:personMapping];
        
        for(NSString *key in correctDict){
            id obj1=mappedDict[key];
            id obj2=correctDict[key];
            [[obj1 should] equal:obj2];
        }
    });
    
    it(@"can accept an object to map to a dictionary", ^{
        
        KVMap *streetNameMap=[[KVMap alloc] initWithKeyTransformationBlock:^NSString *(NSString *inputString) {
            return @"street_name";
        } valueTransformationBlock:nil];
        
        KVMap *houseNumMap=[[KVMap alloc] initWithKeyTransformationBlock:nil valueTransformationBlock:^id(id inputValue) {
            return [NSNumber numberWithInt:[inputValue intValue]+1];
        }];

        
        NSDictionary *objectMapperDict=@{@"streetName" : streetNameMap,
                                         @"houseNumber" : houseNumMap};
        
        NSDictionary *correctDict=@{@"street_name" : @"Batman avenue",
                                    @"houseNumber" : @2};

        TestAddress *testAddress =[[TestAddress alloc] init];
        testAddress.streetName=@"Batman avenue";
        testAddress.houseNumber=@1;
        NSDictionary *dictFromObject=[KVMapper dictionaryFromObject:testAddress mappingDictionary:objectMapperDict];
        
        [[dictFromObject should] equal:correctDict];
        
    });
    
    
    it(@"can map dictionary to an object", ^{
        
        KVMap *streetNameMap=[[KVMap alloc] initWithKeyTransformationBlock:^NSString *(NSString *inputString) {
            return @"streetName";
        } valueTransformationBlock:nil];
        
        KVMap *houseNumMap=[[KVMap alloc] initWithKeyTransformationBlock:nil valueTransformationBlock:^id(id inputValue) {
            return [NSNumber numberWithInt:[inputValue intValue]-1];
        }];
        
        TestAddress *correctAddress =[[TestAddress alloc] init];
        correctAddress.streetName=@"Batman avenue";
        correctAddress.houseNumber=@1;
        
        NSDictionary *inputDict=@{@"street_name" : @"Batman avenue",
                                    @"houseNumber" : @2};

        
        NSDictionary *objectMapperDict=@{@"street_name" : streetNameMap,
                                         @"houseNumber" : houseNumMap};
        
        TestAddress *objectFromDict=(TestAddress *)[KVMapper objectFromDictionary:inputDict mappingDictionary:objectMapperDict class:[TestAddress class]];
        
        [[objectFromDict should] equal:correctAddress];
        
    });
    
    
    it(@"can map NSNulls to nils", ^{
        
        NSDictionary *dictToMap=@{@"firstName" : @"bob", @"LastName" : @"smith", @"middle_name" : @"middle" , @"mySUPERmiddleNaMe" : @"super-middley", @"address" : [NSNull null] , @"arrayOfStuff" : @[@1,@2,@3,@4], @"array_of_addresses":@[@{@"street_name" : @"love street", @"house_number" : @14354},@{@"street_name" : @"love street", @"house_number" : @123}]};

        
        //basic mapping
        NSMutableDictionary *personMapping=[[KVMapper mappingDictionaryForKeys:dictToMap.allKeys defaultKeyTransformer:^NSString *(NSString *inKey) {
            return [Transformers snakeToLlamaCase:inKey];
        }] mutableCopy];
        
        //mappingDict for address class
        NSMutableDictionary *addressMappingDict=[[KVMapper mappingDictionaryForKeys:@[@"street_name",@"house_number"] defaultKeyTransformer:^NSString *(NSString *inKey) {
            return [Transformers snakeToLlamaCase:inKey];
        }] mutableCopy];
        
        //map for address key
        KVMap *addressMap=[[KVMap alloc] init];
        addressMap.valueTransformationBlock=(id)^(NSDictionary *inputDict){
            NSDictionary *properAddressDict=[KVMapper mappedDictionaryWithInputDictionary:inputDict mappingDictionary:addressMappingDict];
            return [TestAddress objectWithDictionary:properAddressDict];
        };
        
        //mapping for superMiddleName
        KVMap *superMiddleNameMap=[[KVMap alloc] init];
        superMiddleNameMap.keyTransformationBlock=^(NSString *inputKey){return @"mySuperMiddleName";};
        
        //mapping for addrassArray
        KVMap *addressArrayMap=[[KVMap alloc] init];
        addressArrayMap.keyTransformationBlock=^(NSString *inputKey){return [Transformers snakeToLlamaCase:inputKey];};
        
        addressArrayMap.valueTransformationBlock=(id)^(NSArray *input){
            NSMutableArray *newArray=[NSMutableArray array];
            for (id object in input) {
                [newArray addObject:[TestAddress objectWithDictionary:[KVMapper mappedDictionaryWithInputDictionary:object mappingDictionary:addressMappingDict]]];
            }
            return newArray;
        };
        
        addressMap.removeNulls=TRUE;
        
        NSDictionary *objectMapperDict=@{
                                         @"mySUPERmiddleNaMe" : superMiddleNameMap,
                                         @"address" : addressMap,
                                         @"array_of_addresses" : addressArrayMap
                                         };
        
        [personMapping addEntriesFromDictionary:objectMapperDict];
        
        
        NSDictionary *mappedDict=[KVMapper mappedDictionaryWithInputDictionary:dictToMap mappingDictionary:personMapping];
        
        [((TestAddress *)[mappedDict objectForKey:@"address"]) shouldBeNil];
        [[[mappedDict objectForKey:@"arrayOfAddresses"] objectAtIndex:0] shouldNotBeNil];

        
    });

});


SPEC_END


