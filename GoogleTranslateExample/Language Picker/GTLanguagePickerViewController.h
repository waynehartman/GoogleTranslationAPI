//
//  GTLanguagePickerViewController.h
//  GoogleTranslate
//
//  Created by Wayne Hartman on 3/15/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GTLanguage;

typedef void(^GTLanguagePickerSelectionhandler)(GTLanguage *language);

@interface GTLanguagePickerViewController : UITableViewController

@property (nonatomic, strong) GTLanguage *selectedLanguage;
@property (nonatomic, strong) NSArray *languages;
@property (nonatomic, copy) GTLanguagePickerSelectionhandler selectionHandler;

@end
