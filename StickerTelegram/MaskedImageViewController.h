//
//  MaskedImageViewController.h
//  StickerTelegram
//
//  Created by Fede Cugliandolo on 15/7/15.
//  Copyright (c) 2015 YiyiSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaskedImageViewController : UIViewController <UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) UIImage *maskedImage;
@property (nonatomic, strong) UIImage *originalImage;

@property (nonatomic, strong) UIDocumentInteractionController *dc;

@end
