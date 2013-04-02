//
//  DifferentTestPerson.m
//  JSObjCDemo
//
//  Created by confidence on 08/03/2013.
//  Copyright (c) 2013 confidenceJuice. All rights reserved.
//

#import "DifferentTestPerson.h"
#import "TestAddress.h"

@implementation DifferentTestPerson
-(BOOL)isEqual:(id)object{
    
    if ([object isKindOfClass:[self class]]) {
        DifferentTestPerson *testPerson=(DifferentTestPerson *)object;
        return [self.firstName isEqualToString:testPerson.firstName] && [self.lastName isEqualToString:testPerson.lastName] && [self.middleName isEqualToString:testPerson.middleName] && [self.mySuperMiddleName isEqualToString:testPerson.mySuperMiddleName] && [self.address isEqual:testPerson.address] && [self.arrayOfStuff isEqualToArray:testPerson.arrayOfStuff] && [self.arrayOfAddresses isEqualToArray:testPerson.arrayOfAddresses];
    }
    else return false;
}

    
@end
