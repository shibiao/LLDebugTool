//
//  LLHierarchyInfoWindow.m
//
//  Copyright (c) 2018 LLDebugTool Software Foundation (https://github.com/HDB-Li/LLDebugTool)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "LLHierarchyInfoWindow.h"
#import "LLWindowManager.h"
#import "LLFactory.h"
#import "UIView+LL_Utils.h"
#import "LLConfig.h"
#import "LLTool.h"
#import "LLMacros.h"
#import "UIColor+LL_Utils.h"

@interface LLHierarchyInfoWindow ()

@property (nonatomic, weak) UIView *selectedView;

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIButton *moreButton;

@end

@implementation LLHierarchyInfoWindow

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initial];
    }
    return self;
}

- (void)updateView:(UIView *)view {
    
    if (self.selectedView == view) {
        return;
    }
    
    self.selectedView = view;

    NSDictionary *boldAttri = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17]};
    NSDictionary *attri = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] init];
    
    NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:@"Name: " attributes:boldAttri];
    [name appendAttributedString:[[NSAttributedString alloc] initWithString:NSStringFromClass(view.class) attributes:attri]];
    
    [attribute appendAttributedString:name];
    
    NSMutableAttributedString *frame = [[NSMutableAttributedString alloc] initWithString:@"\nFrame: " attributes:boldAttri];
    [frame appendAttributedString:[[NSAttributedString alloc] initWithString:[LLTool stringFromFrame:view.frame] attributes:attri]];
    [attribute appendAttributedString:frame];
    
    if (view.backgroundColor) {
        NSMutableAttributedString *color = [[NSMutableAttributedString alloc] initWithString:@"\nBackground: " attributes:boldAttri];
        [color appendAttributedString:[[NSAttributedString alloc] initWithString:[view.backgroundColor LL_description] attributes:attri]];
        [attribute appendAttributedString:color];
    }
    
    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        NSMutableAttributedString *font = [[NSMutableAttributedString alloc] initWithString:@"\nText Color: " attributes:boldAttri];
        [font appendAttributedString:[[NSAttributedString alloc] initWithString:[label.textColor LL_description] attributes:attri]];
        [font appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nFont: " attributes:boldAttri]];
        [font appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%0.2f", label.font.pointSize] attributes:attri]];
        [attribute appendAttributedString:font];
    }
    
    if (view.tag != 0) {
        NSMutableAttributedString *tag = [[NSMutableAttributedString alloc] initWithString:@"\nTag: " attributes:boldAttri];
        [tag appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld",(long)view.tag] attributes:attri]];
        [attribute appendAttributedString:tag];
    }
    
    self.contentLabel.attributedText = attribute;

    [self.contentLabel sizeToFit];
    
    CGFloat height = self.contentLabel.LL_height + 10 * 3 + 35;
    if (height != self.LL_height) {
        self.LL_height = height;
        if (!self.isMoved) {
            if (self.LL_bottom != LL_SCREEN_HEIGHT - 10 * 2) {
                self.LL_bottom = LL_SCREEN_HEIGHT - 10 * 2;
            }
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat gap = 10;
    CGFloat moreHeight = 35;
    CGRect moreRect = CGRectMake(gap, self.LL_height - moreHeight - gap, self.LL_width - gap - gap, moreHeight);
    if (!CGRectEqualToRect(self.moreButton.frame, moreRect)) {
        self.moreButton.frame = moreRect;
    }
    
    CGRect contentRect = CGRectMake(gap, gap, self.closeButton.LL_x - gap - gap, self.moreButton.LL_y - gap - gap);
    if (!CGRectEqualToRect(self.contentLabel.frame, contentRect)) {
        self.contentLabel.frame = contentRect;
    }
}

- (void)componentDidFinish {
    [[LLWindowManager shared] hideWindow:self animated:YES];
    [[LLWindowManager shared] hideWindow:[LLWindowManager shared].hierarchyPickerWindow animated:YES];
    [[LLWindowManager shared] showWindow:[LLWindowManager shared].suspensionWindow animated:YES];
    [[LLWindowManager shared] reloadHierarchyPickerWindow];
    [[LLWindowManager shared] reloadHierarchyInfoWindow];
}

#pragma mark - Primary
- (void)initial {
    self.contentLabel = [LLFactory getLabel:self frame:CGRectZero text:nil font:14 textColor:[LLConfig sharedConfig].textColor];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    self.moreButton = [LLFactory getButton:self frame:CGRectZero target:self action:@selector(moreButtonClicked:)];
    [self.moreButton setTitle:@"More Info" forState:UIControlStateNormal];
    [self.moreButton setTitleColor:LLCONFIG_TEXT_COLOR forState:UIControlStateNormal];
    self.moreButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.moreButton.backgroundColor = LLCONFIG_BACKGROUND_COLOR;
    self.moreButton.layer.borderColor = LLCONFIG_TEXT_COLOR.CGColor;
    self.moreButton.layer.borderWidth = 1;
    self.moreButton.layer.cornerRadius = 5;
    self.moreButton.layer.masksToBounds = YES;
}

- (void)moreButtonClicked:(UIButton *)sender {
    if (!self.selectedView) {
        return;
    }
    [[LLWindowManager shared] presentWindow:[LLWindowManager shared].hierarchyDetailWindow animated:YES];
}

@end
