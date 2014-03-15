//
//  GTEViewController.m
//  GoogleTranslateExample
//
//  Created by Wayne Hartman on 3/15/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import "GTEViewController.h"
#import "GTLanguagePickerViewController.h"

#import "GTTranslationAPI.h"

@interface GTEViewController () <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *sourceButton;
@property (strong, nonatomic) IBOutlet UIButton *destinationButton;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *translateButton;

@property (nonatomic, strong) GTTranslationAPI *translationAPI;
@property (nonatomic, strong) GTLanguage *sourceLanguage;
@property (nonatomic, strong) GTLanguage *destinationLanguage;

@end

#define SCENE_LANGUAGE_PICKER @"SCENE_LANGUAGE_PICKER"
static NSString *API_KEY = @"";

@implementation GTEViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UIButton *button in @[self.sourceButton, self.destinationButton]) {
        button.layer.borderColor = button.tintColor.CGColor;
        button.layer.borderWidth = 0.5f;
        button.layer.cornerRadius = 10.0f;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - Lazy Loaders

- (GTTranslationAPI *)translationAPI {
    if (!_translationAPI) {
        _translationAPI = [[GTTranslationAPI alloc] initWithApiKey:API_KEY];
    }

    return _translationAPI;
}

#pragma mark - Actions

- (IBAction)didSelectTranslateButton:(id)sender {
    [self.textView resignFirstResponder];
    
    [self.translationAPI translateText:self.textView.text usingSourceLanguage:self.sourceLanguage destinationLanguage:self.destinationLanguage withCompletionHandler:^(NSArray *translations, NSError *error)
    {
        if (error) {
            NSString *message = [NSString stringWithFormat:@"Unable to fetch language: %@", error];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            if (translations.count == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No translation"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            } else {
                if (translations.count > 1) {
                    NSLog(@"translations: %@", translations);
                }
                
                GTTranslationResult *result = [translations lastObject];

                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Translation"
                                                                message:result.text
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }

    }];
}

- (IBAction)didSelectSourceButton:(id)sender {
    [self.textView resignFirstResponder];

    __weak typeof(self) weakSelf = self;

    void(^languageHandler)(GTLanguage *) = ^(GTLanguage *language) {
        weakSelf.sourceLanguage = language;
        [weakSelf dismissViewControllerAnimated:YES completion:NULL];
        [weakSelf.sourceButton setTitle:language.name forState:UIControlStateNormal];
        [weakSelf validateUI];
    };

    [self showLanguagePickerWithCompletion:languageHandler currentLanguage:self.sourceLanguage];
}

- (IBAction)didSelectDestinationButton:(id)sender {
    [self.textView resignFirstResponder];

    __weak typeof(self) weakSelf = self;

    void(^languageHandler)(GTLanguage *) = ^(GTLanguage *language) {
        weakSelf.destinationLanguage = language;
        [weakSelf dismissViewControllerAnimated:YES completion:NULL];
        [weakSelf.destinationButton setTitle:language.name forState:UIControlStateNormal];
        [weakSelf validateUI];
    };

    [self showLanguagePickerWithCompletion:languageHandler currentLanguage:self.destinationLanguage];
}

- (void)dismissModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Other Intance Methods

- (void)showLanguagePickerWithCompletion:(GTLanguagePickerSelectionhandler)handler currentLanguage:(GTLanguage *)language {
    UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:SCENE_LANGUAGE_PICKER];
    GTLanguagePickerViewController *languagePicker = (GTLanguagePickerViewController *)[navController topViewController];
    languagePicker.selectedLanguage = language;
    languagePicker.selectionHandler = handler;

    [self.translationAPI fetchAvailableTranslationLanguagesUsingLocalCache:YES
                                                     forTargetLanguageCode:nil
                                                     withCompletionHandler:^(NSArray *languages, NSError *error) {
                                                         if (error) {
                                                             NSString *message = [NSString stringWithFormat:@"Unable to fetch language: %@", error];
                                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                             message:message
                                                                                                            delegate:nil
                                                                                                   cancelButtonTitle:@"OK"
                                                                                                   otherButtonTitles:nil];
                                                             [alert show];
                                                         } else {
                                                             languagePicker.languages = languages;
                                                         }
                                                     }];

    [self presentViewController:navController animated:YES completion:NULL];
    languagePicker.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModal:)];
}

- (void)validateUI {
    self.translateButton.enabled = [self isValid];
}

- (BOOL)isValid {
    BOOL isValid = YES;

    if (self.destinationLanguage == nil) {
        isValid = NO;
    }

    if (self.textView.text.length == 0) {
        isValid = NO;
    }

    return isValid;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self validateUI];
}

#pragma mark - Notifications

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary* userInfo = notification.userInfo;
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                     animations:^{
                         UIEdgeInsets insets = UIEdgeInsetsMake(0.0, 0.0, keyboardRect.origin.y - self.textView.frame.origin.y, 0.0f);
                         self.textView.textContainerInset = insets;
                         self.textView.scrollIndicatorInsets = insets;
                     }];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    NSDictionary* userInfo = notification.userInfo;

    [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                     animations:^{
                         UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
                         self.textView.textContainerInset = insets;
                         self.textView.scrollIndicatorInsets = insets;
                     }];
}

#pragma mark - Memory Managment

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
