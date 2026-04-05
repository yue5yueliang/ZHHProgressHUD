//
//  ExampleOCAnimationPreviewViewController.h
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ExampleOCAnimationKind) {
    ExampleOCAnimationKindSystem = 0,
    ExampleOCAnimationKindCircle,
    ExampleOCAnimationKindImperfect,
    ExampleOCAnimationKindHalf,
    ExampleOCAnimationKindGradient,
    ExampleOCAnimationKindPulse,
    ExampleOCAnimationKindAsymmetric,
};

FOUNDATION_EXPORT NSString *ExampleOCAnimationKindTitle(ExampleOCAnimationKind kind);

@interface ExampleOCAnimationPreviewViewController : UIViewController

- (instancetype)initWithKind:(ExampleOCAnimationKind)kind NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
