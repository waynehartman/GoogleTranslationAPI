//
//  GTLanguageDetectionResult.h
//  GoogleTranslate
//
//  Created by Wayne Hartman on 3/15/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  Class that represents the detections results of text
 */
@interface GTLanguageDetectionResult : NSObject

/*!
 *  The text used for detecting the language used
 */
@property (nonatomic, strong) NSString *originalText;

/*!
 *  Language code detected in the text.
 *  @discussion This code may be used to create GTLanguage instances.  The Google Translate API does not, however, return the display name.  This code may be used find a specific GTLanguage instance that may be cached.
 */
@property (nonatomic, strong) NSString *languageCode;

/*!
 *  The confidence score given by the detection API.  It is a value between 0.0 and 1.0
 *  @discussion The closer this value is to 1, the higher the confidence in language detection. Note that this parameter is not always available.
 */
@property (nonatomic, assign) float confidence;

@end
