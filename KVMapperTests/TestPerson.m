//
//  TestPerson.m
//  MySuperJSONYThingy
//
//  Created by confidence on 25/02/2013.
//  Copyright (c) 2013 confidenceJuice. All rights reserved.
//

#import "TestPerson.h"

@implementation TestPerson


-(BOOL)isEqual:(id)object{
    
    if ([object isKindOfClass:[self class]]) {
        TestPerson *testPerson=(TestPerson *)object;
        return [self.firstName isEqualToString:testPerson.firstName] && [self.lastName isEqualToString:testPerson.lastName] && [self.middleName isEqualToString:testPerson.middleName] && [self.mySuperMiddleName isEqualToString:testPerson.mySuperMiddleName] && [self.address isEqual:testPerson.address] && [self.arrayOfStuff isEqualToArray:testPerson.arrayOfStuff] && [self.arrayOfAddresses isEqualToArray:testPerson.arrayOfAddresses];
    }
    else return false;
    
}

@end
