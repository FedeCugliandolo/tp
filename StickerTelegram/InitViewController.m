//
//  ViewController.m
//  StickerTelegram
//
//  Created by Fede Cugliandolo on 22/3/15.
//  Copyright (c) 2015 YiyiSoft. All rights reserved.
//

#import "InitViewController.h"
#import "MaskedImageViewController.h"

@interface InitViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    // Drawing
    CGPoint lastPoint;
    CGFloat brushWidth;
    CGFloat red, blue, green;
    BOOL touchSwiped;
    CGBlendMode blendMode;
}

// Drawing
@property (nonatomic, strong) IBOutlet UIImageView *tempDrawImage;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewContainer;
@property (weak, nonatomic) IBOutlet UIView *imageViewContainer;

@end

#define OPACITY .6

@implementation InitViewController

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setColorRed:nil];
    
    // scrollView
    self.scrollViewContainer.contentSize = self.imageView.image ? self.imageView.image.size : CGSizeZero;
    
    // gestures
    UIPanGestureRecognizer *oneFingerDraw   = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onOneFingerDraw:)];
    [oneFingerDraw setMinimumNumberOfTouches:1];
    [oneFingerDraw setMaximumNumberOfTouches:1];
    
    [self.scrollViewContainer addGestureRecognizer:oneFingerDraw];
}

#pragma mark - Drawing

-(void)setScrollViewContainer:(UIScrollView *)scrollViewContainer {
    _scrollViewContainer = scrollViewContainer;
    _scrollViewContainer.minimumZoomScale = 1;
    _scrollViewContainer.maximumZoomScale = 2;
    _scrollViewContainer.delegate = self;
    self.scrollViewContainer.contentSize = self.imageView.image ? self.imageView.image.size : CGSizeZero;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // Necesito este método para poder arrastrar la imagen mientras está zoomeada. Se arrastra con dos dedos.
    NSLog(@"arranca aca");
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageViewContainer;
}

- (void)onOneFingerDraw:(UIPanGestureRecognizer*)sender
{
    // Processing the drawing by using comparing:
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        touchSwiped = NO;
        lastPoint = [sender locationInView:self.tempDrawImage];
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        touchSwiped = YES;
        CGPoint currentPoint = [sender locationInView:self.tempDrawImage];
        
        UIGraphicsBeginImageContext(self.tempDrawImage.frame.size);
        [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.tempDrawImage.frame.size.width, self.tempDrawImage.frame.size.height)];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brushWidth );
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),blendMode);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        [self.tempDrawImage setAlpha:OPACITY];
        UIGraphicsEndImageContext();
        
        lastPoint = currentPoint;
        NSLog(@"se mueve en scroll");
        
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        if(!touchSwiped) {
            UIGraphicsBeginImageContext(self.tempDrawImage.frame.size);
            [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.tempDrawImage.frame.size.width, self.tempDrawImage.frame.size.height)];
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brushWidth);
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, OPACITY);
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
            CGContextStrokePath(UIGraphicsGetCurrentContext());
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(),blendMode);
            CGContextFlush(UIGraphicsGetCurrentContext());
            self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
            [self.tempDrawImage setAlpha:OPACITY];
            UIGraphicsEndImageContext();
        }
        NSLog(@"ended del scroll");
    }
}


- (IBAction) setEraser:(id)sender {
    blendMode = kCGBlendModeClear;
}

- (IBAction) setColorRed:(id)sender {
    red = .914;
    green = 0.119;
    blue = 0.145;
    brushWidth = 20;
    blendMode = kCGBlendModeNormal;
}

- (IBAction)clearScreen:(id)sender {
    self.tempDrawImage.image = nil;
    [self setColorRed:nil];
}

#pragma mark - Image Picker

- (IBAction)showActionSheet:(id)sender {
    
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate=self;
    picker.allowsEditing = YES;
    [picker setSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)];
    [self presentViewController:picker animated:YES completion:Nil];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *img = info[UIImagePickerControllerEditedImage];
    self.imageView.image = img;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showMask"]) {
        MaskedImageViewController *maskedVC = (MaskedImageViewController*)segue.destinationViewController;
        UIImage *original = self.imageView.image;
        UIImage *temp = self.tempDrawImage.image;
        maskedVC.originalImage = original;
        maskedVC.maskedImage = temp;
    }
}

@end
