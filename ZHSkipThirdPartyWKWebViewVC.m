//
//  ZHSkipThirdPartyWKWebViewVC.m
//
//
//  Created by Mr.Zhang on 2022/3/20.
//

#import "ZHSkipThirdPartyWKWebViewVC.h"
#import <WebKit/WebKit.h>
#import "OtherPlatformsYouCanUseModel.h"
#import "platformDetailsVC.h"
@interface ZHSkipThirdPartyWKWebViewVC ()<WKNavigationDelegate, WKScriptMessageHandler,WKUIDelegate, UIScrollViewDelegate>
//主要网页视图
@property(nonatomic, strong) WKWebView *webView;

//头部进度条视图
@property(nonatomic, strong) UIProgressView *topProgressView;

//ipa下载链接前缀,通过接口请求返回存储
@property (nonatomic, strong) NSString *ipa_down_url;

//第三方遮罩总视图
@property (weak, nonatomic) IBOutlet UIView *thirdPartyMaskView;

//底部白色遮罩视图
@property (weak, nonatomic) IBOutlet UIView *bottomWhiteMaskView;

@end

@implementation ZHSkipThirdPartyWKWebViewVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view bringSubviewToFront:self.thirdPartyMaskView];
    [self.view bringSubviewToFront:self.bottomWhiteMaskView];
    self.ipa_down_url = @"item://";
   
  //1.5秒后关闭第三方遮罩
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [self.thirdPartyMaskView removeFromSuperview];
            [self.bottomWhiteMaskView removeFromSuperview];
            [self setWebViewDataPage];
        });
    
    //返回上一页按钮
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, 0, 44, 44)];
    [leftButton setImage:[UIImage imageNamed:@"fanhui"] forState:UIControlStateNormal];
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0)];
    [leftButton addTarget:self action:@selector(leftButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = barButtonItem;
            
    //刷新按钮
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(0, 0, 44, 44)];
    [rightButton setImage:[UIImage imageNamed:@"shuaxin"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    //关闭按钮
    UIButton *guanBiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [guanBiButton setFrame:CGRectMake(0, 0, 44, 44)];
    [guanBiButton setImage:[UIImage imageNamed:@"guanbi"] forState:UIControlStateNormal];
    [guanBiButton addTarget:self action:@selector(CloseCurrentPage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *guanBiButtonItem = [[UIBarButtonItem alloc] initWithCustomView:guanBiButton];
    self.navigationItem.rightBarButtonItems = @[guanBiButtonItem,rightButtonItem];
    
    self.navigationItem.title = self.mainPageTitleString;
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.tabBarController.tabBar .hidden = YES;
}
-(void)CloseCurrentPage{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.returnPageBlock) {
        self.returnPageBlock();
    }
}
-(void)rightClick{

    [self.webView reload];
         
}

- (void)setWebViewDataPage{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.preferences = [[WKPreferences alloc] init];
    configuration.preferences.javaScriptEnabled = YES;
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    //成功
    [userContentController addScriptMessageHandler:self name:@"RepaymentSuccessful"];
    //失败
    [userContentController addScriptMessageHandler:self name:@"RepaymentFailure"];
    //发起还款
    [userContentController addScriptMessageHandler:self name:@"RepaymentInitiate"];
    configuration.userContentController = userContentController;

            
            
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kStatusBarFrameHeight + kNavigationBarHeight, kScreenWidth, kScreenHeight- [UIDevice vg_navigationFullHeight] -[UIDevice vg_safeDistanceBottom]) configuration:configuration];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.scrollView.delegate = self;
    [self.view addSubview:self.webView];
    [self.view addSubview:self.topProgressView];
    // 给webview添加监听
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.loadWebLinkString]]];
   
            
         
}

#pragma mark --- WKScriptMessageHandler ---

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
            NSLog(@"message.name:%@", message.name);
            NSLog(@"message.body:%@", message.body);//JS传过来的参数
            //TODO:根据注入js的name做想做的操作
            
    if ([message.name isEqualToString:@"RepaymentSuccessful"]) {

        [self RepaymentSuccessful];
    }
    if ([message.name isEqualToString:@"RepaymentFailure"]) {
        [self.navigationController popViewControllerAnimated:YES];

    }
    
    if ([message.name isEqualToString:@"RepaymentInitiate"]) {
        [self RepaymentInitiate];
    }
}
#pragma mark - 还款成功
-(void)RepaymentSuccessful{
    
}

#pragma mark - 发起还款
-(void)RepaymentInitiate{
   
}



#pragma mark ---- 加载网页标题
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqual:@"estimatedProgress"] && object == self.webView) {
        [self.topProgressView setAlpha:1.0f];
        [self.topProgressView setProgress:self.webView.estimatedProgress animated:YES];
        if (self.webView.estimatedProgress  >= 1.0f) {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.topProgressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.topProgressView setProgress:0.0f animated:YES];
            }];
        }
    }else if ([keyPath isEqualToString:@"title"])
    {
        if (object == self.webView)
        {
            self.navigationItem.title = self.webView.title;
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}



#pragma mark ---- 懒加载
- (UIProgressView *)topProgressView{
    if (!_topProgressView) {
        self.topProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, kStatusBarFrameHeight + kNavigationBarHeight, CGRectGetWidth(self.view.frame), 2)];
        self.topProgressView.progressTintColor = kMainColor;
    }
    return _topProgressView;
}
#pragma mark ---- 返回上一个网页
-(void)leftButtonDidClick:(UIButton *)sender{
            
    [self.webView goBack];

            


}
#pragma mark ---- 返回首页
-(void)returnToTheInitialPage{
    //返回首页
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSArray<UIViewController *> *vcs = self.navigationController.viewControllers;
        [self.navigationController popToViewController:vcs.firstObject animated:YES];
        [vcs.firstObject dismissViewControllerAnimated:YES completion:^{
             
        }];
    });
}
#pragma mark - 返回指定控制器
-(void)backDesignatedController{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([NSStringFromClass(controller.class) isEqualToString:self.returnsPreviousVCName]) {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }

   
}



#pragma mark - 可以跳转appStore 可以下载ipa
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if(webView != self.webView) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *url = navigationAction.request.URL;
    if ([url.absoluteString containsString:@"apple.com"])
    {
        if ([app canOpenURL:url])
        {
            [app openURL:url options:@{} completionHandler:^(BOOL success) {
                
            }];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    if ([url.absoluteString containsString:EMPTY_STRING(self.ipa_down_url)?@"":self.ipa_down_url]) {
        [app openURL:url options:@{} completionHandler:^(BOOL success) {
            
        }];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}





- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 因此这里要记得移除handlers
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"RepaymentSuccessful"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"RepaymentFailure"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"RepaymentInitiate"];
   
}
- (void)dealloc
{
    [self releaseWebView];
}
#pragma mark - 移除相关通知
- (void)releaseWebView{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    self.webView.scrollView.delegate=nil;
    self.webView.navigationDelegate = nil;
    self.webView.UIDelegate = nil;
    [self.webView loadHTMLString:@"" baseURL:nil];
    [self.webView stopLoading];
    if (self.webView.superview) {
        [self.webView removeFromSuperview];
    }
    self.webView = nil;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}
@end
