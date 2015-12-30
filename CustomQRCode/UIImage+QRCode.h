//
//  UIImage+QRCode.h
//  CustomQRCode
//
//  Created by chengxun on 15/12/30.
//  Copyright © 2015年 chengxun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QRCode)
+ (UIImage *)imageOfQRCodeFromUrl:(NSString *)netWorkAddress
                         codeSize:(CGFloat)codeSize;
+ (UIImage *)imageOfQRCodeFromUrl:(NSString *)netWorkAddress
                         codeSize:(CGFloat)codeSize
                              red:(NSUInteger)red
                            green:(NSUInteger)green
                             blue:(NSUInteger)blue;
+ (UIImage *)imageInsertedImage:(UIImage *)originImage
                    insertImage:(UIImage *)insertImage
                         radius:(CGFloat)radius;
@end
