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

-(void)viewDidLoad {
    [super viewDidLoad];
    [self startDrawing:nil];
    
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

- (IBAction) startDrawing:(id)sender {
    red = .914;
    green = 0.119;
    blue = 0.145;
    brushWidth = 20;
    blendMode = kCGBlendModeNormal;
}

- (IBAction)clearScreen: (id)sender {
    self.tempDrawImage.image = nil;
    [self startDrawing:nil];
}

#pragma mark - Image Picker

- (IBAction)showActionSheet:(id)sender {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Open Photo" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Tomar fotografía"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                                                             picker.delegate=self;
                                                             picker.allowsEditing = YES;
                                                             [picker setSourceType:(UIImagePickerControllerSourceTypeCamera)];
                                                             [self presentViewController:picker animated:YES completion:Nil];
                                                         }];
    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"Seleccionar Imagen"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                                                             picker.delegate=self;
                                                             picker.allowsEditing = YES;
                                                             [picker setSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)];
                                                             [self presentViewController:picker animated:YES completion:Nil];
                                                         }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        [self dismiss dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [actionSheet addAction:libraryAction];
    [actionSheet addAction:cameraAction];
    [actionSheet addAction:cancelAction];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *img = info[UIImagePickerControllerEditedImage];
    self.imageView.image = img;
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Segues
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
