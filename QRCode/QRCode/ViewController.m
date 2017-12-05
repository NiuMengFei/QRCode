//
//  ViewController.m
//  QRCode
//
//  Created by leo on 17/8/17.
//  Copyright © 2017年 huashen. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#define Screen_Width  [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

static const char *qr_scan_queue = "qr_scan_queue";

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>{
   
    AVCaptureSession *_session ;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //扫描页面UI实现
    //[self prepareUI] ;
    //设置扫描范围
    [self declareScanFrame];
    //开始扫描
    [self startScaning];
}

-(void)prepareUI{
   
    UIView *maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,Screen_Width, Screen_Height)];
    maskView.backgroundColor = [UIColor blackColor] ;
    maskView.alpha           = 0.5 ;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, Screen_Width, Screen_Height)] ;
    [path appendPath:[[UIBezierPath bezierPathWithRect:CGRectMake(Screen_Width * 0.14,100, Screen_Width*0.72,Screen_Width*0.72)] bezierPathByReversingPath]];
    CAShapeLayer *layer = [CAShapeLayer layer] ;
    layer.path = path.CGPath ;
    maskView.layer.mask = layer ;
    [self.view addSubview:maskView];
}

-(void)declareScanFrame{

    CALayer *layer = [[CALayer alloc]init];
    layer.frame = CGRectMake(Screen_Width * 0.14,100, Screen_Width*0.72,Screen_Width*0.72);
    layer.backgroundColor = [UIColor clearColor].CGColor ;
    layer.borderColor = [UIColor yellowColor].CGColor ;
    layer.borderWidth = 1 ;
    [self.view.layer addSublayer:layer] ;
}

-(void)startScaning{
    /*
     获取调用系统摄像机的功能
     */
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] ;
    /*
     建立输入
     */
    NSError *error ;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc]initWithDevice:device error:&error];
    /*
     建立输出
     */
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    
    output.rectOfInterest = CGRectMake(100.0f/Screen_Height,0.14, Screen_Width/Screen_Height *0.72 ,0.72);//设置扫描范围（输出范围）
   
    dispatch_queue_t qr_queue = dispatch_queue_create(qr_scan_queue, NULL) ;
    [output setMetadataObjectsDelegate:self queue:qr_queue] ; //设置输出代理

    /*
     建立一个数据传输的会话连接以维持持续扫描
     */
    AVCaptureSession *session = [[AVCaptureSession alloc]init];
    session.sessionPreset = AVCaptureSessionPreset1920x1080 ;
    [session addInput:input];
    [session addOutput:output];
    [output setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]] ; // 设置输出类型 只有输入类型为二维码时才会调用代理方法
    
    // 预览类
    AVCaptureVideoPreviewLayer *_layer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:session];
    [_layer setVideoGravity:AVLayerVideoGravityResizeAspectFill] ;
    [_layer setFrame:self.view.frame] ;//视频窗口用来展示镜头捕获到的图像
    [self.view.layer insertSublayer:_layer atIndex:0];    
    [session startRunning] ;//开始扫描
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    NSLog(@"获取到扫描数据%@",metadataObjects) ;
}




@end
