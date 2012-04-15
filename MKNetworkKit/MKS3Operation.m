//
//  MKS3Operation.m
//  MKNetworkKit-iOS
//
//  Created by Mugunth Kumar on 15/4/12.
//  Copyright (c) 2012 Steinlogic. All rights reserved.
//

#import "MKS3Operation.h"

@implementation MKS3Operation

/*
 Authorization = "AWS" + " " + AWSAccessKeyId + ":" + Signature;
 
 Signature = Base64( HMAC-SHA1( UTF-8-Encoding-Of( YourSecretAccessKeyID, StringToSign ) ) );
 
 StringToSign = HTTP-Verb + "\n" +
 Content-MD5 + "\n" +
 Content-Type + "\n" +
 Date + "\n" +
 CanonicalizedAmzHeaders +
 CanonicalizedResource;
 
 CanonicalizedResource = [ "/" + Bucket ] +
 <HTTP-Request-URI, from the protocol name up to the query string> +
 [ sub-resource, if present. For example "?acl", "?location", "?logging", or "?torrent"];
 
 CanonicalizedAmzHeaders = <described below>
 */

-(void) signWithAccessId:(NSString*) accessId secretKey:(NSString*) password {
  
  NSMutableString *stringToSign = [NSMutableString string];
  [stringToSign appendFormat:@"%@\n", self.readonlyRequest.HTTPMethod];
  
  NSString *bodyMD5Hash = [[[NSString alloc] initWithData:[self bodyData] encoding:NSUTF8StringEncoding] md5];
  NSString *contentTypeMD5Hash = [[self.readonlyRequest valueForHTTPHeaderField:@"Content-Type"] md5];
  NSString *dateString = [[NSDate date] rfc1123String];
  
  [stringToSign appendFormat:@"%@\n%@\n%@\n%@\n", bodyMD5Hash, contentTypeMD5Hash, dateString];
  
  NSString *pathToResource = @"/";
  [stringToSign appendString:pathToResource];
  
  NSString *signature = [[[stringToSign stringByEncryptingWithPassword:password] 
                          dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
  
  NSString *awsAuthHeaderValue = [NSString stringWithFormat:@"AWS %@:%@", accessId, signature];
  [self addHeaders:[NSDictionary dictionaryWithObject:awsAuthHeaderValue 
                                               forKey:@"Authorization"]];
}
@end