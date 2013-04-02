//
//  TestAdress.m
//  MySuperJSONYThingy
//
//  Created by confidence on 25/02/2013.
//  Copyright (c) 2013 confidenceJuice. All rights reserved.
//

#import "TestAddress.h"

@implementation TestAddress

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[self class]]) {
        TestAddress *testAddress=(TestAddress *)object;
        BOOL equal=[self.streetName isEqualToString:testAddress.streetName] && [self.houseNumber isEqualToNumber:testAddress.houseNumber];
        return equal;
    }
    else return false;
}

@end
