//
//  DemoViewController.m
//  HJDemo
//
//  Created by jixuhui on 15/11/6.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import "DemoViewController.h"

@interface DemoViewController ()<UITextViewDelegate>
{
    UITextView * curTextView;
    UILabel *penLabel;
    NSArray * array1;
    NSArray * array2;
}
@property(nonatomic)NSString *contentStr;
@end

@implementation DemoViewController
@synthesize contentStr = _contentStr;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    curTextView = [[UITextView alloc]init];
    curTextView.layer.borderColor = [[UIColor grayColor]CGColor];
    curTextView.layer.borderWidth = 1;
    curTextView.translatesAutoresizingMaskIntoConstraints = NO;
    curTextView.delegate=self;
    [self.view addSubview:curTextView];
    
    penLabel = [[UILabel alloc]init];
    penLabel.translatesAutoresizingMaskIntoConstraints = NO;
    penLabel.numberOfLines = 0;
    [self.view addSubview:penLabel];
    
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(animationLabel) object:nil];
    [thread start];
    self.contentStr = @"人生最宝贵的是生命，生命属于人只有一次。一个人的生命应当这样度过：当他回忆往事的时候，他不致因虚度年华而悔恨，也不致因碌碌无为而羞愧；在临死的时候，他能够说：“我的整个生命和全部精力，都已献给世界上最壮丽的事业——为人类的解放而斗争。”";
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.topItem.title = @"测试";
}

- (void)animationLabel
{
    for (NSInteger i = 0; i < self.contentStr.length; i++)
    {
        [self performSelectorOnMainThread:@selector(refreshUIWithContentStr:) withObject:[self.contentStr substringWithRange:NSMakeRange(0, i+1)] waitUntilDone:YES];
        [NSThread sleepForTimeInterval:0.3];
    }
}

- (void)refreshUIWithContentStr:(NSString *)contentStr
{
    penLabel.text = contentStr;
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    array1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-100-[curTextView]-100-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(curTextView)];
    array2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-150-[curTextView(30)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(curTextView)];
    [self.view addConstraints:array1];
    [self.view addConstraints:array2];
    
    NSArray *penLabelH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[penLabel]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(penLabel)];
    NSArray *penLabelV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-200-[penLabel]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(penLabel)];
    [self.view addConstraints:penLabelH];
    [self.view addConstraints:penLabelV];
}

- (void)textViewDidChange:(UITextView *)textView
{
    float hight =textView.contentSize.height;
    //将以前的移除掉
    [self.view removeConstraints:array1];
    [self.view removeConstraints:array2];
    array1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-100-[textView]-100-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textView)];
    array2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-150-[textView(hight)]" options:0 metrics:@{@"hight":[NSNumber numberWithFloat:hight]} views:NSDictionaryOfVariableBindings(textView)];
    [self.view addConstraints:array1];
    [self.view addConstraints:array2];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
