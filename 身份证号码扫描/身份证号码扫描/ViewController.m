//
//  ViewController.m
//  身份证号码扫描
//
//  Created by li wei on 16/4/27.
//  Copyright © 2016年 li wei. All rights reserved.
//

#import "ViewController.h"
#import <TesseractOCR/TesseractOCR.h>
#import "MBProgressHUD.h"
#import "DZC_Request_Mode.h"
#import "WHC_DataModel.h"
#import "DZCResult.h"
#import "PECropViewController.h"
@interface ViewController ()

{
    MBProgressHUD *MBHUD;
   
}
@property (weak,nonatomic)UIImage *choiceImage;
@property (nonatomic) UIPopoverController *popover;
@property (weak,nonatomic)UIButton *btn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MBHUD=[[MBProgressHUD alloc]init];
    [self.view addSubview:MBHUD];
    self.operationQueue =[[NSOperationQueue alloc]init];
    self.showResult.delegate=self;
    
    self.navigationItem.title=@"英语翻译";
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_background"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
    
    
    
   
   
}
-(void)Check
{
    //UIImage *image=[self grayscale:[UIImage imageNamed:@"ceshitwo"] type:0];
    [self recognizeImageWithTesseract:[UIImage imageNamed:@"ceshi"]];
//    UIImageView *imgview=[[UIImageView alloc]initWithFrame:CGRectMake(10, 100, 200, 50)];
//    imgview.image=[self grayscale:[UIImage imageNamed:@"ceshi"] type:3];
//    [self.view addSubview:imgview];
}
-(void)recognizeImageWithTesseract:(UIImage *)image
{
    // Animate a progress activity indicator
    
    [MBHUD show:YES];
    // Create a new `G8RecognitionOperation` to perform the OCR asynchronously
    // It is assumed that there is a .traineddata file for the language pack
    // you want Tesseract to use in the "tessdata" folder in the root of the
    // project AND that the "tessdata" folder is a referenced folder and NOT
    // a symbolic group in your project
    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] init];
    
    
    // Use the original Tesseract engine mode in performing the recognition
    // (see G8Constants.h) for other engine mode options
    operation.tesseract.engineMode = G8OCREngineModeTesseractOnly;
    
    // Let Tesseract automatically segment the page into blocks of text
    // based on its analysis (see G8Constants.h) for other page segmentation
    // mode options
    operation.tesseract.pageSegmentationMode = G8PageSegmentationModeAutoOnly;
    
    // Optionally limit the time Tesseract should spend performing the
    // recognition
    //operation.tesseract.maximumRecognitionTime = 1.0;
    
    // Set the delegate for the recognition to be this class
    // (see `progressImageRecognitionForTesseract` and
    // `shouldCancelImageRecognitionForTesseract` methods below)
    operation.delegate = self;
    
    // Optionally limit Tesseract's recognition to the following whitelist
    // and blacklist of characters
    //operation.tesseract.charWhitelist = @"0123456789";
    //operation.tesseract.charBlacklist = @"56789";
    
    // Set the image on which Tesseract should perform recognition
    
    operation.tesseract.image = image;
    
    // Optionally limit the region in the image on which Tesseract should
    // perform recognition to a rectangle
    //operation.tesseract.rect = CGRectMake(20, 20, 100, 100);
    
    // Specify the function block that should be executed when Tesseract
    // finishes performing recognition on the image
    operation.recognitionCompleteBlock = ^(G8Tesseract *tesseract) {
        // Fetch the recognized text
        
        
        self.showResult.text= tesseract.recognizedText;
        [G8Tesseract clearCache];
        [MBHUD hide:YES];
        // Remove the animated progress activity indicator
       
        
        // Spawn an alert with the recognized text
        
    };
    
    // Display the image to be recognized in the view
    //self.imageToRecognize.image = operation.tesseract.thresholdedImage;
    
    // Finally, add the recognition operation to the queue
    [self.operationQueue addOperation:operation];
}
-(void)handleResult:(NSString *)_str
{
    [MBHUD show:YES];
    _str=[_str stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    [DZC_Request_Mode JSONDataWithUrl:_str success:^(id json) {
        
    DZCResult *result= [WHC_DataModel dataModelWithJsonData:json className:[DZCResult class]];
        for(trans_result *trans in result.trans_result)
        {
            NSLog(@"结果%@",trans.dst);
            self.showResult.text = [self.showResult.text stringByAppendingFormat:@"\n%@",trans.dst];
        }
        [MBHUD hide:YES];
    } fail:^(NSError *error) {
        
        [MBHUD hide:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)TakePhoto:(UIButton *)sender {
//    UIImagePickerControllerSourceType sourceType=UIImagePickerControllerSourceTypeCamera;
//    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
//    {
//        sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
//    }
//    UIImagePickerController *picker=[[UIImagePickerController alloc]init];
//    picker.delegate=self;
//    picker.allowsEditing=YES;
//    picker.sourceType=sourceType;
//    [self presentViewController:picker animated:YES completion:nil];
    [self cameraButtonAction:nil];
    
}

- (IBAction)Translation:(UIButton *)sender {
    if (![self.showResult.text isEqualToString:@""]&&PhotoState==YES)
    {
        [self handleResult:self.showResult.text];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"友情提醒" message:@"拍摄图片没有识别成功或者没有拍摄图片，请重新拍摄要识别的内容" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
}

#pragma mark -

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    [self recognizeImageWithTesseract:croppedImage];
    PhotoState=YES;
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    PhotoState=NO;
}

#pragma mark -

- (void)openEditor:(id)sender
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = sender;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (void)cameraButtonAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Photo Album", nil), nil];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Camera", nil)];
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [actionSheet showFromBarButtonItem:self.btn animated:YES];
    } else {
        [actionSheet showFromToolbar:self.navigationController.toolbar];
    }
}

- (void)showCamera
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.popover.isPopoverVisible) {
            [self.popover dismissPopoverAnimated:NO];
        }
        
        self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        [self.popover presentPopoverFromBarButtonItem:self.btn
                             permittedArrowDirections:UIPopoverArrowDirectionAny
                                             animated:YES];
    } else {
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

- (void)openPhotoAlbum
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.popover.isPopoverVisible) {
            [self.popover dismissPopoverAnimated:NO];
        }
        
        self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        [self.popover presentPopoverFromBarButtonItem:self.btn
                             permittedArrowDirections:UIPopoverArrowDirectionAny
                                             animated:YES];
    } else {
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Photo Album", nil)]) {
        [self openPhotoAlbum];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Camera", nil)]) {
        [self showCamera];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info

{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    self.choiceImage = image;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.popover.isPopoverVisible) {
            [self.popover dismissPopoverAnimated:NO];
        }
        
        [self openEditor:nil];
    } else {
        [picker dismissViewControllerAnimated:YES completion:^{
            [self openEditor:image];
        }];
    }
    
}

-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    return YES;
}

#pragma mark-UITextFieldDelegate代理事件
-(void)textViewDidBeginEditing:(UITextView *)textView
{
     [self animateTextField:textView up:YES];
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    [self animateTextField:textView up:NO];
}

//视图上移的方法
- (void) animateTextField: (UITextView *) textField up: (BOOL) up
{
    //设置视图上移的距离，单位像素
    const int movementDistance = 100; // tweak as needed
    //三目运算，判定是否需要上移视图或者不变
    int movement = (up ? -movementDistance : movementDistance);
    //设置动画的名字
    [UIView beginAnimations: @"Animation" context: nil];
    //设置动画的开始移动位置
    [UIView setAnimationBeginsFromCurrentState: YES];
    //设置动画的间隔时间
    [UIView setAnimationDuration: 0.20];
    //设置视图移动的位移
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    //设置动画结束
   
 [UIView commitAnimations];
}

//屏幕点击事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
