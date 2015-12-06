//
//  Sticker.h
//  Stickers Telegram
//
//  Created by Fede Cugliandolo on 5/12/15.
//  Copyright © 2015 YiyiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Sticker : NSObject

@property (nonatomic, strong) NSURL *webpImageDataURL;
@property (nonatomic, strong) NSURL *pngImageDataURL;
@property (nonatomic, strong) UIImage *stickerImage;

@end
