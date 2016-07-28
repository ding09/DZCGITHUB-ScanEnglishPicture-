//
//  ViewController.h
//  身份证号码扫描
//
//  Created by li wei on 16/4/27.
//  Copyright © 2016年 li wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TesseractOCR/TesseractOCR.h>
@interface ViewController : UIViewController<G8TesseractDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITextViewDelegate>
{
    BOOL  PhotoState;
}

@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (weak, nonatomic) IBOutlet UITextView *showResult;
- (IBAction)TakePhoto:(UIButton *)sender;
- (IBAction)Translation:(UIButton *)sender;


@end

