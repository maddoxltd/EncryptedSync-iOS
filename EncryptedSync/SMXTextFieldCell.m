//
//  SMXTextFieldCell.m
//  QuickExpenses
//
//  Created by Simon Maddox on 14/09/2013.
//  Copyright (c) 2013 Simon Maddox. All rights reserved.
//

#import "SMXTextFieldCell.h"

// Adapted from https://github.com/breeno/EditingUITableView/blob/master/UITableViewTextFieldAdditionsDemo/EditableTableViewCell.m

#define kLeading	10.0

@interface SMXTextFieldCell ()

@end

@implementation SMXTextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addTextField];
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]){
        [self addTextField];
    }
    
    return self;
}

- (void) addTextField
{
    _textField = [[UITextField alloc] initWithFrame:CGRectZero];
    _textField.minimumFontSize = 12;
    _textField.adjustsFontSizeToFitWidth = YES;
    _textField.textColor = self.detailTextLabel.textColor;
    _textField.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_textField];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    [self.detailTextLabel removeFromSuperview];
    
    CGRect contentRect = self.contentView.bounds;
    CGSize textSize = [@"W" sizeWithAttributes:@{NSFontAttributeName: self.textField.font}];
    self.textField.frame = CGRectIntegral(CGRectMake(contentRect.size.width / 2.0, (contentRect.size.height - textSize.height) / 2.0, (contentRect.size.width / 2.0) - (2.0 * kLeading), textSize.height));
}

@end
