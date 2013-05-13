#KVMapper

A Library to map one NSDictionary to another that can transform BOTH keys and values with a single map. It also allows you to decouple any formatting you may have to do from one representation of data to another (eg. rest api -> internal model representation).

#####sidenote
In trying to allow for as much customisation as possible, this tiny library makes very little assumptions which means you must be somewhat verbose. But see [convenience methods](#convenience-methods) that should greatly reduce code for the simpler cases.

##Installation

###cocoapods

add to your podfile:

```
Pod 'KVMapper' '~>0.1'
```
###manual

(pro-tip use cocoapods)

Drag contents of `KVMapper` folder to ~~Xcode~~ your favourite IDE.

##Usage

###instant attention grabbing example

You have a dictionary from a JSON Rest API that gives you a key-value store of cat names and their ages: the NSDictionary representaion looks like this:

```
NSDictionary *catsFromAPI=@{
                            @"maggy_the_ninja": @5,
                            @"magrat_the_rockstar": @6,
                            @"mable_the_wizard": @2,
                            … 15 or so more cats
                            @"milly_the_scratcher":@"3"
                            };


```
you want this in an NSDictionary which looks like this:

```
//llamaCaseCatNames
//ages are now in human years (sort of)
NSDictionary *catsForMyModel=@{
                            @"maggyTheNinja": @30,
                            @"magratTheRockstar": @36,
                            @"mableTheWizard": @12,
                            … 15 or so more cats
                            @"millyTheScratcher":@"3"
                            };



```
here's how you can do that:



```
 #import "KVMapper.h"
 #import "Transformers.h" //see apendix, used to do snake_case to llameCase transformation

NSDictionary *catsMappingDict=[KVMapper mappingDictionaryForKeys:catsFromAPI.allKeys
                              defaultKeyTransformer:^NSString *(NSString *catName) {
                                  return [Transformers snakeToLlamaCase:catName];
                             }
                            defaultValueTransformer:^id(NSNumber *catAge) {
                                float humanAge=catAge.floatValue+5;
                                return [NSNumber numberWithFloat:humanAge];
                            }];
                             
NSDictionary *catsForMyModel=[KVMapper mappedDictionaryWithInputDictionary:catsFromAPI mappingDictionary:catsMappingDict];

//catsForMyModel is now as in the form @{@"maggyTheNinja": @30, …… etc.}


```


###Creating a dictionary

To create a dictionary from a dictionary, you need `mappedDictionaryWithInputDictionary:mappingDictionary:` 

verbosely:

```
+(NSDictionary *)mappedDictionaryWithInputDictionary:(NSDictionary *)inputDict mappingDictionary:(NSDictionary *)mappingDict;
```

```
NSDictionary *myMappedDictionary=[KVMapper mappedDictionaryWithInputDictionary:inputDict mappingDictionary:mappingDict];
```
This takes your input dictionary and a _mapping dictionary_.


####mapping dictionary

A mapping dictionary is an NSDictionary whose keys correspond to the keys of the input dictionary and the values are instances of `KVMap`.


#####KVMap

the `KVMap` object is just an NSObject with two properties:

1. `keyTransformationBlock`
2. `valueTransformationBlock`

The former receives and returns an `NSString` (the key) the latter receives and return `id` ie any object you want (the value).

######creating a KVMap

making a `KVMap` is a simple as setting the key and value transformation blocks:

```
KVMap *myKVMap=[[KVMap alloc] init];

myKVMap.keyTransformationBlock=^(NSString *inputString){
	return [inputString lowercaseString];
};

myKVMap.valueTransformationBlock=^(id *input){
	return @5;
};

```

there is an initaliser `initWithKeyTransformationBlock:valueTransformationBlock:` to create one in a single step.

####creating a mapping dictionary

To create a mapping dictionary you must create the various KVMaps you need to map the input dictionary's key-value pairs into the form you want. Then set these as values to the key correspondong to the input dictionary's key:

```
// the input dictionary
NSDictionary *inputDict=@{
@"KEYONE":@1,
@"KEYTWO":@2,
@"myKEYTHREE":@"3",
};

//set up maps (you can use the same map if it applies to multiple KV pairs)
KVMap *myKeyOneAndTwoKVMap=[[KVMap alloc] init];
myKeyOneAndTwoKVMap.keyTransformationBlock=^(NSString *inputString){
	return [NSSString stringWithFormat:@"my%@",[inputSting lowerCaseString]];
};
myKeyOneAndTwoKVMap.valueTransformationBlock=^(id *input){
	return [NSString stringWithFormat:@"%i",input];
};

KVMap *myKeyThreeKVMap=[[KVMap alloc] init];
myKeyThreeKVMap.keyTransformationBlock=^(NSString *inputString){
	return [inputSting lowerCaseString];
};

//create mapping dict
NSDictionary *mappingDict=@{
@"KEYONE":myKeyOneAndTwoKVMap,
@"KEYTWO":myKeyOneAndTwoKVMap,
@"myKEYTHREE":myKeyThreeKVMap
};

// [KVMapper mappedDictionaryWithInputDictionary:inputDict mappingDictionary:mappingDict];
// will return:
//    @{
// 		@"mykeyone":@"1",
// 		@"mykeytwo":@"2",
//		@"mykeythree":@"3"
// 		};

``` 

###Convenience Methods

Writing out all the mapping logic can quickly become tedious, especially when we often have to do the same transformation for a key, value or both.

so KVMapper has: `KVMapsForKeys:defaultKeyTransformer:` and `KVMapsForKeys:defaultKeyTransformer:defaultValueTransformer:`

so suppose we want to create a mappingDictionary for where all the keys are transformed to lowerCase and all the values (which we get as strings) are NSURLs.

```
        NSDictionary *mappingDict=[KVMapper mappingDictionaryForKeys:testDict.allKeys
                                               defaultKeyTransformer:^(NSString *inKey){
                                                   return [Transformers snakeToLlamaCase:inKey];
                                               }
                                             defaultValueTransformer:^(id inValue){
                                                 NSURL *url=[NSURL URLWithString:inValue];
                                                 return url;
                                             }];
```
This `mappingDict` can now be used in 



##Appendix

###The random transformer class

```
//Transformers.h
#import <Foundation/Foundation.h>

@interface Transformers : NSObject
+(NSString *)snakeToLlamaCase:(NSString *)inKey;
@end

```

```
//Transformers.m

#import "Transformers.h"

@implementation Transformers

#pragma mark -string transformers

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSLog(@"couldn't set value: %@ for undefkey:%@",[value description],key);
}

+(NSString *)snakeToLlamaCase:(NSString *)inKey{
    
    NSArray *keyComponents=[inKey componentsSeparatedByString:@"_"];
    
    return [self llamaCasFromComponents:keyComponents];
}

+(NSString *)llamaCasFromComponents:(NSArray *)components{
    NSMutableString *llamaCaseString=[NSMutableString string];
    for (NSString *component in components) {
        NSString *firstLetterUpper=[[component substringToIndex:1] uppercaseString];
        NSString *restOfComponent=[component substringFromIndex:1];
        NSString *newComponent=[NSString stringWithFormat:@"%@%@",firstLetterUpper,restOfComponent];
        [llamaCaseString appendString:newComponent];
    }
    NSString *firstLetterLower=[[llamaCaseString substringToIndex:1] lowercaseString];
    [llamaCaseString replaceCharactersInRange:NSMakeRange(0, 1) withString:firstLetterLower];
    
    return llamaCaseString;
}

@end

```

##TODO  


- methods to take in and return different types of key-value stores eg NSObjects and JSON strings.
- better docs? any advice or questions are appriciated.  
- include some sensible string/ value transformations. (you should out this [TransformerKit](https://github.com/mattt/TransformerKit) by @mattt)


##License

**MIT**

##Contribution

Is welcome!!

- start a conversation in issues / make a pull request if you have code
- KVMapper is tested with [Kiwi](https://github.com/allending/Kiwi) so adding tests to your code would be nice, (also feel free to use OCUnit if you prefer)

Eternal thanks
