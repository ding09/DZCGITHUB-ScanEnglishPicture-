//
//  DZCResult.h
//  身份证号码扫描
//
//  Created by li wei on 16/7/21.
//  Copyright © 2016年 li wei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface trans_result :NSObject
@property (nonatomic , copy) NSString              * src;
@property (nonatomic , copy) NSString              * dst;

@end

@interface DZCResult :NSObject
@property (nonatomic , copy) NSString              * to;
@property (nonatomic , strong) NSArray              * trans_result;
@property (nonatomic , copy) NSString              * from;

@end

