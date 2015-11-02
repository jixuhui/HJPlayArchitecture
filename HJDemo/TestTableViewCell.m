//
//  TestTableViewCell.m
//  HJServiceDemo
//
//  Created by jixuhui on 15/10/26.
//  Copyright © 2015年 private. All rights reserved.
//

#import "TestTableViewCell.h"

#import "HJService.h"

@interface TestTableViewCell()
{
    UILabel *_titleLabel;
    UIView *_bottomLine;
}
@property(nonatomic,assign) float cellMarginLeft;
@end

@implementation TestTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.cellHeight = 60;
        self.cellMarginLeft = 10;
    }
    return self;
}

-(void)setDataItem:(NSObject *)dataItem
{
    [super setDataItem:dataItem];
    
    [self layoutTitleLabel];
    
    [self layoutBottomLine];
}

-(void)layoutTitleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, kScreenWidth, 60)];
        
        [self.contentView addSubview:_titleLabel];
    }
    
    [_titleLabel setText:(NSString *)[self.dataItem dataForKey:@"name"]];
}

-(void)layoutBottomLine
{
    if (!_bottomLine)
    {
        _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(self.cellMarginLeft, self.cellHeight - 0.5, (kScreenWidth - self.cellMarginLeft * 2), 0.5)];
        _bottomLine.backgroundColor = [UIColor lightGrayColor];
        
        [self.contentView addSubview:_bottomLine];
    }
}
@end
