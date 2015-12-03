//
//  ThirdViewController.m
//  HJDemo
//
//  Created by jixuhui on 15/11/6.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import "ThirdViewController.h"
#import "Masonry.h"

@interface ThirdViewController ()<UITextViewDelegate>
{
    UITextView * _curTextView;
    UILabel *_penLabel;
}
@property(nonatomic)NSString *contentStr;
@end

@implementation ThirdViewController
@synthesize contentStr = _contentStr;

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initSubViews];
    
    [self initLayoutSubViews];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTap:)];
    [self.view addGestureRecognizer:tap];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.topItem.title = @"测试";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init

-(void)initSubViews
{
    [self initCurTextView];
    [self initPanLabel];
}

-(void)initCurTextView
{
    _curTextView = [[UITextView alloc]init];
    _curTextView.layer.borderColor = [[UIColor grayColor]CGColor];
    _curTextView.layer.borderWidth = 1;
    _curTextView.delegate=self;
    [self.view addSubview:_curTextView];
}

-(void)initPanLabel
{
    self.contentStr = @"人生最宝贵的是生命，生命属于人只有一次。一个人的生命应当这样度过：当他回忆往事的时候，他不致因虚度年华而悔恨，也不致因碌碌无为而羞愧；在临死的时候，他能够说：“我的整个生命和全部精力，都已献给世界上最壮丽的事业——为人类的解放而斗争。”";
    
    _penLabel = [[UILabel alloc]init];
    _penLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _penLabel.numberOfLines = 0;
    [self.view addSubview:_penLabel];
    
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(doLabelAnimation) object:nil];
    [thread start];
}

-(void)initLayoutSubViews
{
    [self layoutCurTextViewWithHeight:30];
    [self layoutPanLabel];
}

-(void)layoutCurTextViewWithHeight:(float)height
{    
    WEAKSELF
    
    [_curTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
        STRONGSELF
        make.centerY.equalTo(strongSelf.view.top).with.offset(50);
        make.left.equalTo(strongSelf.view).with.offset(100);
        make.right.equalTo(strongSelf.view).with.offset(-100);
//        make.height.equalTo(@(height));//或者如此设置变量值
        make.height.mas_equalTo(height);
    }];
}

-(void)layoutPanLabel
{
    NSArray *_penLabelH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_penLabel]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_penLabel)];
    NSArray *_penLabelV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-200-[_penLabel]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_penLabel)];
    [self.view addConstraints:_penLabelH];
    [self.view addConstraints:_penLabelV];
}

#pragma mark - help methods

-(void)doTap:(id)sender
{
    [_curTextView resignFirstResponder];
}

- (void)doLabelAnimation
{
    for (NSInteger i = 0; i < self.contentStr.length; i++)
    {
        [self performSelectorOnMainThread:@selector(refreshUIWithContentStr:) withObject:[self.contentStr substringWithRange:NSMakeRange(0, i+1)] waitUntilDone:YES];
        [NSThread sleepForTimeInterval:0.3];
    }
}

- (void)refreshUIWithContentStr:(NSString *)contentStr
{
    _penLabel.text = contentStr;
}

#pragma mark - delegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self layoutCurTextViewWithHeight:textView.contentSize.height];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
