//
//  DZC_Request_Mode.h
//  DZCAFNetworking
//
//  Created by li wei on 16/4/18.
//  Copyright © 2016年 li wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
@interface DZC_Request_Mode : NSObject
//检测网络状态
+ (void)netWorkStatus;

//JSON方式获取数据
+ (void)JSONDataWithUrl:(NSString *)url success:(void (^)(id json))success fail:(void (^)(NSError *))fail;
//xml方式获取数据
+ (void)XMLDataWithUrl:(NSString *)urlStr success:(void (^)(id xml))success fail:(void (^)())fail ;
//post提交json数据
+ (void)postJSONWithUrl:(NSString *)urlStr parameters:(id)parameters success:(void (^)(id responseObject))success fail:(void (^)())fail ;
//下载文件
+ (void)sessionDownloadWithUrl:(NSString *)urlStr success:(void (^)(NSURL *fileURL))success fail:(void (^)())fail;
//文件上传－自定义上传文件名
+ (void)postUploadWithUrl:(NSString *)urlStr fileUrl:(NSURL *)fileURL fileName:(NSString *)fileName fileType:(NSString *)fileTye progress:(void(^)())progress success:(void (^)(id responseObject))success fail:(void (^)())fail;
//文件上传－随机生成文件名
+ (void)postUploadWithUrl:(NSString *)urlStr fileUrl:(NSURL *)fileURL progress:(void(^)())progress success:(void (^)(id responseObject))success fail:(void (^)())fail  ;
@end
