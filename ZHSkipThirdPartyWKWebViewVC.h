//
//  ZHSkipThirdPartyWKWebViewVC.h
//  
//
//  Created by Mr.Zhang on 2022/3/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ReturnPageBlock)(void);
@interface ZHSkipThirdPartyWKWebViewVC : UIViewController
//需要加载的网页链接
@property (nonatomic, strong) NSString *loadWebLinkString;

//页面标题
@property (nonatomic, copy) NSString *mainPageTitleString;

//点击返回按钮执行的Block
@property (nonatomic, copy) ReturnPageBlock returnPageBlock;

//返回上一个控制器的名称
@property(nonatomic,strong)NSString *returnsPreviousVCName;

@end

NS_ASSUME_NONNULL_END
