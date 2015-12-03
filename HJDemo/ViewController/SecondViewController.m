//
//  SecondViewController.m
//  HJDemo
//
//  Created by jixuhui on 15/11/5.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import "SecondViewController.h"
#import "GlobeViewController.h"
#import "RDVTabBarController.h"

#define screenHeight [[UIScreen mainScreen]bounds].size.height //屏幕高度
#define screenWidth [[UIScreen mainScreen]bounds].size.width   //屏幕宽度
#define colletionCell 3  //设置具体几列
@interface SecondViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>{
    NSMutableArray  *hArr; //记录每个cell的高度
}

@end

@implementation SecondViewController
@synthesize curCollectionView = _curCollectionView;

- (void)viewDidLoad {
    [super viewDidLoad];
    hArr = [[NSMutableArray alloc] init];
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical]; //设置横向还是竖向
    self.curCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    
    [self.curCollectionView setBackgroundColor:[UIColor clearColor]];
    [self.curCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    self.curCollectionView.dataSource = self;
    self.curCollectionView.delegate = self;
    [self.view addSubview:self.curCollectionView];
    
    WEAKSELF
    
    [self.curCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONGSELF
        make.edges.equalTo(strongSelf.view).with.insets(self.padding);
    }];
    
    [self doRequest];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.topItem.title = @"图片";
    
    NSArray *itemsPaths = [self.curCollectionView indexPathsForSelectedItems];
    
    [self.curCollectionView deselectItemAtIndexPath:[itemsPaths firstObject] animated:YES];
}

- (void)doRequest {
    HJURLTask *task = [[HJURLPageTask alloc]init];
    task.urlString = @"http://i2.api.weibo.com/2/search/statuses.json";
    task.otherParameters = [[NSMutableDictionary alloc]initWithCapacity:10];
    [task.otherParameters setValue:@"2281842789" forKey:@"source"];
    [task.otherParameters setValue:@"" forKey:@"sid"];//搜索的来源标识ID，由搜索部门提供，对外部接口不公布该参数。
    [task.otherParameters setValue:@"1" forKey:@"hasori"];
    [task.otherParameters setValue:@"0" forKey:@"hasret"];
    [task.otherParameters setValue:@"1" forKey:@"haspic"];
    [task.otherParameters setValue:@"50" forKey:@"count"];
    [task.otherParameters setValue:@"2" forKey:@"istag"];
    [task.otherParameters setValue:@"CHXX0008" forKey:@"city"];
    
    [[HJURLService shareService] handleTask:task success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
}
#pragma mark -- UICollectionViewDataSource

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 20;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"UICollectionViewCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed:((10 * indexPath.row) / 255.0) green:((20 * indexPath.row)/255.0) blue:((30 * indexPath.row)/255.0) alpha:1.0f];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    label.textColor = [UIColor redColor];
    label.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    //移除cell
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    NSInteger remainder=indexPath.row%colletionCell;
    NSInteger currentRow=indexPath.row/colletionCell;
    CGFloat   currentHeight=[hArr[indexPath.row] floatValue];
    
    CGFloat positonX=(screenWidth/colletionCell-8)*remainder+5*(remainder+1);
    CGFloat positionY=(currentRow+1)*5;
    for (NSInteger i=0; i<currentRow; i++) {
        NSInteger position=remainder+i*colletionCell;
        positionY+=[hArr[position] floatValue];
    }
    cell.frame = CGRectMake(positonX, positionY,screenWidth/colletionCell-8,currentHeight) ;//重新定义cell位置、宽高
    
    UIView *bgV = [[UIView alloc]initWithFrame:cell.frame];
    bgV.backgroundColor = [UIColor greenColor];
    
    cell.selectedBackgroundView = bgV;
    
    [cell.contentView addSubview:label];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout

//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height=100+(arc4random()%120);
    [hArr addObject:[NSString stringWithFormat:@"%f",height]];
    return  CGSizeMake(screenWidth/colletionCell-8, height);  //设置cell宽高
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0,0, 0, 0);
}

#pragma mark --UICollectionViewDelegate

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self setTabBarHidden:YES animated:YES];
    
    GlobeViewController *globeVC = [[GlobeViewController alloc]init];
    [self.navigationController pushViewController:globeVC animated:YES];
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

@end
