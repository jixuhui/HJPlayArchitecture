//
//  HJMultipleProxyBehavior.h
//  HJADemo
//
//  Created by jixuhui on 15/12/10.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HJMultipleProxyBehavior : NSObject

@property (nonatomic, weak) IBOutlet id owner;
@property (nonatomic, strong) IBOutletCollection(id) NSArray* delegateTargets;

@end
