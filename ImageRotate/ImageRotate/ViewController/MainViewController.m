//
//  MainViewController.m
//  ImageRotate
//
//  Created by Work on 15/7/28.
//  Copyright (c) 2015年 zengqingfu. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (assign, nonatomic) NSInteger count;
@property (nonatomic, strong) UIImage *defaultImg;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.defaultImg = [UIImage imageNamed:@"openImg.png"];
    self.imageView.image = self.defaultImg;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)openPhoto:(id)sender {
    [self LocalPhoto];
}

//打开本地相册
-(void)LocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    
    
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = NO;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}
- (IBAction)rightRotate:(id)sender {
    self.count += 1;
    NSLog(@"count = %ld", self.count);
    UIImage *image = self.imageView.image;
    UIImage *newImg = [self image:image rotation:UIImageOrientationRight];
    self.imageView.image = newImg;
}
- (IBAction)leftRotate:(id)sender {
    self.count -= 1;
    UIImage *image = self.imageView.image;
    UIImage *newImg = [self image:image rotation:UIImageOrientationLeft];
    self.imageView.image = newImg;
}

- (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newPic;
}
- (IBAction)savePhotoAction:(id)sender {
    [self savePhoto];
}

- (void)savePhoto
{
    UIImage *image = self.imageView.image;
    [self saveImageToPhotos:image];
}

- (void)saveImageToPhotos:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
- (void)setCount:(NSInteger)count
{
    while (count < 0) {
        count += 4;
    }
    while (count > 3) {
        count -=4;
    }
    if (count != 0) {
        self.saveButton.enabled = YES;
    } else {
        self.saveButton.enabled = NO;
    }
    _count = count;
    
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
        
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSString *msg = alertView.message;
    if ([msg containsString:@"成功"]) {
        self.imageView.image = self.defaultImg;
        [self buttonEnable:NO];
    };
}
#pragma mark --delegate
//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    NSLog(@"info = %@", info);
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSData *data = nil;
        
        data = UIImagePNGRepresentation(image);
        if (data == nil) {
            data = UIImageJPEGRepresentation(image, 1.0);
        }
        
        if (data == nil) {
            return;
        }
        if (data) {
            [self buttonEnable:YES];
        }
        UIImage *img = [UIImage imageWithData:data];
        self.imageView.image = img;
        [picker dismissViewControllerAnimated:YES completion:nil];
        
    }
    
}
- (void)buttonEnable:(BOOL)enable
{
    self.leftButton.enabled = enable;
    self.rightButton.enabled = enable;
    if (enable == NO) {
        self.saveButton.enabled = enable;
    }
}
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    [picker dismissViewControllerAnimated:YES completion:nil];
//}

@end
