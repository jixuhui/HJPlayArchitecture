//
//  HJConstant.h
//  HJArchitecture
//
//  Created by jixuhui on 15/10/9.
//  Copyright (c) 2015年 private. All rights reserved.
//

#ifndef HJArchitecture_HJConstant_h
#define HJArchitecture_HJConstant_h

//----------------------------ABOUT SYSTEM VERSION----------------------------
// 系统版本号枚举
#define IOS_2_0 @"2.0"
#define IOS_3_0 @"3.0"
#define IOS_4_0 @"4.0"
#define IOS_5_0 @"5.0"
#define IOS_6_0 @"6.0"
#define IOS_7_0 @"7.0"
#define IOS_8_0 @"8.0"
#define IOS_9_0 @"9.0"

// detect current system version upon v
// >=
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
// >
#define SYSTEM_VERSION_GREATER_THAN(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
// ==
#define SYSTEM_VERSION_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)

// detect current system is Simulator?
#define Simulator ([[[UIDevice currentDevice] name] hasSuffix:@"Simulator"] ? YES : NO)

//----------------------------ABOUT SCREEN----------------------------
#define kScreenWidth					[UIScreen mainScreen].bounds.size.width
#define kScreenHeight					[UIScreen mainScreen].bounds.size.height

//----------------------------VALID CHECKING----------------------------
#define CHECK_VALID_STRING(__string)               (__string && [__string isKindOfClass:[NSString class]] && [__string length])
#define CHECK_VALID_NUMBER(__aNumber)               (__aNumber && [__aNumber isKindOfClass:[NSNumber class]])
#define CHECK_VALID_ARRAY(__aArray)                 (__aArray && [__aArray isKindOfClass:[NSArray class]] && [__aArray count])
#define CHECK_VALID_DICTIONARY(__aDictionary)       (__aDictionary && [__aDictionary isKindOfClass:[NSDictionary class]] && [__aDictionary count])

//----------------------------ABOUT MIAOCHE----------------------------
//URL
#define SNEP_MiaoChe_URL_BrandWall @"http://2.miaocheapp.sinaapp.com/Sina_Index/discontPrice"
#define SNEP_MiaoChe_URL_BrandList @"http://2.miaocheapp.sinaapp.com/Sina_Auto/seriesList"
#define SNEP_MiaoChe_URL_CarTypeList @"http://2.miaocheapp.sinaapp.com/Sina_Auto/specList"
#define SNEP_MiaoChe_URL_AreaList @"http://2.miaocheapp.sinaapp.com/Sina_Area/areaList"
#define SNEP_MiaoChe_URL_Getaddressbylngb @"http://2.miaocheapp.sinaapp.com/Sina_Area/getaddressbylngb"
#define SNEP_MiaoChe_URL_SearchList @"http://2.miaocheapp.sinaapp.com/Sina_Auto/searchList"
//Keyword
#define SNEP_MiaoChe_Keyword_Area @"SNEP_MiaoChe_Keyword_Area"
#define SNEP_MiaoChe_Keyword_CityChanged @"SNEP_MiaoChe_Keyword_CityChanged"

//----------------------------OTHER----------------------------

#define kLoadMoreCellHeigth                     55

// block self
#define WEAKSELF __typeof(self) __weak weakSelf = self;
#define STRONGSELF __typeof(weakSelf) __strong strongSelf = weakSelf;

#endif
