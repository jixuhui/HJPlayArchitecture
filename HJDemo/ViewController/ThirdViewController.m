//
//  ThirdViewController.m
//  HJDemo
//
//  Created by jixuhui on 15/11/6.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import "ThirdViewController.h"
#import "Masonry.h"
#import "HJMutipleDelegateViewController.h"
#import "ChartViewController.h"

@interface ThirdViewController ()<UITextViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UITextView * _curTextView;
    UILabel *_penLabel;
    UITableView *_tableView;
    NSArray *_cellTextArray;
}
@property(nonatomic)NSString *contentStr;
@end

@implementation ThirdViewController
@synthesize contentStr = _contentStr;

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initDataSource];
    
    [self initTableView];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.topItem.title = @"测试";
    
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init

- (void)initDataSource
{
    _cellTextArray = @[@"navig",@"auto_textfield",@"autowrite",@"chart",@"del_chart_cache"];
}

- (void)initTableView
{
    _tableView = [[UITableView alloc]init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 15, 1, 15);
    [self.view addSubview:_tableView];
    
    WEAKSELF
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONGSELF
        make.left.equalTo(strongSelf.view.left);
        make.top.equalTo(strongSelf.view.top);
        make.width.equalTo(strongSelf.view.width);
        make.height.equalTo(strongSelf.view.height);
    }];
    
    [_tableView reloadData];
}

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

#pragma mark
#pragma delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_cellTextArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HJTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[HJTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSString *text = [_cellTextArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = text;
    cell.actionName = text;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HJTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[HJTableViewCell class]]) {
        if ([cell.actionName isEqualToString:@"chart"]) {
            ChartViewController *chartVC = [[ChartViewController alloc]init];
            [self.navigationController pushViewController:chartVC animated:YES];
        }else if ([cell.actionName isEqualToString:@"del_chart_cache"]) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            NSString *mess = [self delChartCacheWithFileName:@"600123.plist"]?@"Delete Success!":@"Delete Failure!";
            [self showSimpleAlertByMessgae:mess];
        }else {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            //由storyboard根据myView的storyBoardID来获取我们要切换的视图
            UIViewController *myView = [story instantiateViewControllerWithIdentifier:@"mutipleDelegateVC"];
            //由navigationController推向我们要推向的view
            [self.navigationController pushViewController:myView animated:YES];
        }
    }
    
    
    [self setTabBarHidden:YES animated:YES];
}

- (BOOL)delChartCacheWithFileName:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    
    if ([fileManager fileExistsAtPath:filePath]) {
        return [fileManager removeItemAtPath:filePath error:&error];
    }
    
    return NO;
}

@end
