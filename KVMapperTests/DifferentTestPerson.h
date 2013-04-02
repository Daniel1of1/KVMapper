//
//  DifferentTestPerson.h
//  JSObjCDemo
//
//  Created by confidence on 08/03/2013.
//  Copyright (c) 2013 confidenceJuice. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TestAddress;

@interface DifferentTestPerson : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *middleName;
@property (nonatomic, strong) NSString *mySuperMiddleName;
@property (nonatomic, strong) TestAddress *address;
@property(nonatomic, strong) NSArray *arrayOfStuff;
@property(nonatomic, strong) NSArray *arrayOfAddresses;
@property (nonatomic, strong) NSString *someString;

@end
