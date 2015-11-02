//
//  HJTableViewCell.h
//  HJArchitecture
//
//  Created by jixuhui on 15/10/9.
//  Copyright (c) 2015年 private. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IHJViewBindDataProtocol.h"

@interface HJTableViewCell : UITableViewCell <IHJViewBindDataProtocol>
@property(nonatomic,assign)float cellHeight;
@end
