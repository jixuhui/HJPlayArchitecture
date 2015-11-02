//
//  HJConstant.h
//  HJArchitecture
//
//  Created by jixuhui on 15/10/9.
//  Copyright (c) 2015年 private. All rights reserved.
//

#ifndef HJArchitecture_HJConstant_h
#define HJArchitecture_HJConstant_h

//----------------------------about screen----------------------------
#define kScreenWidth					[UIScreen mainScreen].bounds.size.width
#define kScreenHeight					[UIScreen mainScreen].bounds.size.height

//----------------------------VALID CHECKING----------------------------
#define CHECK_VALID_STRING(__string)               (__string && [__string isKindOfClass:[NSString class]] && [__string length])
#define CHECK_VALID_NUMBER(__aNumber)               (__aNumber && [__aNumber isKindOfClass:[NSNumber class]])
#define CHECK_VALID_ARRAY(__aArray)                 (__aArray && [__aArray isKindOfClass:[NSArray class]] && [__aArray count])
#define CHECK_VALID_DICTIONARY(__aDictionary)       (__aDictionary && [__aDictionary isKindOfClass:[NSDictionary class]] && [__aDictionary count])

//----------------------------miaoche----------------------------
//URL
#define SNEP_MiaoChe_URL_BrandWall                        @"http://2.miaocheapp.sinaapp.com/Sina_Index/discontPrice"
#define SNEP_MiaoChe_URL_BrandList @"http://2.miaocheapp.sinaapp.com/Sina_Auto/seriesList"
#define SNEP_MiaoChe_URL_CarTypeList @"http://2.miaocheapp.sinaapp.com/Sina_Auto/specList"
#define SNEP_MiaoChe_URL_AreaList @"http://2.miaocheapp.sinaapp.com/Sina_Area/areaList"
#define SNEP_MiaoChe_URL_Getaddressbylngb @"http://2.miaocheapp.sinaapp.com/Sina_Area/getaddressbylngb"
#define SNEP_MiaoChe_URL_SearchList @"http://2.miaocheapp.sinaapp.com/Sina_Auto/searchList"
//Keyword
#define SNEP_MiaoChe_Keyword_Area @"SNEP_MiaoChe_Keyword_Area"
#define SNEP_MiaoChe_Keyword_CityChanged @"SNEP_MiaoChe_Keyword_CityChanged"

//------other

#define kScreenWidth					[UIScreen mainScreen].bounds.size.width
#define kScreenHeight					[UIScreen mainScreen].bounds.size.height
#define kLoadMoreCellHeigth                     55

#endif
