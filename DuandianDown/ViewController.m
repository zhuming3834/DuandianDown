//
//  ViewController.m
//  DuandianDown
//
//  Created by HGDQ on 15/10/27.
//  Copyright (c) 2015年 HGDQ. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
//http://ftp-idc.pconline.com.cn/ceb7f6f871c6ec356127881b13eb8e3e/pub/download/201010/WPS2015.exe
@interface ViewController (){
	AFHTTPRequestOperationManager *_manage;
	AFHTTPRequestOperation *_downloadOperation;
	NSURL *_url;
	NSTimer *_timer;
	CGFloat _currentByte;
	CGFloat _totalByte;
	CGFloat _lastByte;
	CGFloat _nowByte;
	BOOL _flag;
}
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *proLabel;

@property (weak, nonatomic) IBOutlet UILabel *downLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	_flag = NO;
	_url = [NSURL URLWithString:@"http://ftp-idc.pconline.com.cn/ceb7f6f871c6ec356127881b13eb8e3e/pub/download/201010/WPS2015.exe"];
	self.progressView.progress = 0;
	// Do any additional setup after loading the view, typically from a nib.
}
/**
 *  网络监测按钮
 *
 *  @param sender sender description
 */
- (IBAction)testNetwork:(id)sender {
	_manage = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:_url];
	[_manage.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
		if (status == AFNetworkReachabilityStatusUnknown || status == AFNetworkReachabilityStatusNotReachable) {
			UIAlertView * netStatusAl = [[UIAlertView alloc] initWithTitle:@"服务器连接失败" message:@"请检查网络连接" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
			[netStatusAl show];  //请检查网络连接
		}
	}];
}
/**
 *  开始下载按钮点击事件
 *
 *  @param sender sender description
 */
- (IBAction)startDownload:(id)sender {
	//制作一个请求头
	NSURLRequest *request = [NSURLRequest requestWithURL:_url];
	_downloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	//设置一个下载路径
	NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *downloadPath = [cacheDirectory stringByAppendingPathComponent:@"word2007.exe"];
	NSLog(@"downloadPath = %@",downloadPath);
	_downloadOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:downloadPath append:YES];
	__weak ViewController *wself = self;
	//下载进度
	[_downloadOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
		_totalByte = totalBytesExpectedToRead; //全部字节
		_currentByte = totalBytesRead;  //已经下载的字节
		wself.downLabel.text = [NSString stringWithFormat:@"%.2fMB/%.2fMB",_currentByte/1024/1024,_totalByte/1024/1024];
		//这里会不断调用，保证定时器只是一个 就只需要执行一次
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			//减少定时间隔 可以是测量的网速 更加接近当前网速
			_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(currentSpeed) userInfo:nil repeats:YES];
		});
		//下载进度
		float progress = (float)totalBytesRead/totalBytesExpectedToRead;
		wself.progressView.progress = progress;
		wself.proLabel.text = [NSString stringWithFormat:@"下载进度:%f%%",progress*100];
	}];
	[_downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		; //下载完成
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		; //下载出错
	}];
	//开始下载
	[_downloadOperation start];
}
/**
 *  暂停开始按钮
 *
 *  @param sender sender description
 */
- (IBAction)stop_start:(id)sender {
	UIButton *button = (UIButton *)sender;
	//开始
	if (_downloadOperation.isPaused) {
		[_downloadOperation resume];
		//恢复定时器
		_timer.fireDate = [NSDate distantPast];
		[button setTitle:@"暂停" forState:UIControlStateNormal];
	}
	//暂停
	else{
		[_downloadOperation pause];
		//暂停定时器
		_timer.fireDate = [NSDate distantFuture];
		[button setTitle:@"继续" forState:UIControlStateNormal];
	}
}
/**
 *  定时器1秒定时事件 
 *  监测网速
 */
- (void)currentSpeed{
	_flag = !_flag;
	if (_flag == YES) {//获取上一秒下载的Byte数
		_lastByte = _currentByte;
	}
	if (_flag == NO) { //获取当前的下载的Byte数
		_nowByte = _currentByte;
		_speedLabel.text = [NSString stringWithFormat:@"当前网速:%.2fkB/s",(_nowByte - _lastByte)/1000];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end




















