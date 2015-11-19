//
//  TestTableViewCell.m
//  HJServiceDemo
//
//  Created by jixuhui on 15/10/26.
//  Copyright © 2015年 private. All rights reserved.
//

#import "TestTableViewCell.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"

@interface TestTableViewCell()
{
    UIImageView *_imageView;
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
    
    NSString *tempStr = (NSString *)[dataItem dataForKey:@"img_url"];
    
    if (!CHECK_VALID_STRING(tempStr)) {
        tempStr = @"";
    }
    
    [self layoutImageView:tempStr];
    
    [self layoutTitleLabel];
    
    [self layoutBottomLine];
    
    [self updateConstraintsIfNeeded];
}

-(void)updateConstraints
{
    [super updateConstraints];
    
    //_imageView constraints
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.left).with.offset(15);
        make.top.mas_equalTo(self.top).with.offset(10);
        make.bottom.mas_equalTo(self.bottom).with.offset(10);
        make.right.equalTo(_titleLabel.left).with.offset(15);
        
        make.width.mas_equalTo(75);
    }];
    
    //_titleLabel constraints
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    NSLayoutConstraint *trailingLayout = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.cellMarginLeft];
    NSLayoutConstraint *leadinLayout = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.cellMarginLeft];
    NSLayoutConstraint *topLayout = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:5];
    NSLayoutConstraint *bottomLayout = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-5];
    
    [self.contentView addConstraints:@[leadinLayout,topLayout,bottomLayout]];
    
    //_bottomLine constraints
    _bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *lineLeft = [NSLayoutConstraint constraintWithItem:_bottomLine attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.cellMarginLeft];
    
    NSLayoutConstraint *lineRight = [NSLayoutConstraint constraintWithItem:_bottomLine attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.cellMarginLeft];
    
    NSLayoutConstraint *lineBottom = [NSLayoutConstraint constraintWithItem:_bottomLine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    
    NSLayoutConstraint *lineH = [NSLayoutConstraint constraintWithItem:_bottomLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.5];//固定高度，不对比
    
    [self.contentView addConstraints:@[lineLeft,lineRight,lineBottom,lineH]];
}

-(void)layoutImageView:(NSString *)imageUrl
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        [self.contentView addSubview:_imageView];
    }
    [_imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
    [_imageView sizeToFit];
}

-(void)layoutTitleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont systemFontOfSize:24];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:_titleLabel];
    }
    
    [_titleLabel setText:(NSString *)[self.dataItem dataForKey:@"name"]];
}

-(void)layoutBottomLine
{
    if (!_bottomLine)
    {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_bottomLine];
    }
}
@end
