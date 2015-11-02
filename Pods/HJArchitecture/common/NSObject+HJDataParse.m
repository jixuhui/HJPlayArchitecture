//
//  NSObject+HJDataParse.m
//  HJArchitecture
//
//  Created by Hubbert on 15/9/27.
//  Copyright (c) 2015年 private. All rights reserved.
//

#import "NSObject+HJDataParse.h"

@implementation NSObject (HJDataParse)

-(instancetype) dataForKey:(NSString *) key{
    if([self isKindOfClass:[NSString class]]){
        return nil;
    }
    if([self isKindOfClass:[NSNumber class]]){
        return nil;
    }
    if([self isKindOfClass:[NSNull class]]){
        return nil;
    }
    if([self isKindOfClass:[NSData class]]){
        return nil;
    }
    if([self isKindOfClass:[NSDate class]]){
        return nil;
    }
    if([self isKindOfClass:[NSArray class]]){
        if([key hasPrefix:@"@last"]){
            return [(NSArray *)self lastObject];
        }
        else if([key hasPrefix:@"@joinString"]){
            return [(NSArray *)self componentsJoinedByString:@","];
        }
        else if([key hasPrefix:@"@count"]){
            return [NSNumber numberWithUnsignedInteger:[(NSArray *) self count]];
        }
        else if([key hasPrefix:@"@"]){
            NSInteger index = [[key substringFromIndex:1] intValue];
            if(index >=0 && index < [(NSArray *)self count]){
                return [(NSArray *)self objectAtIndex:index];
            }
        }
        return nil;
    }
#ifdef DEBUG
    return [self valueForKey:key];
#else
    @try {
        return [self valueForKey:key];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        return nil;
    }
#endif
}

-(instancetype) dataForKeyPath:(NSString *) keyPath{
    NSRange r = [keyPath rangeOfString:@"."];
    if(r.location == NSNotFound){
        return [self dataForKey:keyPath];
    }
    id v = [self dataForKey:[keyPath substringToIndex:r.location]];
    return [v dataForKeyPath:[keyPath substringFromIndex:r.location + r.length]];
}

@end
