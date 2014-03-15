GoogleTranslationAPI v0.1
====================

GoogleTranslationAPI is an Objective-C wrapper for calling the Google Translate API.

How to use:
------------

Instantiate a GTTranslationAPI with your Google Translate API Key:

    GTTranslationAPI *translateAPI = [[GTTranslationAPI alloc] initWithApiKey:@"<YOUR KEY>"];

Then call its translate method:

    [translationAPI translateText:@"Hello. My name is Inigo Montoya. You killed my father. Prepare to die."
              usingSourceLanguage:nil
              destinationLanguage:[[GTLanguage alloc] initWithLanguageCode:@"es"]
              withCompletionHandler:^(NSArray *translations, NSError *error) {
                  if (error) {
                     NSLog(@"error: %@", error);
                  } else {
                     NSLog(@"translations: %@", translations);
                  }
    }];

This library includes all v2 supported API calls:

 - Translate
 - Detect Language
 - Get Supported Languages
  
 
How to setup your API key
--------------------------

Setting up your API key involves several steps:

### Generating a Key ###

 1. Log into your Google account.
 1. Got to [https://cloud.google.com/console](https://cloud.google.com/console)
 1. Create a new project.
 1. In the "APIs & auth" section click on "APIs", then active "Translate API".
 1. In the "APIs & auth" section click on "Credentials" and click on "Create New Key"
 1. Select "iOS Key" from the pop up and add the application bundle ID for your app.

At this point the only method you can call is the `languages` API.  This is because you will need to setup billing.  As of this commit, Google allows up to 2 million characters of free translation per month.  Any usage beyond that is subject to charges.

### Setting Up Billing ###

 1. Click on the "Settings", then "Billing", and then select your project.
 1. Select the "Profile" tab and enter the billing details.
 1. Once you have successfully entered your details, go make a sandwich.  Seriously.  The verification email can take a while to reach your inbox and you cannot proceed until you have verified.
 1. After the verfication email arrives, click on the link enclosed.
 1. Tada! You are now activated and ready to start making calls. 