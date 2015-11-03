//
//  BuzztangWL.h
//  Buzztang
//
//

#import <Foundation/Foundation.h>

#import "CallBack.h"


@interface BuzztangWL : NSObject<CallBack>

@property(nonatomic, retain) id <CallBack> callBack;

//Login registered user
-(void)doLogInWithEmail:(NSString *)email withPassword:(NSString *)password;

//Sign uo new user
-(void)doSignUpWithUserName:(NSString *)userName withPassword:(NSString *)password withEmailId:(NSString *)emailId;

//Forgot password
-(void)getNewPasswordWithEmailId:(NSString *)emailId;

//Buzzboard Data i.e. networks
-(void)getBuzzboardData;

-(void)checkLogInCredentialwith:(UserInfoBO *)userInfo;
-(void)existingUserLoginWith:(UserInfoBO *)userInfo;
-(void)getNetWorkDetailWithid:(NSString *)networkID;
-(void)getNetWorkWithUrl:(NSString *)urls;
-(void)getAvailableNetworkData;
-(void)getSearchResultWithCriteria:(NSString *)criteria;
-(void)creatNetworkWithObject:(NetworkBO *)network;
-(void)joinNetWorkWithObject:(NetworkBO *)network;
-(void)getContactsWithNetworkId:(NSString *)networkId;
-(void)deleteNetWorkWithObject:(NetworkBO *)network;
-(void)addNetworkToBuzzboardWithNetworkId:(NSString *)networkId;
-(void)removeNetworkFromBuzzboardWithNetworkId:(NSString *)networkId;
-(void)dropFromNetworkWithNetworkId:(NSString *)networkId;
-(void)getNewContactsWithNetworkId:(NSString *)networkID;
-(void)addContactToBuzzboardWith:(NSString *)networkId andcontactId:(NSString *)contactId;
-(void)removeContactToBuzzboardWith:(NSString *)networkId andcontactId:(NSString *)contactId;
-(void)getUserProfileDetails;
-(void)ChangePasswordWithOldPassword:(NSString *)oldPassword withNewPassword:(NSString *)newPassword withConfirmationPassword:(NSString *)confirmationPassword;
-(void)editUserProfileDetailsWithFirstName:(NSString *)firstName withLastName:(NSString *)lastName withAddress:(NSString *)address withTimeZone:(NSString *)timezone;
-(void)getUserHistory;
-(void)getBuzzDataWithNetworkId:(NSString *)networkId;
-(void)createContactWithFirstName:(NSString *)firstName withLastName:(NSString *)lastName withEmail:(NSString *)email withCompany:(NSString *)companyName withOutlookId:(NSString *)outlookId withStockSymbol:(NSString *)stockSymbol withCity:(NSString *)city withFacebookUrls:(NSArray *)arrFacebookUrl withTwitterUrls:(NSArray *)arrTwitter withLinkedinUrls:(NSArray *)arrLinkedInUrl withRssFeedName:(NSArray *)arrRssFeedsName withRssFeedsUrls:(NSArray *)arrRssFeedsUrl;

/*Ontology managemnet*/
//All Ontology Words
-(void)getAllOntologyWordsForCurrentSession;

//CreatenewOntologyWord
-(void)createNewOntologyWordWithSearchValue:(NSString *)searchStr synonyms:(NSArray *)synonymsArr andExtraWords:(NSString *)extraWordsStr;
//Delete Ontology word
-(void)deleteOntologyWordWithID:(NSString *)ontologyWordID;
//Update Ontology word
-(void)updateOntologyWord:(NSString *)newOntologyWordStr WithID:(NSString *)ontologyWordID;

//Search Synonyms
-(void)searchSynonymsForWord:(NSString*)wordStr;

//Add New Synonyms for a Ontology Word
-(void)addNewSynonyms:(NSString *)synonymsStr ForWord:(NSString *)wordID;

//Update a synonym for a Ontology Word
-(void)updateSynonym:(NSString *)toBeUpdatedSynonymStr withID:(NSString *)synonymID;

//Delete a synonym for a Ontology Word
-(void)deleteSynonymWithID:(NSString *)synonymID;

//CreateContact
-(void)createContactWithNetworkID:(NSString *)networkID FirstName:(NSString *)fName lastName:(NSString *)lName emailAddress:(NSString *)emailID companyURL:(NSString *)companyUrl stockSymbol:(NSString *)stockSymbol outlookAddress:(NSString *)outlookID facebookURLs:(NSArray *)facebookURLs twitterIDs:(NSArray *)twitterIDs linkedInURls:(NSArray *)linkedInURLs RSSFeedNames:(NSArray *)rssFeedNames RSSFeedURLs:(NSArray *)rssFeedUrls;

//UpdateContact
-(void)updateContactWithFirstName:(NSString *)fName lastName:(NSString *)lName emailAddress:(NSString *)emailID companyURL:(NSString *)companyUrl stockSymbol:(NSString *)stockSymbol outlookAddress:(NSString *)outlookID facebookURLs:(NSArray *)facebookURLs twitterIDs:(NSArray *)twitterIDs linkedInURls:(NSArray *)linkedInURLs RSSFeedNames:(NSArray *)rssFeedNames RSSFeedURLs:(NSArray *)rssFeedUrls andContactID:(NSString *)contactID;

//DeleteContact
-(void)deleteContactWithContactID:(NSString *)contactID;

//Search All Synonyms #34
-(void)searchAllSynonymsForWord:(NSString*)wordStr;

-(void)getNetworkFilterNames;

//All Network Filters
-(void)getAllNetworkFilters;

//Create Network Filters
-(void)createNewNetworkFilterWithMasterId:(NSString *)masterIdentifier Synonyms:(NSArray *)synonymsIDArr andNetworkID:(NSArray *)networkIDArr;

//Update Network Filters
-(void)updateNetworkFilterWithMasterId:(NSString *)masterIdentifier Synonyms:(NSArray *)synonymsIDArr andNetworkFilterId:(NSString *)filterID;

//Delete Network Filters
-(void)deleteNetworkFilterWithNetworkFilterId:(NSString *)filterID andOptionalWordId:(NSString *)wordID;

-(void)editNetworkFilterWithIdentifier:(NSString *)identifier;

-(void)getAllBuzzboardContactsForNetworkID:(NSString *)networkID;


@end
