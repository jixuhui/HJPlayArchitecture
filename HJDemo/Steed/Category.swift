//
//  Category.swift
//  HJDemo
//
//  Created by Hubbert on 15/11/14.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

import Foundation

//if([self isKindOfClass:[NSString class]]){
//    return nil;
//}
//if([self isKindOfClass:[NSNumber class]]){
//    return nil;
//}
//if([self isKindOfClass:[NSNull class]]){
//    return nil;
//}
//if([self isKindOfClass:[NSData class]]){
//    return nil;
//}
//if([self isKindOfClass:[NSDate class]]){
//    return nil;
//}
//if([self isKindOfClass:[NSArray class]]){
//    if([key hasPrefix:@"@last"]){
//        return [(NSArray *)self lastObject];
//    }
//    else if([key hasPrefix:@"@joinString"]){
//        return [(NSArray *)self componentsJoinedByString:@","];
//    }
//    else if([key hasPrefix:@"@count"]){
//        return [NSNumber numberWithUnsignedInteger:[(NSArray *) self count]];
//    }
//    else if([key hasPrefix:@"@"]){
//        NSInteger index = [[key substringFromIndex:1] intValue];
//        if(index >=0 && index < [(NSArray *)self count]){
//            return [(NSArray *)self objectAtIndex:index];
//        }
//    }
//    return nil;
//}
//#ifdef DEBUG
//return [self valueForKey:key];
//#else
//@try {
//    return [self valueForKey:key];
//}
//@catch (NSException *exception) {
//    NSLog(@"%@",exception);
//    return nil;
//}
//#endif

//extension NSObject {
//    func dataForKey(key:String)->AnyClass?{
//        switch self{
//            case is String:
//                return nil
//            case is NSString:
//                return nil
//            case is NSNumber:
//                return nil
//            case is NSNull:
//                return nil
//            case is NSData:
//                return nil
//            case is NSDate:
//                return nil
//            case is NSArray:
//                switch key{
//                    case key where key.hasPrefix("@last"):
//                        return self
//                }
//            
//        }
//        
//    }
//}