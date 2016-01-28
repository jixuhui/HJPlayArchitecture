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
    
    NSString *picStr = @"";
    
    NSDictionary *picPath  = (NSDictionary *)[dataItem dataForKey:@"indexPic"];
    
    [self layoutTitleLabel];
    
    if (CHECK_VALID_DICTIONARY(picPath)) {
        picStr = [NSString stringWithFormat:@"%@%@%@%@",[picPath dataForKey:@"host"],[picPath dataForKey:@"dir"],[picPath dataForKey:@"filepath"],[picPath dataForKey:@"filename"]];
        NSLog(@"picStr...%@",picStr);
        
        [self layoutImageView:picStr size:CGSizeMake(100, 100*[[picPath valueForKey:@"height"] floatValue]/[[picPath valueForKey:@"width"] floatValue])];
    }else {
        [self layoutImageView:@"" size:CGSizeMake(100, 100)];
    }
    
    [self layoutBottomLine];
}

-(void)addLabelConstraints
{
    //_titleLabel constraints
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-self.cellMarginLeft);
        make.top.equalTo(self.contentView.top).with.offset(5);
        make.bottom.equalTo(self.contentView.bottom).with.offset(-5);
        make.height.mas_greaterThanOrEqualTo(70);
    }];
}

-(void)addImageViewConstraintsWithSize:(CGSize)size
{
    //_imageView constraints
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.left).with.offset(self.cellMarginLeft);
        make.right.equalTo(_titleLabel.left).with.offset(-15);
        make.centerY.equalTo(self.contentView.centerY);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(80);
//        make.top.equalTo(self.contentView.top).with.offset(5);
    }];
}

-(void)addBottomViewConstraints
{
    //_bottomLine constraints
    _bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *lineLeft = [NSLayoutConstraint constraintWithItem:_bottomLine attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.cellMarginLeft];
    
    NSLayoutConstraint *lineRight = [NSLayoutConstraint constraintWithItem:_bottomLine attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.cellMarginLeft];
    
    NSLayoutConstraint *lineBottom = [NSLayoutConstraint constraintWithItem:_bottomLine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    
    NSLayoutConstraint *lineH = [NSLayoutConstraint constraintWithItem:_bottomLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0.5];//固定高度，不对比
    
    [self.contentView addConstraints:@[lineLeft,lineRight,lineBottom,lineH]];
}

-(void)layoutImageView:(NSString *)imageUrl size:(CGSize)size
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        [self.contentView addSubview:_imageView];
        
        [self addImageViewConstraintsWithSize:size];
    }
    [_imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
}

-(void)layoutTitleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont systemFontOfSize:24];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:_titleLabel];
        
        [self addLabelConstraints];
    }
    
    [_titleLabel setText:(NSString *)[self.dataItem dataForKey:@"title"]];
}

-(void)layoutBottomLine
{
    if (!_bottomLine)
    {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_bottomLine];
        
        [self addBottomViewConstraints];
    }
}
@end
