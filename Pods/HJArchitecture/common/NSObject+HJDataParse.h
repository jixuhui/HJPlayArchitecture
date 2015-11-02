//
//  NSObject+HJDataParse.h
//  HJArchitecture
//
//  Created by Hubbert on 15/9/27.
//  Copyright (c) 2015年 private. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (HJDataParse)

-(instancetype) dataForKey:(NSString *) key;

-(instancetype) dataForKeyPath:(NSString *) keyPath;

@end
