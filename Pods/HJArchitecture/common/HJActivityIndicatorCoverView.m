//
//  HJActivityIndicatorCoverView.m
//  HJArchitecture
//
//  Created by jixuhui on 15/10/9.
//  Copyright (c) 2015年 private. All rights reserved.
//

#import "HJActivityIndicatorCoverView.h"

// failRetryImage
#define Image_FailRetry_Width   60
#define Image_FailRetry_Height  111

@interface HJActivityIndicatorCoverView ()
{
    SEL                      retryAction;
}

@property (nonatomic, weak) id actObject;       // must be weak,otherwise may result in retain cycle

@end

@implementation HJActivityIndicatorCoverView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame style:HJActivityIndicatorCoverViewStyle_other];
}

- (id)initWithFrame:(CGRect)frame style:(HJActivityIndicatorCoverViewStyle)s
{
    self = [super initWithFrame:frame];
    if (self) {
        _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _style = s;
        [self reloadUIElements];
        
        _retryButton.frame = frame;
        [_retryButton addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
        
        _retryButton.hidden = YES;
        [self addSubview:_retryButton];
        
        _indicator.hidesWhenStopped = YES;
        
        self.hidden = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    _indicator.center = self.center;
    _indicator.frame = CGRectOffset(_indicator.frame, 0, -26);
    _retryButton.center = self.center;
}

- (void)reloadUIElements
{
    if (_indicator == nil)
    {
        _indicator = [[UIActivityIndicatorView alloc] init];
        [self addSubview:_indicator];
    }
    switch (_style)
    {
        case HJActivityIndicatorCoverViewStyle_other:
            self.backgroundColor = [UIColor whiteColor];
            _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            [_retryButton setImage:[UIImage imageNamed:@"refresh.png"] forState:UIControlStateNormal];
            [_retryButton setImage:[UIImage imageNamed:@"refresh.png"] forState:UIControlStateHighlighted];
            break;
        case HJActivityIndicatorCoverViewStyle_article:
            self.backgroundColor = [UIColor whiteColor];
            _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            [_retryButton setImage:[UIImage imageNamed:@"refresh.png"] forState:UIControlStateNormal];
            [_retryButton setImage:[UIImage imageNamed:@"refresh.png"] forState:UIControlStateHighlighted];
            break;
        case HJActivityIndicatorCoverViewStyle_photo:
            self.backgroundColor = [UIColor blackColor];
            _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
            [_retryButton setImage:[UIImage imageNamed:@"refresh.png"] forState:UIControlStateNormal];
            [_retryButton setImage:[UIImage imageNamed:@"refresh.png"] forState:UIControlStateHighlighted];
        default:
            break;
    }
}

- (void)startAnimating
{
    _retryButton.hidden = YES;
    [_indicator startAnimating];
    
    self.hidden = NO;
}

- (void)stopAnimating
{
    [_indicator stopAnimating];
    self.hidden = YES;
}

- (void)stopAnimationWithRetryAction:(SEL)aRetryAction withActObject:(id)object
{
    self.hidden = NO;
    [_indicator stopAnimating];
    _retryButton.hidden = NO;
    retryAction = aRetryAction;
    self.actObject = object;
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _indicator = nil;
}

- (void)tapped
{
    [self startAnimating];
    if ([self.actObject respondsToSelector:retryAction])
    {
        if (nil != retryAction) {
            /*
             [actObject performSelector:retryAction];
             //ARC下使用这个方法会照成泄露performselector may cause a leak because its selector is unknown
             http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
             */
            IMP imp = [self.actObject methodForSelector:retryAction];
            void (*func)(id, SEL) = (void *)imp;
            func(self.actObject, retryAction);
        }
        
    }
}

@end



//@implementation HJActivityIndicatorCoverView (Action)
//
//- (void)tapped
//{
//    [self startAnimating];
//    if ([self.actObject respondsToSelector:retryAction])
//    {
//        if (nil != retryAction) {
//            /*
//             [actObject performSelector:retryAction];
//             //ARC下使用这个方法会照成泄露performselector may cause a leak because its selector is unknown
//             http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
//             */
//            IMP imp = [self.actObject methodForSelector:retryAction];
//            void (*func)(id, SEL) = (void *)imp;
//            func(self.actObject, retryAction);
//        }
//        
//    }
//}

//@end
