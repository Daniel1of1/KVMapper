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
