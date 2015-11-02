//
//  HJURLTask.m
//  HJArchitecture
//
//  Created by jixuhui on 15/8/24.
//  Copyright (c) 2015年 private. All rights reserved.
//

#import "HJURLTask.h"

@implementation HJURLTask

@synthesize ID = _ID;
@synthesize type = _type;
@synthesize urlString = _urlString;
@synthesize requestType = _requestType;
@synthesize operation = _operation;
@synthesize otherParameters = _otherParameters;

#pragma mark - coding protocol

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (!self) {
        return nil;
    }
    
    self.ID = [aDecoder decodeObjectForKey:@"ID"];
    self.type = [aDecoder decodeObjectForKey:@"type"];
    self.urlString = [aDecoder decodeObjectForKey:@"urlString"];
    self.otherParameters = [aDecoder decodeObjectForKey:@"otherParameters"];
    self.operation = [aDecoder decodeObjectForKey:@"operation"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.urlString forKey:@"urlString"];
    [aCoder encodeObject:self.otherParameters forKey:@"otherParameters"];
    [aCoder encodeObject:self.operation forKey:@"operation"];
}

#pragma mark - copying protocol

-(id)copyWithZone:(NSZone *)zone
{
    HJURLTask *task = [(HJURLTask *)[[self class] allocWithZone:zone] init];
    
    task.ID = self.ID;
    task.type = self.type;
    task.urlString = self.urlString;
    task.otherParameters = self.otherParameters;
    task.operation = self.operation;
    
    return task;
}

@end
