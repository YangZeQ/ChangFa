//
//  CFRepairOrderView.h
//  ChangFa
//
//  Created by yang on 2018/6/6.
//  Copyright © 2018年 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CFReasonTextView.h"
#import "CFRegisterTextFieldView.h"
typedef enum : NSUInteger {
    FillViewStylePhoto,// 合影
    FillViewStyleInfo,// 农机信息
    FillViewStyleReason,//说明
    FillViewStyleParts,//零件
} FillViewStyle;
typedef enum : NSUInteger {
    FaultTypePart,// 零件
    FaultTypeCommon,// 普通
} FaultType;
typedef void(^chooseTypeBlock)(void);
typedef void(^addImageBlock)(void);
typedef void(^reloadCollectionViewBlock)(void);
typedef void(^deleteImageBlock)(NSInteger index);
typedef void(^scanBlock)(void);
typedef void(^getScanInfoBlock)(NSString *str);
typedef void(^isCompleteBlock)(BOOL isComplete);

@interface CFRepairOrderView : UIView
@property (nonatomic, assign)BOOL isSelected;
@property (nonatomic, assign)BOOL isRefill;
@property (nonatomic, assign)BOOL isCheck;
@property (nonatomic, assign)BOOL isComplete;
@property (nonatomic, strong)NSMutableArray *partInfoArray;
@property (nonatomic, strong)NSMutableArray *photoArray;

@property (nonatomic, strong)UIImageView *signImage;
@property (nonatomic, strong)UIImageView *starImage;
@property (nonatomic, strong)UIImageView *statusImage;
@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UILabel *statuslabel;
@property (nonatomic, strong)UIButton *selectedButton;
@property (nonatomic, strong)UIView *partTypeView;
@property (nonatomic, strong)CFReasonTextView *reasonView;
@property (nonatomic, strong)UILabel *textNumberLabel;
@property (nonatomic, strong)UIView *bodyView;
@property (nonatomic, strong)CFRegisterTextFieldView *hourTextField;
@property (nonatomic, strong)CFRegisterTextFieldView *mileageTextField;
@property (nonatomic, strong)UICollectionView *photoCollectionView;

//@property (nonatomic, copy)chooseTypeBlock chooseTypeBlock;
@property (nonatomic, copy)addImageBlock addImageBlock;
@property (nonatomic, copy)reloadCollectionViewBlock reloadCollectionViewBlock;
@property (nonatomic, copy)deleteImageBlock deleteImageBlock;
@property (nonatomic, copy)scanBlock scanBlock;
@property (nonatomic, copy)getScanInfoBlock getScanInfoBlock;
@property (nonatomic, copy)isCompleteBlock isCompleteBlock;

- (instancetype)initWithViewStyle:(FillViewStyle)viewStyle
                          IsCheck:(BOOL)isCheck;
- (void)addMachineFaultViewWithType:(FaultType)type
                     infoDictionary:(NSDictionary *)dcit;
@end

