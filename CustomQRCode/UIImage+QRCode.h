//
//  UIImage+QRCode.h
//  CustomQRCode
//
//  Created by chengxun on 15/12/30.
//  Copyright © 2015年 chengxun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QRCode)
+ (UIImage*)imageOfQRCodeFromUrl:(NSString*)netWorkAddress codeSize:(CGFloat)codeSize;
@end