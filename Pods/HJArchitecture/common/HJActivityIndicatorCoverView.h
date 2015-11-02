//
//  HJActivityIndicatorCoverView.h
//  HJArchitecture
//
//  Created by jixuhui on 15/10/9.
//  Copyright (c) 2015年 private. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum HJActivityIndicatorCoverViewStyle
{
    HJActivityIndicatorCoverViewStyle_article,
    HJActivityIndicatorCoverViewStyle_photo,
    HJActivityIndicatorCoverViewStyle_other
}HJActivityIndicatorCoverViewStyle;

@interface HJActivityIndicatorCoverView : UIView
{
    HJActivityIndicatorCoverViewStyle _style;
}

@property (nonatomic, readonly, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, readonly, strong) UIButton *retryButton;


- (id)initWithFrame:(CGRect)frame style:(HJActivityIndicatorCoverViewStyle)style;

- (void)startAnimating;
- (void)stopAnimating;
- (void)stopAnimationWithRetryAction:(SEL)retryAction withActObject:(id)object;

@end
