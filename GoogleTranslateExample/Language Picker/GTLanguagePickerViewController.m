//
//  GTLanguagePickerViewController.m
//  GoogleTranslate
//
//  Created by Wayne Hartman on 3/15/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import "GTLanguagePickerViewController.h"
#import "GTLanguage.h"

@interface GTLanguagePickerViewController ()

@end

@implementation GTLanguagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)setSelectedLanguage:(GTLanguage *)selectedLanguage {
    _selectedLanguage = selectedLanguage;

    if ([self isViewLoaded]) {
        [self.tableView reloadData];
    }
}

- (void)setLanguages:(NSArray *)languages {
    _languages = languages;

    if ([self isViewLoaded]) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.languages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"LanguageCell";

    GTLanguage *language = self.languages[indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.textLabel.text = language.name;
    cell.detailTextLabel.text = language.languageCode;
    cell.accessoryType = [language.languageCode isEqualToString:self.selectedLanguage.languageCode] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectionHandler) {
        self.selectionHandler(self.languages[indexPath.row]);
    }
}

@end
