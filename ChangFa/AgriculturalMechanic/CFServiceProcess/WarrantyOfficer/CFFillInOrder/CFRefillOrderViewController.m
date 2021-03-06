//
//  CFFillInOrderViewController.m
//  ChangFa
//
//  Created by Developer on 2018/3/21.
//  Copyright © 2018年 dev. All rights reserved.
//

#import "CFRefillOrderViewController.h"
#import "CFPreviewPhotoViewController.h"
#import "CFRegisterTextFieldView.h"
#import "CFFillInOrderViewTableViewCell.h"
#import "CFFillInOrderModel.h"

#import "AFHTTPSessionManager.h"
#import <Photos/Photos.h>
#import "CTAssetsPickerController/CTAssetsPickerController.h"
#define MAX_LIMIT_NUMS 150
#define MAX_LIMIT_PHOTONUMBER 9
typedef void(^reloadCollectionItemBlock)(NSMutableArray *photoArray, NSInteger infoType);
@interface CFRefillOrderViewController ()<UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CTAssetsPickerControllerDelegate, UITextFieldDelegate>
@property (nonatomic, strong)CFFillInOrderModel *fillModel;
@property (nonatomic, strong)UIScrollView *fillScrollView;
@property (nonatomic, strong)UIView *titleView;
@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UITableView *orderTableView;
@property (nonatomic, strong)UIButton *submitButton;

@property (nonatomic, strong)NSArray *infoArray;
@property (nonatomic, assign)NSInteger selectedIndex; // 点击cell下标
@property (nonatomic, strong)NSMutableArray *signArray; // 存储cell的选定标识
@property (nonatomic, strong)NSMutableArray *editSignArray;  // 判断是否被编辑
@property (nonatomic, strong)NSArray *styleArray;

@property (nonatomic, strong)UIView *vagueView;
@property (nonatomic, strong)UIButton *firstStyleButton; //
@property (nonatomic, strong)UIButton *secondStyleButton;

@property (nonatomic, strong)NSMutableArray *reasonArray;   // 不通过时，存储reason标识
@property (nonatomic, strong)NSMutableArray *imageArray;
@property (nonatomic, strong)NSMutableArray *photoArray;
@property (nonatomic, strong)NSMutableArray *faultPhotoArray;
@property (nonatomic, strong)NSMutableArray *personPhotoArray;
@property (nonatomic, strong)NSMutableArray *faultPhotoPathArray;
@property (nonatomic, strong)NSMutableArray *personPhotoPathArray;
@property (nonatomic, copy)NSString *fileIds;
@property (nonatomic, copy)NSString *useTime;
@property (nonatomic, copy)NSString *driveDistance;
@property (nonatomic, copy)NSString *faultFileIds;
@property (nonatomic, copy)NSString *personFileIds;
@property (nonatomic, copy)NSString *machineInstruction;
@property (nonatomic, copy)NSString *faultInstruction;
@property (nonatomic, copy)NSString *customerOpinion;
@property (nonatomic, copy)NSString *handleOpinion;
@property (nonatomic, copy)NSString *remarks;

@property (nonatomic, strong)UIImagePickerController *imagePicker;
@property (nonatomic, copy)reloadCollectionItemBlock reloadCollectionItemBlock;
@end

@implementation CFRefillOrderViewController

- (NSArray *)infoArray
{
    if (_infoArray == nil) {
        _infoArray = [NSArray arrayWithObjects:@"故障照片", @"人机合影",@"农机信息", @"农机用途说明", @"农机故障说明", @"客户意见", @"处理意见", @"备注", nil];
    }
    return _infoArray;
}
- (NSMutableArray *)signArray
{
    if (_signArray == nil) {
        _signArray = [NSMutableArray arrayWithObjects:@0, @0, @0, @0, @0, @0, @0, @0, nil];
    }
    return _signArray;
}
- (NSMutableArray *)editSignArray
{
    if (_editSignArray == nil) {
        _editSignArray = [NSMutableArray arrayWithObjects:@0, @0, @0, @0, @0, @0, @0, @0, nil];
    }
    return _editSignArray;
}
- (NSArray *)styleArray
{
    if (_styleArray == nil) {
        _styleArray = [NSArray arrayWithObjects:@1, @1, @2, @2, @2, @2, @2, @2, nil];
    }
    return _styleArray;
}
- (UIView *)vagueView
{
    if (_vagueView == nil) {
        _vagueView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _vagueView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        _vagueView.hidden = YES;
        [self.view addSubview:_vagueView];
    }
    return _vagueView;
}
- (NSMutableArray *)reasonArray
{
    if (_reasonArray == nil) {
        _reasonArray = [NSMutableArray array];
    }
    return _reasonArray;
}
- (NSMutableArray *)imageArray
{
    if (_imageArray == nil) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}
- (NSMutableArray *)photoArray
{
    if (_photoArray == nil) {
        _photoArray = [NSMutableArray array];
    }
    return _photoArray;
}
- (NSMutableArray *)faultPhotoArray
{
    if (_faultPhotoArray == nil) {
        _faultPhotoArray = [NSMutableArray array];
    }
    return _faultPhotoArray;
}
- (NSMutableArray *)personPhotoArray
{
    if (_personPhotoArray == nil) {
        _personPhotoArray = [NSMutableArray array];
    }
    return _personPhotoArray;
}
- (NSMutableArray *)faultPhotoPathArray
{
    if (_faultPhotoPathArray == nil) {
        _faultPhotoPathArray = [NSMutableArray array];
    }
    return _faultPhotoPathArray;
}
- (NSMutableArray *)personPhotoPathArray
{
    if (_personPhotoPathArray == nil) {
        _personPhotoPathArray = [NSMutableArray array];
    }
    return _personPhotoPathArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BackgroundColor;
    self.navigationItem.title = @"填写维修单";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"fanhuiwhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonClick)];
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    //设置代理
    _imagePicker.delegate=self;
    //可编辑
    
    _imagePicker.allowsEditing=YES;
    [self createFillInOrderView];
    [self getFillInOrderWithReapirId:self.repairId];

    // Do any additional setup after loading the view.
}
- (void)createFillInOrderView
{
    self.selectedIndex = 0;
    [self.signArray replaceObjectAtIndex:self.selectedIndex withObject:@1];
    
    _fillScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _fillScrollView.contentSize = CGSizeMake(0, 1700 * screenHeight);
    _fillScrollView.backgroundColor = BackgroundColor;
    _fillScrollView.delegate = self;
    [self.view addSubview:_fillScrollView];
    
    _titleView = [[UIView alloc]initWithFrame:CGRectMake(0, navHeight, CF_WIDTH, 60 * screenWidth)];
    _titleView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    [self.view addSubview:_titleView];
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(30 * screenWidth, 0, CF_WIDTH - 100 * screenWidth, 60 * screenHeight)];
    _titleLabel.text = @"";
    _titleLabel.font = CFFONT11;
    [_titleView addSubview:_titleLabel];
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    titleButton.frame = CGRectMake(_titleLabel.frame.size.width + _titleLabel.frame.origin.x, 10 * screenHeight, 40 * screenWidth, 40 * screenHeight);
    [titleButton setImage:[UIImage imageNamed:@"CF_HideMessage"] forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(titleButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_titleView addSubview:titleButton];
    
    UILabel *repairStyleLabel = [[UILabel alloc]initWithFrame:CGRectMake(30 * screenWidth, 20 * screenHeight, CF_WIDTH - 60 * screenWidth, 120 * screenHeight)];
    repairStyleLabel.backgroundColor = [UIColor whiteColor];
    repairStyleLabel.layer.cornerRadius = 20 * screenWidth;
    repairStyleLabel.clipsToBounds = YES;
    repairStyleLabel.text = @"外出服务";
    repairStyleLabel.font = CFFONT14;
    repairStyleLabel.textAlignment = NSTextAlignmentCenter;
    [_fillScrollView addSubview:repairStyleLabel];
    UILabel *repairTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(70 * screenWidth, 35 * screenHeight, 250 * screenWidth, 50 * screenHeight)];
    repairTitleLabel.text = @"维修类型";
    repairTitleLabel.font = CFFONT14;
    [repairStyleLabel addSubview:repairTitleLabel];
    
    _orderTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, repairStyleLabel.frame.size.height + repairStyleLabel.frame.origin.y, CF_WIDTH, (120 +  20) * self.signArray.count * screenHeight + 292 * screenHeight)];
    _orderTableView.delegate = self;
    _orderTableView.dataSource = self;
    _orderTableView.showsVerticalScrollIndicator = NO;
    _orderTableView.scrollEnabled = NO;
    _orderTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_fillScrollView addSubview:_orderTableView];
    
    _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _submitButton.frame = CGRectMake(0, CF_HEIGHT - 100 * screenHeight, CF_WIDTH, 100 * screenHeight);
    //    _submitButton.layer.cornerRadius = 20 * Width;
    [_submitButton setTitle:@"提交" forState:UIControlStateNormal];
    [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submitButton setBackgroundColor:ChangfaColor];
    [_submitButton addTarget:self action:@selector(submitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_submitButton];
    
    self.vagueView.hidden = YES;
    self.firstStyleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.firstStyleButton.frame = CGRectMake(0, CF_HEIGHT - 312 * screenHeight, CF_WIDTH, 100 * screenHeight);
    self.firstStyleButton.backgroundColor = [UIColor whiteColor];
    self.firstStyleButton.titleLabel.font = CFFONT15;
    [self.firstStyleButton addTarget:self action:@selector(firstStyleButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.vagueView addSubview:self.firstStyleButton];
    self.secondStyleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.secondStyleButton.frame = CGRectMake(0, self.firstStyleButton.frame.size.height + self.firstStyleButton.frame.origin.y + 2 * screenHeight, CF_WIDTH, self.firstStyleButton.frame.size.height);
    self.secondStyleButton.backgroundColor = [UIColor whiteColor];
    self.secondStyleButton.titleLabel.font = CFFONT15;
    [self.secondStyleButton addTarget:self action:@selector(secondStyleButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.vagueView addSubview:self.secondStyleButton];
    UIButton *cancelStyleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelStyleButton.frame = CGRectMake(0, self.secondStyleButton.frame.size.height + self.secondStyleButton.frame.origin.y + 10 * screenHeight, CF_WIDTH, self.secondStyleButton.frame.size.height);
    cancelStyleButton.backgroundColor = [UIColor whiteColor];
    [cancelStyleButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelStyleButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [cancelStyleButton addTarget:self action:@selector(cancelStyleButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.vagueView addSubview:cancelStyleButton];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.infoArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    CFFillInOrderViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[CFFillInOrderViewTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    cell.statusLabel.hidden = YES;
    if ([self.signArray[indexPath.section] integerValue] == 1) {
        cell.selected = YES;
        if (indexPath.section > 1) {
            cell.cellIndex = indexPath.section;
            if (indexPath.section == 2) {
                cell.styleStatus = 3;
            } else {
                cell.styleStatus = 2;
                cell.reasonPlaceholder = @"点击填写内容";
            }
            cell.textInfoBlock = ^(NSString *textInfo, NSInteger index) {
                [self getTextInfoWithText:textInfo CellIndex:index];
            };
            cell.textEditBlock = ^(NSInteger status){
                [self changeScrollViewOriginYWithStatus:status];
            };
        } else {
            cell.styleStatus = 1;
            cell.itemBlock = ^{
                [self selectedToUploadImage];
            };
            cell.deleteImageBlock = ^(NSInteger sender) {
                [self deleteImage:sender];
            };
            self.reloadCollectionItemBlock = ^(NSMutableArray *photoArray, NSInteger infoType) {
                cell.infoType = infoType;
                cell.reloadPhotoArray = photoArray;
            };
            cell.clickImageBlock = ^(NSInteger sender) {
                CFPreviewPhotoViewController *preview = [[CFPreviewPhotoViewController alloc]init];
                if (_selectedIndex == 0) {
                    preview.photoArray = self.faultPhotoArray;
                } else {
                    preview.photoArray = self.personPhotoArray;
                }
                preview.selectedIndex = sender;
                preview.headerHeight = navHeight;
                [self presentViewController:preview animated:YES completion:^{
                    
                }];
            };
        }
    } else {
        cell.styleStatus = 0;
    }
    cell.nameLabel.text = _infoArray[indexPath.section];
    switch (indexPath.section) {
        case 0:
            if (self.fillModel.faultFileInfo.count > 0 || self.faultFileIds.length > 0) {
                cell.photoArray = self.faultPhotoArray;
                cell.statusLabel.hidden = NO;
                if (self.faultPhotoArray.count >= MAX_LIMIT_PHOTONUMBER) {
                    cell.cellType = 2;
                } else {
                    cell.cellType = 1;
                }
            }
            break;
        case 1:
            if (self.fillModel.personFileInfo.count > 0 || self.personFileIds.length > 0) {
                cell.photoArray = self.personPhotoArray;
                cell.statusLabel.hidden = NO;
                if (self.personPhotoArray.count >= MAX_LIMIT_PHOTONUMBER) {
                    cell.cellType = 2;
                } else {
                    cell.cellType = 1;
                }
            }
            break;
        case 2:
            if (self.useTime.length > 0) {
                cell.hourTextField.textField.text = self.useTime;
                cell.hourTextField.textField.placeholder = @"";
                cell.statusLabel.hidden = NO;
            }
            if (self.driveDistance.length > 0) {
                cell.mileageTextField.textField.text = self.driveDistance;
                cell.mileageTextField.textField.placeholder = @"";
                cell.statusLabel.hidden = NO;
            }
            break;
        case 3:
//            if (self.fillModel.machineInstruction.length > 0) {
//                cell.reasonView.text = self.fillModel.machineInstruction;
//                cell.reasonView.placeholder = @"";
//                cell.statusLabel.hidden = NO;
//            }
//            if (self.machineInstruction.length > 0) {
                cell.reasonView.text = self.machineInstruction;
                cell.reasonView.placeholder = @"";
                cell.statusLabel.hidden = NO;
                cell.reasonView.text = self.machineInstruction;
                cell.textNumberLabel.text = [NSString stringWithFormat:@"%ld/%d", self.machineInstruction.length, MAX_LIMIT_NUMS];
//            }
            break;
        case 4:
//            if (self.fillModel.faultInstruction.length > 0) {
//                cell.reasonView.text = self.fillModel.faultInstruction;
//                cell.reasonView.placeholder = @"";
//                cell.statusLabel.hidden = NO;
//            }
//            if (self.faultInstruction.length > 0) {
                cell.reasonView.text = self.faultInstruction;
                cell.reasonView.placeholder = @"";
                cell.statusLabel.hidden = NO;
                cell.reasonView.text = self.faultInstruction;
                cell.textNumberLabel.text = [NSString stringWithFormat:@"%ld/%d", self.faultInstruction.length, MAX_LIMIT_NUMS];
//            }
            break;
        case 5:
//            if (self.fillModel.customerOpinion.length > 0) {
//                cell.reasonView.text = self.fillModel.customerOpinion;
//                cell.reasonView.placeholder = @"";
//                cell.statusLabel.hidden = NO;
//            }
//            if (self.customerOpinion.length > 0) {
                cell.reasonView.text = self.customerOpinion;
                cell.reasonView.placeholder = @"";
                cell.statusLabel.hidden = NO;
                cell.reasonView.text = self.customerOpinion;
                cell.textNumberLabel.text = [NSString stringWithFormat:@"%ld/%d", self.customerOpinion.length, MAX_LIMIT_NUMS];
//            }
            break;
        case 6:
//            if (self.fillModel.handleOpinion.length > 0) {
//                cell.reasonView.text = self.fillModel.handleOpinion;
//                cell.reasonView.placeholder = @"";
//                cell.statusLabel.hidden = NO;
//            }
//            if (self.handleOpinion.length > 0) {
                cell.reasonView.text = self.handleOpinion;
                cell.reasonView.placeholder = @"";
                cell.statusLabel.hidden = NO;
                cell.reasonView.text = self.handleOpinion;
                cell.textNumberLabel.text = [NSString stringWithFormat:@"%ld/%d", self.handleOpinion.length, MAX_LIMIT_NUMS];
//            }
            break;
        case 7:
//            if (self.fillModel.remarks.length > 0) {
//                cell.reasonView.text = self.fillModel.remarks;
//                cell.reasonView.placeholder = @"";
//                cell.statusLabel.hidden = NO;
//            }
//            if (self.remarks.length > 0) {
//                cell.reasonView.text = self.remarks;
                cell.reasonView.placeholder = @"";
                cell.statusLabel.hidden = NO;
//            }
            cell.reasonView.text = self.remarks;
            cell.textNumberLabel.text = [NSString stringWithFormat:@"%ld/%d", self.remarks.length, MAX_LIMIT_NUMS];
            cell.starImage.hidden = YES;
            break;
        default:
            break;
    }
    cell.cellType = 0;
    if (indexPath.section >1) {
        cell.reasonView.editable = NO;
    }
    if (indexPath.section == 2) {
        cell.hourTextField.textField.userInteractionEnabled = NO;
        cell.mileageTextField.textField.userInteractionEnabled = NO;
    }
    for (NSString *str in self.reasonArray) {
        if (([str integerValue] - 17) < 2 && indexPath.section == ([str integerValue] - 17)) {
            if ([self.editSignArray[indexPath.section] integerValue] == 1) {
                cell.nameLabel.textColor = ChangfaColor;
            } else {
                cell.nameLabel.textColor = [UIColor redColor];
                cell.statusLabel.text = @"审核不通过，请重新填写";
            }
            cell.statusLabel.hidden = NO;
            cell.statusLabel.font = CFFONT13;
            cell.cellType = 1;
        } else if (([str integerValue] - 17) > 1 && indexPath.section == ([str integerValue] - 16)) {
            if ([self.editSignArray[indexPath.section] integerValue] == 1) {
                cell.nameLabel.textColor = ChangfaColor;
            } else {
                cell.nameLabel.textColor = [UIColor redColor];
                cell.statusLabel.text = @"审核不通过，请重新填写";
            }
            cell.statusLabel.hidden = NO;
            cell.statusLabel.font = CFFONT13;
            cell.reasonView.editable = YES;
        }
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20 * screenHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.signArray[indexPath.section] integerValue] == 1) {
        if (indexPath.section == 2) {
            return (120 + 196) * screenHeight;
        }
        return (120 + 292) * screenHeight;
    }
    return 120 * screenHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _orderTableView.frame.size.width, 20 * screenHeight)];
    headView.backgroundColor = BackgroundColor;
    return headView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (int i = 0; i < self.signArray.count; i++) {
        [self.signArray replaceObjectAtIndex:i withObject:@0];
    }
    [self.signArray replaceObjectAtIndex:indexPath.section withObject:@1];
    CGRect viewFrame = _orderTableView.frame;
    if (self.selectedIndex == indexPath.section) {// 点击同一个收回
        [self.signArray replaceObjectAtIndex:indexPath.section withObject:@0];
        self.selectedIndex = 1000;
        _orderTableView.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y, viewFrame.size.width, (120 +  20) * self.infoArray.count * screenHeight);
        [self.orderTableView reloadData];
        return;
    }
    if (indexPath.section == 2) {
        _orderTableView.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y, viewFrame.size.width, (120 +  20) * self.infoArray.count * screenHeight + 196 * screenHeight);
    } else {
        _orderTableView.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y, viewFrame.size.width, (120 +  20) * self.infoArray.count * screenHeight + 292 * screenHeight);
    }
    [_orderTableView reloadData];
    self.selectedIndex = indexPath.section;
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    CFFillInOrderViewTableViewCell *orderInfoCell = [tableView cellForRowAtIndexPath:indexPath];
    orderInfoCell.selected = NO;
    orderInfoCell.styleStatus = 0;
    [self.orderTableView reloadData];
}
// 删除图片
- (void)deleteImage:(NSInteger)sender
{
    if (self.selectedIndex == 0) {
        [self.faultPhotoArray removeObjectAtIndex:sender];
        NSMutableArray *fileIdsArray = [NSMutableArray arrayWithArray:[self.faultFileIds componentsSeparatedByString:@","]];
        [fileIdsArray removeObjectAtIndex:sender];
        self.faultFileIds = @"";
        for (NSString *str in fileIdsArray) {
            if (self.faultFileIds.length < 1) {
                self.faultFileIds = str;
            } else {
                self.faultFileIds = [[self.faultFileIds stringByAppendingString:@","] stringByAppendingString:str];
            }
        }
        self.photoArray = self.faultPhotoArray;
    } else {
        [self.personPhotoArray removeObjectAtIndex:sender];
        NSMutableArray *fileIdsArray = [NSMutableArray arrayWithArray:[self.personFileIds componentsSeparatedByString:@","]];
        [fileIdsArray removeObjectAtIndex:sender];
        self.personFileIds = @"";
        for (NSString *str in fileIdsArray) {
            if (self.personFileIds.length < 1) {
                self.personFileIds = str;
            } else {
                self.personFileIds = [[self.personFileIds stringByAppendingString:@","] stringByAppendingString:str];
            }
        }
        self.photoArray = self.personPhotoArray;
    }
    [self submitOrderInfoWithPhoto:YES];
}
- (void)firstStyleButtonClick
{
        if (self.photoArray.count == 9) {
            [MBManager showBriefAlert:@"最多上传9张图片" time:1.5];
            return;
        }
        _imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:_imagePicker animated:YES completion:nil];
}
- (void)secondStyleButtonClick
{
    if (self.photoArray.count == 9) {
        [MBManager showBriefAlert:@"最多上传9张图片" time:1.5];
        return;
    }
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        if (status != PHAuthorizationStatusAuthorized) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            picker.delegate = self;
            // 显示选择的索引
            picker.showsSelectionIndex = YES;
            // 设置相册的类型：相机胶卷 + 自定义相册
            picker.assetCollectionSubtypes = @[
                                                @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                                                @(PHAssetCollectionSubtypeAlbumRegular)];
            // 不需要显示空的相册
            picker.showsEmptyAlbums = NO;
            [self presentViewController:picker animated:YES completion:nil];
        });
    }];
}
- (void)cancelStyleButtonClick
{
    self.vagueView.hidden = YES;
}

- (void)submitButtonClick
{
    [self submitOrderInfoWithPhoto:NO];
}
- (void)leftButtonClick
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定退出编辑吗" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [sureAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [alert addAction:cancelAction];
    [alert addAction:sureAction];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    if (self.selectedIndex == 0) {
        [self.faultPhotoArray addObject:image];
        self.reloadCollectionItemBlock(self.faultPhotoArray, 1);
    } else {
        [self.personPhotoArray addObject:image];
        self.reloadCollectionItemBlock(self.personPhotoArray, 1);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self uploadImagesArray];
}
- (void)getTextInfoWithText:(NSString *)textInfo
                  CellIndex:(NSInteger)cellIndex
{
    switch (cellIndex) {
        case 3:
            self.machineInstruction = textInfo;
            [self.editSignArray replaceObjectAtIndex:3 withObject:@1];
            break;
        case 4:
            self.faultInstruction = textInfo;
            [self.editSignArray replaceObjectAtIndex:4 withObject:@1];
            break;
        case 5:
            self.customerOpinion = textInfo;
            [self.editSignArray replaceObjectAtIndex:5 withObject:@1];
            break;
        case 6:
            self.handleOpinion = textInfo;
            [self.editSignArray replaceObjectAtIndex:6 withObject:@1];
            break;
        case 7:
            self.remarks = textInfo;
            [self.editSignArray replaceObjectAtIndex:7 withObject:@1];
            break;
        case 1001:
            self.useTime = textInfo;
            break;
        case 1002:
            self.driveDistance = textInfo;
        default:
            break;
    }
}
- (void)changeScrollViewOriginYWithStatus:(NSInteger)status
{
    if (status == 0) {
        [UIView animateWithDuration:0.5 animations:^{
            _fillScrollView.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            _fillScrollView.frame =CGRectMake(0, -300 * screenHeight, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
}
#pragma mark - <CTAssetsPickerControllerDelegate>
-(BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset
{
    NSInteger max = 9;
    if (picker.selectedAssets.count + self.photoArray.count >= max) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"最多选择%zd张图片", picker.selectedAssets.count] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
        [picker presentViewController:alert animated:YES completion:nil];
        // 这里不能使用self来modal别的控制器，因为此时self.view不在window上
        return NO;
    }
    return YES;
}
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    // 关闭图片选择界面
    [picker dismissViewControllerAnimated:YES completion:nil];
    // 基本配置
    CGFloat scale = [UIScreen mainScreen].scale;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode   = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = YES;
    options.networkAccessAllowed = YES;
    // 遍历选择的所有图片
    for (NSInteger i = 0; i < assets.count; i++) {
        PHAsset *asset = assets[i];
        CGSize size = CGSizeMake(asset.pixelWidth / scale, asset.pixelHeight / scale);
        // 获取图片
        //        [self.photoArray removeAllObjects];
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            //            [self.photoArray addObject:result];
            if (self.selectedIndex == 0) {
                [self.faultPhotoArray addObject:result];
            } else {
                [self.personPhotoArray addObject:result];
            }
        }];
    }
    if (self.selectedIndex == 0) {
        self.reloadCollectionItemBlock(self.faultPhotoArray, 1);
    } else {
        self.reloadCollectionItemBlock(self.personPhotoArray, 1);
    }
    
    [self uploadImagesArray];
}
#pragma mark-多图片上传
- (NSURLSessionUploadTask*)uploadTaskWithImage:(UIImage*)image completion:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionBlock
{
    // 构造 NSURLRequest
    NSError* error = NULL;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *params = @{@"file":@"",
                             @"userId":[userDefaults objectForKey:@"UserUid"],
                             @"dispatchId":self.dispatchId,
                             @"token":[userDefaults objectForKey:@"UserToken"],
                             @"type":[NSString stringWithFormat:@"%lu", (_selectedIndex + 1)],
                             };
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://192.168.31.68:8080/changfa_system/file/manyFileUpload.do?" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData* imageData = UIImageJPEGRepresentation(image, 1.0);
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"avatar.png" mimeType:@"multipart/form-data"];
    } error:&error];
    
    // 可在此处配置验证信息
    
    // 将 NSURLRequest 与 completionBlock 包装为 NSURLSessionUploadTask
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
    } completionHandler:completionBlock];
    return uploadTask;
}
- (void)uploadImagesArray
{
    if (_selectedIndex == 0) {
        self.photoArray = self.faultPhotoArray;
    } else if (_selectedIndex == 1) {
        self.photoArray = self.personPhotoArray;
    }
    self.vagueView.hidden = YES;
    [MBManager showWaitingWithTitle:@"上传图片中"];
    // 准备保存结果的数组，元素个数与上传的图片个数相同，先用 NSNull 占位
    NSMutableArray* result = [NSMutableArray array];
    for (UIImage* image in self.photoArray) {
        [result addObject:[NSNull null]];
    }
    
    
    dispatch_group_t group = dispatch_group_create();
    
    for (NSInteger i = 0; i < self.photoArray.count; i++) {
        
        dispatch_group_enter(group);
        
        NSURLSessionUploadTask* uploadTask = [self uploadTaskWithImage:self.photoArray[i] completion:^(NSURLResponse *response, NSDictionary* responseObject, NSError *error) {
            if (error) {
                NSLog(@"第 %d 张图片上传失败: %@", (int)i + 1, error);
                dispatch_group_leave(group);
            } else {
                NSLog(@"uploadimages%@", response);
                NSLog(@"第 %d 张图片上传成功: %@", (int)i + 1, responseObject);
                @synchronized (result) { // NSMutableArray 是线程不安全的，所以加个同步锁
                    result[i] = responseObject;
                }
                dispatch_group_leave(group);
            }
        }];
        [uploadTask resume];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        NSLog(@"上传完成!");
        self.fileIds = @"";
        NSInteger ids = 0;
        for (id response in result) {
            NSLog(@"tupian%@", response);
            if (ids == 0) {
                self.fileIds = [[[response objectForKey:@"body"] objectForKey:@"result"] objectForKey:@"fileIds"];
            } else {
                self.fileIds = [[self.fileIds stringByAppendingString:@","] stringByAppendingString:[[[response objectForKey:@"body"] objectForKey:@"result"] objectForKey:@"fileIds"]];
            }
            ids++;
        }
        switch (self.selectedIndex) {
            case 0:
                self.faultFileIds = self.fileIds;
                [self.editSignArray replaceObjectAtIndex:0 withObject:@1];
                break;
            case 1:
                self.personFileIds = self.fileIds;
                [self.editSignArray replaceObjectAtIndex:1 withObject:@1];
                break;
            default:
                break;
        }
        NSLog(@"%@", self.fileIds);
        [self submitOrderInfoWithPhoto:YES];
    });
}
#pragma mark - 获取已填写维修单信息
- (void)getFillInOrderWithReapirId:(NSString *)repairId
{
    [MBManager showWaitingWithTitle:@"加载中"];
    NSDictionary *param = @{
                            @"repairId":repairId,
                            };
    [CFAFNetWorkingMethod requestDataWithJavaUrl:@"repair/getRepairInfo" Loading:0 Params:param Method:@"get" Image:nil Success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"dispatch%@", responseObject);
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[responseObject objectForKey:@"head"]];
        if ([[dict objectForKey:@"code"] integerValue] == 200) {
            [MBManager hideAlert];
            self.fillModel = [CFFillInOrderModel fillInOrderModelWithDictionary:[[responseObject objectForKey:@"body"] objectForKey:@"result"]];
            [self fillInOrderInfo];
        } else {
            [MBManager hideAlert];
            //            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[dict objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            //            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //
            //            }];
            //            [alert addAction:alertAction];
            //            [self presentViewController:alert animated:YES completion:^{
            //
            //            }];
        }
    } Failure:^(NSURLSessionDataTask *task, NSError *error) {
        [MBManager showBriefAlert:@"加载失败" time:1.0];
    }];
}
#pragma mark - 提交维修单信息
//派工单id String disId
//派工单编号 String disNum
//派工类型 String repairType
//故障图片id String faultFileIds
//人机合影图片id String personFileIds
//用户登录token String token
//使用时长 String useTime
//行驶里程 String driveDistance
//农机用途说明 String machineInstruction
//故障描述 String faultInstruction
//客户意见 String customerOpinion
//处理意见 String handleOpinion
- (void)submitOrderInfoWithPhoto:(BOOL)sender
{
    if (self.faultFileIds.length < 1) {
        self.faultFileIds = @"";
    }
    if (self.personFileIds.length < 1) {
        self.personFileIds = @"";
    }
    if (self.machineInstruction.length < 1) {
        self.machineInstruction = @"";
    }
    if (self.faultInstruction.length < 1) {
        self.faultInstruction = @"";
    }
    if (self.customerOpinion.length < 1) {
        self.customerOpinion = @"";
    }
    if (self.handleOpinion.length < 1) {
        self.handleOpinion = @"";
    }
    if (self.remarks.length < 1) {
        self.remarks = @"";
    }
    NSString *disIdStr = [NSString stringWithFormat:@"%d", [self.disId intValue]];
    NSDictionary *param = @{
                            @"disId":disIdStr,
                            @"disNum":self.disNum,
                            @"faultFileIds":self.faultFileIds,
                            @"personFileIds":self.personFileIds,
                            @"token":[[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"],
                            @"useTime":self.useTime,
                            @"driveDistance":self.driveDistance,
                            @"machineInstruction":self.machineInstruction,
                            @"faultInstruction":self.faultInstruction,
                            @"customerOpinion":self.customerOpinion,
                            @"handleOpinion":self.handleOpinion,
                            @"remarks":self.remarks,
                            };
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:param];
    if ([self.editSignArray[0] integerValue] == 0) {
        [dict removeObjectForKey:@"faultFileIds"];
    }
    if ([self.editSignArray[1] integerValue] == 0) {
        [dict removeObjectForKey:@"personFileIds"];
    }
    if ([self.editSignArray[3] integerValue] == 0) {
        [dict removeObjectForKey:@"machineInstruction"];
    }
    if ([self.editSignArray[4] integerValue] == 0) {
        [dict removeObjectForKey:@"faultInstruction"];
    }
    if ([self.editSignArray[5] integerValue] == 0) {
        [dict removeObjectForKey:@"customerOpinion"];
    }
    if ([self.editSignArray[6] integerValue] == 0) {
        [dict removeObjectForKey:@"handleOpinion"];
    }
    if ([self.editSignArray[7] integerValue] == 0) {
        [dict removeObjectForKey:@"remarks"];
    }
    [CFAFNetWorkingMethod requestDataWithJavaUrl:@"repair/createRepair" Loading:1 Params:dict Method:@"post" Image:nil Success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@", responseObject);
        [MBManager hideAlert];
        if ([[[responseObject objectForKey:@"head"] objectForKey:@"code"] integerValue] == 200) {
            if (!sender) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"提交成功" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                [alert addAction:alertAction];
                [self presentViewController:alert animated:YES completion:^{
                    
                }];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"上传成功" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [alert addAction:alertAction];
                [self presentViewController:alert animated:YES completion:^{
                    
                }];
            }
            
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
- (void)fillInOrderInfo
{
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSDictionary *dic in self.fillModel.faultFileInfo) {
        if (self.faultFileIds.length == 0) {
            self.faultFileIds = [dic objectForKey:@"fileId"];
        } else {
            self.faultFileIds = [[self.faultFileIds stringByAppendingString:@","] stringByAppendingString:[dic objectForKey:@"fileId"]];
        }
        [self.faultPhotoArray addObject:[dic objectForKey:@"filePath"]];
    }
    for (NSString *str in self.faultPhotoArray) {
        UIImage *image = [self getImageFromURL:str];
        if (image == nil) {
            image = [UIImage imageNamed:@"CF_RepairImage"];
        }
        [tempArray addObject:image];
    }
    self.faultPhotoArray = [NSMutableArray arrayWithArray:tempArray];
    [tempArray removeAllObjects];
    for (NSDictionary *dic in self.fillModel.personFileInfo) {
        if (self.personFileIds.length == 0) {
            self.personFileIds = [dic objectForKey:@"fileId"];
        } else {
            self.personFileIds = [[self.personFileIds stringByAppendingString:@","] stringByAppendingString:[dic objectForKey:@"fileId"]];
        }
        [self.personPhotoArray addObject:[dic objectForKey:@"filePath"]];
    }
    for (NSString *str in self.personPhotoArray) {
        UIImage *image = [self getImageFromURL:str];
        if (image == nil) {
            image = [UIImage imageNamed:@"CF_RepairImage"];
        }
        [tempArray addObject:image];
    }
    self.personPhotoArray = [NSMutableArray arrayWithArray:tempArray];
    if ([_fillModel.useTime integerValue] > 0) {
        self.useTime = [NSString stringWithFormat:@"%@", _fillModel.useTime];
    }
    if ([_fillModel.driveDistance integerValue] > 0) {
        self.driveDistance = [NSString stringWithFormat:@"%@", _fillModel.driveDistance];
    }
    self.faultInstruction = self.fillModel.faultInstruction;
    self.machineInstruction = self.fillModel.machineInstruction;
    self.customerOpinion = self.fillModel.customerOpinion;
    self.handleOpinion = self.fillModel.handleOpinion;
    self.remarks = self.fillModel.remarks;
    self.reasonArray = [NSMutableArray arrayWithArray:[self.fillModel.reason componentsSeparatedByString:@","]];
    switch ([self.reasonArray[0] integerValue]) {
        case 17:
            _titleLabel.text = @"故障图片与实际情况不符，请重新上传真实故障图片。";
            break;
        case 18:
            _titleLabel.text = @"人机合影图片与实际情况不符，请重新上传真实人机合影图片。";
            break;
        case 19:
            _titleLabel.text = @"车辆用途说明不准确，请重新上传准确车辆用途说明。";
            break;
        case 20:
            _titleLabel.text = @"车辆故障说明不准确，请重新上传准确车辆故障说明。";
            break;
        case 21:
            _titleLabel.text = @"客户意见不符合实际情况，请重新上传客户意见。";
            break;
        case 22:
            _titleLabel.text = @"处理意见不符合实际情况，请重新上传处理意见。";
            break;
        default:
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.orderTableView reloadData];
    });
}
- (void)selectedToUploadImage
{
    self.vagueView.hidden = NO;
    [_firstStyleButton setTitle:@"拍照" forState:UIControlStateNormal];
    [_secondStyleButton setTitle:@"从手机相册中选择" forState:UIControlStateNormal];
    [_firstStyleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_secondStyleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    self.vagueView.hidden = YES;
}
- (void)titleButtonClick
{
    self.titleView.hidden = YES;
}
/**通过URL地址从网上获取图片*/
- (UIImage*)getImageFromURL:(NSString*)fileURL
{
    UIImage *image;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", fileURL]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    image = [UIImage imageWithData:data];
    return image;
    
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

