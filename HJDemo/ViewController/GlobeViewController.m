//
//  GlobeViewController.m
//  HJDemo
//
//  Created by jixuhui on 15/11/6.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import "GlobeViewController.h"
#import "GlobeCollectionViewLayout.h"
#import "Masonry.h"
#import "HJArchitecture.h"

@interface GlobeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@end

@implementation GlobeViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    GlobeCollectionViewLayout * layout = [[GlobeCollectionViewLayout alloc]init];
    UICollectionView * collect  = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    collect.delegate=self;
    collect.dataSource=self;
    //这里设置的偏移量是为了无缝进行循环的滚动，具体在上一篇博客中有解释
    collect.contentOffset = CGPointMake(320, 400);
    [collect registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
    [self.view addSubview:collect];
    
    WS(ws);
    
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [collect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(ws.view).width.insets(padding);
    }];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
//我们返回30的标签
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 30;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1];
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    label.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    [cell.contentView addSubview:label];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//这里对滑动的contentOffset进行监控，实现循环滚动
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y<200) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y+10*400);
    }else if(scrollView.contentOffset.y>11*400){
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y-10*400);
    }
    if (scrollView.contentOffset.x<160) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x+10*320,scrollView.contentOffset.y);
    }else if(scrollView.contentOffset.x>11*320){
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x-10*320,scrollView.contentOffset.y);
    }
}

@end
