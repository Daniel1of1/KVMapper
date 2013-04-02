//
//  Transformers.m
//  JSObjC
//
//  Created by confidence on 08/03/2013.
//  Copyright (c) 2013 confidenceJuice. All rights reserved.
//

#import "Transformers.h"

@implementation Transformers

#pragma mark -string transformers

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSLog(@"couldn't set value: %@ for undefkey:%@",[value description],key);
}

+(NSString *)normalizedKey:(NSString *)inKey{
    
    NSArray *keyComponents=[inKey componentsSeparatedByString:@"_"];
    
    return [self camelCaseFromComponents:keyComponents];
}

+(NSString *)camelCaseFromComponents:(NSArray *)keyComponents{
    NSMutableString *camelCaseKey=[NSMutableString string];
    for (NSString *component in keyComponents) {
        NSString *firstLetterUpper=[[component substringToIndex:1] uppercaseString];
        NSString *restOfComponent=[component substringFromIndex:1];
        NSString *newComponent=[NSString stringWithFormat:@"%@%@",firstLetterUpper,restOfComponent];
        [camelCaseKey appendString:newComponent];
    }
    NSString *firstLetterLower=[[camelCaseKey substringToIndex:1] lowercaseString];
    [camelCaseKey replaceCharactersInRange:NSMakeRange(0, 1) withString:firstLetterLower];
    
    return camelCaseKey;
}

@end
