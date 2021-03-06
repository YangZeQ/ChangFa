//
//  CFAgencyReturnViewController.m
//  ChangFa
//
//  Created by Developer on 2018/2/5.
//  Copyright © 2018年 dev. All rights reserved.
//

#import "CFAgencyReturnViewController.h"
#import "CFAgencyReturnStatusViewController.h"
#import "ScanViewController.h"
#import "CFPickView.h"
#import "CFReasonTextView.h"
#import "MachineModel.h"
#define MAX_LIMIT_NUMS 200
@interface CFAgencyReturnViewController ()<scanViewControllerDelegate, UITextViewDelegate>
@property (nonatomic, strong)UIView *machineNumberView;
@property (nonatomic, strong)UILabel *machineNumber;
@property (nonatomic, strong)UIView *lineView;

@property (nonatomic, strong)UIView *retreatReasonView;
@property (nonatomic, strong)UIButton *retreatResonButton;
@property (nonatomic, strong)CFPickView *pickReaseonView;
@property (nonatomic, strong)UIView *vagueView;
@property (nonatomic, strong)CFReasonTextView *reasonTextView;
@property (nonatomic, strong)UILabel *placeHolder;
@property (nonatomic, strong)MachineModel *model;
@end

@implementation CFAgencyReturnViewController
- (CFPickView *)pickReaseonView{
    if (_pickReaseonView == nil) {
        _pickReaseonView = [[CFPickView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 520 * screenHeight)];
        _pickReaseonView.sourceArray = @[@"型号不符", @"退", @"换"];
        _pickReaseonView.selectedInfo = _pickReaseonView.sourceArray[0];
        _pickReaseonView.numberOfComponents = 1;
        self.vagueView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        [self.pickReaseonView.cancelButton addTarget:self action:@selector(pickViewCancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.pickReaseonView.sureButton addTarget:self action:@selector(pickViewsuerButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _vagueView.hidden = YES;
        [self.view addSubview:_vagueView];
        [self.view addSubview:_pickReaseonView];
    }
    return _pickReaseonView;
}
- (UIView *)vagueView{
    if (_vagueView == nil) {
        _vagueView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _vagueView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"返厂";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"fanhuiwhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonClick)];
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"fanhuiwhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonClick)];
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"申请记录" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonClick)];
    //    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    self.view.backgroundColor = BackgroundColor;
    // Do any additional setup after loading the view.
    [self createRetreatView];
    
}
- (void)createRetreatView{
//    [self scanViewWithText:@"农机信息" Place:nil ScanText:@"农机扫码" ScanImage:@"scanCompany" ViewFrame:CGRectMake(0, navHeight, self.view.frame.size.width, 338 * screenHeight) ScanButtonFrame:CGRectMake(self.view.frame.size.width / 2 - 49 * screenWidth, 130 * screenHeight, 98 * screenWidth, 98 * screenHeight) ScanType:@"scanMachineBarCode"];

    UIView *machineView = [[UIView alloc]initWithFrame:CGRectMake(30 * screenWidth, navHeight + 20 * screenHeight, CF_WIDTH - 60 * screenWidth, 220 * screenHeight)];
    machineView.backgroundColor = [UIColor whiteColor];
    machineView.layer.cornerRadius = 20 * screenWidth;
    [self.view addSubview:machineView];
    UIImageView *machineImage = [[UIImageView alloc]initWithFrame:CGRectMake(20 * screenWidth, 20 * screenHeight, 180 * screenWidth, 180 * screenHeight)];
    switch ([_machineModel.carType integerValue]) {
        case 1:
            machineImage.image = [UIImage imageNamed:@"Agency_Tractors"];
            break;
        case 2:
            machineImage.image = [UIImage imageNamed:@"Agency_Harvester"];
            break;
        case 3:
            machineImage.image = [UIImage imageNamed:@"Agency_RiceTransplanter"];
            break;
        case 4:
            machineImage.image = [UIImage imageNamed:@"Agency_Dryer"];
            break;
        default:
            break;
    }
    [machineView addSubview:machineImage];
    UILabel *machineNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(machineImage.frame.size.width + machineImage.frame.origin.x + 20 * screenWidth, 50 * screenHeight, machineView.frame.size.width - 240 * screenWidth, 26 * screenHeight)];
    machineNameLabel.text = [NSString stringWithFormat:@"名称：%@", _machineModel.productName];
    machineNameLabel.font = CFFONT14;
    machineNameLabel.textColor = BlackTextColor;
    [machineView addSubview:machineNameLabel];
    UILabel *machineTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(machineNameLabel.frame.origin.x, machineNameLabel.frame.size.height + machineNameLabel.frame.origin.y + 26 * screenHeight, machineNameLabel.frame.size.width, machineNameLabel.frame.size.height)];
    machineTypeLabel.text = [NSString stringWithFormat:@"型号：%@", _machineModel.productModel];
    machineTypeLabel.font = CFFONT14;
    machineTypeLabel.textColor = BlackTextColor;
    [machineView addSubview:machineTypeLabel];
    UILabel *machineNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(machineNameLabel.frame.origin.x, machineTypeLabel.frame.size.height + machineTypeLabel.frame.origin.y + 26 * screenHeight, machineNameLabel.frame.size.width, machineNameLabel.frame.size.height)];
    machineNumberLabel.text = [NSString stringWithFormat:@"车架号：%@", _machineModel.productBarCode];
    machineNumberLabel.font = CFFONT14;
    machineNumberLabel.textColor = [UIColor grayColor];
    [machineView addSubview:machineNumberLabel];
    
    _retreatReasonView = [[UIView alloc]initWithFrame:CGRectMake(30 * screenWidth, machineView.frame.size.height + machineView.frame.origin.y + 30 * screenHeight, CF_WIDTH - 60 * screenWidth, 588 * screenHeight)];
    _retreatReasonView.layer.cornerRadius = 20 * screenWidth;
    _retreatReasonView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_retreatReasonView];
    
    UILabel *retreatReasonLabel = [[UILabel alloc]initWithFrame:CGRectMake(30 * screenWidth, 0, (_retreatReasonView.frame.size.width - 60 * screenWidth) / 3, 88 * screenHeight)];
    retreatReasonLabel.text = @"返厂原因";
    retreatReasonLabel.textColor = BlackTextColor;
    retreatReasonLabel.font = CFFONT14;
    [_retreatReasonView addSubview:retreatReasonLabel];
    _retreatResonButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _retreatResonButton.frame = CGRectMake(retreatReasonLabel.frame.size.width + retreatReasonLabel.frame.origin.x, 0, retreatReasonLabel.frame.size.width, retreatReasonLabel.frame.size.height);
    _retreatResonButton.titleLabel.font = CFFONT14;
    [_retreatResonButton setTitle:@"选择原因" forState:UIControlStateNormal];
    [_retreatResonButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_retreatResonButton addTarget:self action:@selector(chooseRetreatReason) forControlEvents:UIControlEventTouchUpInside];
    [_retreatReasonView addSubview:_retreatResonButton];
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(30 * screenWidth, retreatReasonLabel.frame.size.height - 2 * screenHeight, _retreatReasonView.frame.size.width - 60 * screenWidth, 2 * screenHeight)];
    lineLabel.backgroundColor = BackgroundColor;
    [_retreatReasonView addSubview:lineLabel];
    _reasonTextView = [[CFReasonTextView alloc]initWithFrame:CGRectMake(30 * screenWidth, _retreatResonButton.frame.size.height, _retreatReasonView.frame.size.width - 60 * screenWidth, 500 * screenHeight)];
//    _reasonTextView.delegate = self;
    _reasonTextView.layer.cornerRadius = 20 * screenWidth;
    _reasonTextView.placeholder = [NSString stringWithFormat:@"原因描述：（必填，%d字以内）", MAX_LIMIT_NUMS];
    _reasonTextView.maxNumberOfLines = 10;
    _reasonTextView.delegate = self;
    self.reasonTextView.textNumberLabel.text = [NSString stringWithFormat:@"0/%d", MAX_LIMIT_NUMS];
    [_retreatReasonView addSubview:_reasonTextView];
    [_reasonTextView textValueDidChanged:^(NSString *text, CGFloat textHeight) {
        CGRect frame = _reasonTextView.frame;
        frame.size.height = textHeight;
        _reasonTextView.frame = frame;
    }];
    
//    [self setupPlaceHolder];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.frame = CGRectMake(30 * screenWidth, _retreatReasonView.frame.size.height + _retreatReasonView.frame.origin.y + 120 * screenHeight, self.view.frame.size.width - 60 * screenWidth, 100 * screenHeight);
    submitButton.layer.cornerRadius = 20 * screenWidth;
    [submitButton setTitle:@"提交" forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton setBackgroundColor:ChangfaColor];
    [submitButton addTarget:self action:@selector(submitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitButton];
}
- (void)submitButtonClick{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定返厂" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    //    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:@"提示"];
    //    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 2)];
    //    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, 2)];
    //    [alert setValue:alertControllerStr forKey:@"attributedTitle"];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self submitRetreatRequest];
    }];
    [sureAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [alert addAction:cancelAction];
    [alert addAction:sureAction];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}
#pragma mark -选择退换原因
- (void)chooseRetreatReason{
    [UIView animateWithDuration:0.3 animations:^{
        self.pickReaseonView.frame = CGRectMake(0, self.view.frame.size.height - 520 * screenHeight, self.view.frame.size.width, 520 * screenHeight);
    }];
}
- (void)pickViewCancelButtonClick{
    self.vagueView.hidden = YES;
    CGRect pickViewFrame = self.pickReaseonView.frame;
    [UIView animateWithDuration:0.3 animations:^{
        self.pickReaseonView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, pickViewFrame.size.width, pickViewFrame.size.height);
    }];
}
- (void)pickViewsuerButtonClick{
    [self.retreatResonButton setTitle:self.pickReaseonView.selectedInfo forState:UIControlStateNormal];
    self.vagueView.hidden = YES;
    CGRect pickViewFrame = self.pickReaseonView.frame;
    [UIView animateWithDuration:0.3 animations:^{
        self.pickReaseonView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, pickViewFrame.size.width, pickViewFrame.size.height);
    }];
}
- (void)scanViewWithText:(NSString *)text
                   Place:(NSString *)place
                ScanText:(NSString *)scanText
               ScanImage:(NSString *)scanImage
               ViewFrame:(CGRect)viewFrame
         ScanButtonFrame:(CGRect)scanButtonFrame
                ScanType:(NSString *)scanType{
    _machineNumberView = [[UIView alloc]initWithFrame:viewFrame];
    _machineNumberView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_machineNumberView];
    
    _machineNumber = [[UILabel alloc]init];
    _machineNumber.frame = CGRectMake(50 * screenWidth, 20 * screenHeight, 400 * screenWidth, 42 * screenHeight);
    _machineNumber.text = text;
    _machineNumber.font = CFFONT16;
    _machineNumber.textAlignment = NSTextAlignmentLeft;
    //    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(putInMachineNumber)];
    _machineNumber.userInteractionEnabled = YES;
    //    [_machineNumber addGestureRecognizer:tapGesture];
    [_machineNumberView addSubview:_machineNumber];
    
    UIButton *machineNumberPlace = [UIButton buttonWithType:UIButtonTypeCustom];
    machineNumberPlace.frame = CGRectMake(self.view.frame.size.width -  280 * screenWidth, _machineNumber.frame.origin.y, 250 * screenWidth, _machineNumber.frame.size.height);
    [machineNumberPlace setTitle:place forState:UIControlStateNormal];
    machineNumberPlace.titleLabel.font = CFFONT16;
    [machineNumberPlace setTitleColor:ChangfaColor forState:UIControlStateNormal];
    //    [machineNumberPlace addTarget:self action:@selector(whereIsMachineNumber) forControlEvents:UIControlEventTouchUpInside];
    [_machineNumberView addSubview:machineNumberPlace];
    
    _lineView = [[UIView alloc]initWithFrame:CGRectMake(_machineNumber.frame.origin.x, _machineNumber.frame.size.height + _machineNumber.frame.origin.y + 30 * screenHeight, self.view.frame.size.width - _machineNumber.frame.origin.x * 2, 2 * screenHeight)];
    _lineView.backgroundColor = BackgroundColor;
    [_machineNumberView addSubview:_lineView];
    
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    scanButton.frame = scanButtonFrame;
    [scanButton setImage:[UIImage imageNamed:scanImage] forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(scanMachine) forControlEvents:UIControlEventTouchUpInside];
    [_machineNumberView addSubview:scanButton];
    
    UILabel *scanLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, scanButton.frame.size.height + scanButton.frame.origin.y + 40 * screenHeight, self.view.frame.size.width, 26 * screenHeight)];
    scanLabel.text = scanText;
    scanLabel.font = CFFONT16;
    scanLabel.textAlignment = NSTextAlignmentCenter;
    [_machineNumberView addSubview:scanLabel];
    
}
- (void)scanMachine{
    ScanViewController *scan = [[ScanViewController alloc]init];
    scan.delegate = self;
    [self presentViewController:scan animated:YES completion:^{
        
    }];
}
- (void)scanGetInformation:(MachineModel *)model{
    self.model = model;
    [self reloadMachineNumberView:model];
}
- (void)reloadMachineNumberView:(MachineModel *)model {
    
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0,_lineView.frame.size.height + _lineView.frame.origin.y, self.view.frame.size.width, _machineNumberView.frame.size.height - _lineView.frame.size.height - _lineView.frame.origin.y)];
    backView.backgroundColor = [UIColor whiteColor];
    [_machineNumberView addSubview:backView];
    UIImageView *machineImage = [[UIImageView alloc]initWithFrame:CGRectMake(30 * screenWidth, 30 * screenHeight, 190 * screenWidth, 190 * screenHeight)];
    switch ([model.carType integerValue]) {
        case 1:
            machineImage.image = [UIImage imageNamed:@"CFTuoLaJi"];
            break;
        case 2:
            machineImage.image = [UIImage imageNamed:@"CFShouGeJi"];
            break;
        case 3:
            machineImage.image = [UIImage imageNamed:@"CFChaYangji"];
            break;
        case 4:
            machineImage.image = [UIImage imageNamed:@"CFHongGanJi"];
            break;
        default:
            break;
    }
    [backView addSubview:machineImage];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(machineImage.frame.size.width + machineImage.frame.origin.x + 30 * screenWidth, machineImage.frame.origin.y, self.view.frame.size.width - 280 * screenWidth, 50 * screenHeight)];
    nameLabel.text = [@"名称：" stringByAppendingString:[NSString stringWithFormat:@"%@",model.productName]];
    nameLabel.font = CFFONT14;
    [backView addSubview:nameLabel];
    UILabel *typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.size.height + nameLabel.frame.origin.y + 20 * screenHeight, nameLabel.frame.size.width, nameLabel.frame.size.height)];
    typeLabel.text = [@"型号：" stringByAppendingString:[NSString stringWithFormat:@"%@",model.productModel]];
    typeLabel.font = CFFONT14;
    [backView addSubview:typeLabel];
    UILabel *numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.frame.origin.x, typeLabel.frame.size.height + typeLabel.frame.origin.y + 20 * screenHeight, nameLabel.frame.size.width, nameLabel.frame.size.height)];
    numberLabel.text = [@"车架号："stringByAppendingString:[NSString stringWithFormat:@"%@",model.productBarCode]];
    numberLabel.font = CFFONT14;
    numberLabel.textColor = [UIColor redColor];
    [backView addSubview:numberLabel];
//    
//    UIView *userView = [[UIView alloc]initWithFrame:CGRectMake(0, _machineNumberView.frame.size.height + _machineNumberView.frame.origin.y + screenHeight, self.view.frame.size.width, 172 * screenHeight)];
//    userView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:userView];
//    UILabel *userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(30 * screenWidth, 20 * screenHeight, self.view.frame.size.width - 60 * screenWidth, 40 * screenHeight)];
//    userNameLabel.text = [@"用户姓名：" stringByAppendingString:[NSString stringWithFormat:@"%@", model.name]];
//    userNameLabel.font = CFFONT14;
//    [userView addSubview:userNameLabel];
//    UILabel *userPhoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(userNameLabel.frame.origin.x, userNameLabel.frame.origin.y + userNameLabel.frame.size.height + 15 * screenHeight, userNameLabel.frame.size.width, userNameLabel.frame.size.height)];
//    userPhoneLabel.text = [@"用户电话：" stringByAppendingString:[NSString stringWithFormat:@"%@", model.tel]];
//    userPhoneLabel.font = CFFONT14;
//    [userView addSubview:userPhoneLabel];
//    UILabel *sellTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(userNameLabel.frame.origin.x, userPhoneLabel.frame.origin.y + userPhoneLabel.frame.size.height + 15 * screenHeight, userNameLabel.frame.size.width, 32 * screenHeight)];
//    sellTimeLabel.text = [@"售出时间：" stringByAppendingString:[NSString stringWithFormat:@"%@",[[model.saleDate substringToIndex:19] stringByReplacingOccurrencesOfString:@"T" withString:@" "]]];
//    sellTimeLabel.textColor = [UIColor grayColor];
//    sellTimeLabel.font = CFFONT13;
//    [userView addSubview:sellTimeLabel];
//    _retreatReasonView.frame = CGRectMake(0, _machineNumberView.frame.size.height + _machineNumberView.frame.origin.y + 193 * screenHeight, self.view.frame.size.width, 510 * screenHeight);
//    _reasonTextView.frame = CGRectMake(30 * screenWidth, 88 * screenHeight, self.view.frame.size.width - 60 * screenWidth, 422 * screenHeight);
}

- (void)leftButtonClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.text.length < 1) {
        self.placeHolder.hidden = NO;
    }
}
- (void)setupPlaceHolder
{
    UILabel *placeHolder = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.reasonTextView.frame.size.width, 50 * screenHeight)];
    self.placeHolder = placeHolder;
    placeHolder.text = @"原因描述：（必填，200字以内）";
    placeHolder.textColor = BackgroundColor;
    placeHolder.numberOfLines = 0;
    placeHolder.contentMode = UIViewContentModeTop;
    [_reasonTextView addSubview:placeHolder];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    self.vagueView.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.pickReaseonView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 520 * screenHeight);
    }];
}
- (void)submitRetreatRequest{
    if (_model.imei.length < 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"请获取农机信息" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:alertAction];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
        return;
    }
    NSString *returnReason = _retreatResonButton.titleLabel.text;
    if ([_retreatResonButton.titleLabel.text isEqualToString:@"选择原因"]) {
        returnReason = @"无";
    }
    NSDictionary *dict = @{
                           @"imei":_model.imei,
                           @"returnReason":returnReason,
                           @"returnNote":_reasonTextView.text,
                           @"distributorsID":[[NSUserDefaults standardUserDefaults] objectForKey:@"UserDistributorId"],
                           };
    [CFAFNetWorkingMethod requestDataWithUrl:@"machinery/applyReturnFactory" Params:dict Method:@"post" Image:nil Success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@", responseObject);
        if ([[[responseObject objectForKey:@"head"] objectForKey:@"code"] integerValue] == 200) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            CFAgencyReturnStatusViewController *retreatStatus = [[CFAgencyReturnStatusViewController alloc]initWithSubmitTime:[formatter stringFromDate:[NSDate date]]];
            //            retreatStatus.model = self.model;
            [self.navigationController pushViewController:retreatStatus animated:YES];
            
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[[responseObject objectForKey:@"head"]objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:alertAction];
            [self presentViewController:alert animated:YES completion:^{
                
            }];
        }
    } Failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //获取高亮部分内容
    //NSString * selectedtext = [textView textInRange:selectedRange];
    
    //如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedRange && pos) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        
        if (offsetRange.location < MAX_LIMIT_NUMS) {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
    
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    NSInteger caninputlen = MAX_LIMIT_NUMS - comcatstr.length;
    
    if (caninputlen >= 0)
    {
        return YES;
    }
    else
    {
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        
        if (rg.length > 0)
        {
            NSString *s = @"";
            //判断是否只普通的字符或asc码(对于中文和表情返回NO)
            BOOL asc = [text canBeConvertedToEncoding:NSASCIIStringEncoding];
            if (asc) {
                s = [text substringWithRange:rg];//因为是ascii码直接取就可以了不会错
            }
            else
            {
                __block NSInteger idx = 0;
                __block NSString  *trimString = @"";//截取出的字串
                //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                                         options:NSStringEnumerationByComposedCharacterSequences
                                      usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                                          
                                          if (idx >= rg.length) {
                                              *stop = YES; //取出所需要就break，提高效率
                                              return ;
                                          }
                                          
                                          trimString = [trimString stringByAppendingString:substring];
                                          
                                          idx++;
                                      }];
                
                s = trimString;
            }
            //rang是指从当前光标处进行替换处理(注意如果执行此句后面返回的是YES会触发didchange事件)
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
            //既然是超出部分截取了，哪一定是最大限制了。
            self.reasonTextView.textNumberLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)MAX_LIMIT_NUMS, (long)MAX_LIMIT_NUMS];
        }
        return NO;
    }
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    //    static CGFloat maxHeight = 500 * screenHeight;
    self.placeHolder.hidden = YES;
    CGFloat maxHeight = 500 * screenHeight;
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height<=maxHeight) {
        size.height=maxHeight;
    }
    //    _reasonTextView.scrollEnabled = NO;    // 不允许滚动
    _reasonTextView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
    
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    
    if (existTextNum > MAX_LIMIT_NUMS)
    {
        //截取到最大位置的字符
        NSString *s = [nsTextContent substringToIndex:MAX_LIMIT_NUMS];
        
        [textView setText:s];
    }
    
    //不让显示负数 口口日
    self.reasonTextView.textNumberLabel.text = [NSString stringWithFormat:@"%ld/%d",MAX(0, existTextNum),MAX_LIMIT_NUMS];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
