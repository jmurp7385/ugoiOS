// ParameterEncoding.swift
//
// Copyright (c) 2014–2015 Alamofire Software Foundation (http://alamofire.org/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

/**
    HTTP method definitions.

    See http://tools.ietf.org/html/rfc7231#section-4.3
*/
public enum Method: String {
    case OPTIONS = "OPTIONS"
    case GET = "GET"
    case HEAD = "HEAD"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
    case TRACE = "TRACE"
    case CONNECT = "CONNECT"
}

// MARK: - ParameterEncoding

/**
    Used to specify the way in which a set of parameters are applied to a URL request.
*/
public enum ParameterEncoding {
    /**
        A query string to be set as or appended to any existing URL query for `GET`, `HEAD`, and `DELETE` requests, or set as the body for requests with any other HTTP method. The `Content-Type` HTTP header field of an encoded request with HTTP body is set to `application/x-www-form-urlencoded`. Since there is no published specification for how to encode collection types, the convention of appending `[]` to the key for array values (`foo[]=1&foo[]=2`), and appending the key surrounded by square brackets for nested dictionary values (`foo[bar]=baz`).
    */
    case url

    /**
        Uses `NSJSONSerialization` to create a JSON representation of the parameters object, which is set as the body of the request. The `Content-Type` HTTP header field of an encoded request is set to `application/json`.
    */
    case json

    /**
        Uses `NSPropertyListSerialization` to create a plist representation of the parameters object, according to the associated format and write options values, which is set as the body of the request. The `Content-Type` HTTP header field of an encoded request is set to `application/x-plist`.
    */
    case propertyList(PropertyListSerialization.PropertyListFormat, PropertyListSerialization.WriteOptions)

    /**
        Uses the associated closure value to construct a new request given an existing request and parameters.
    */
    case custom((URLRequestConvertible, [String: AnyObject]?) -> (NSMutableURLRequest, NSError?))

    /**
        Creates a URL request by encoding parameters and applying them onto an existing request.

        :param: URLRequest The request to have parameters applied
        :param: parameters The parameters to apply

        :returns: A tuple containing the constructed request and the error that occurred during parameter encoding, if any.
    */
    public func encode(_ URLRequest: URLRequestConvertible, parameters: [String: AnyObject]?) -> (NSMutableURLRequest, NSError?) {
        var mutableURLRequest: NSMutableURLRequest = (URLRequest.URLRequest as NSURLRequest).mutableCopy() as! NSMutableURLRequest

        if parameters == nil {
            return (mutableURLRequest, nil)
        }

        var error: NSError? = nil

        switch self {
        case .url:
            func query(_ parameters: [String: AnyObject]) -> String {
                var components: [(String, String)] = []
                for key in sorted(Array(parameters.keys), <) {
                    let value: AnyObject! = parameters[key]
                    components += queryComponents(key, value)
                }

                return join("&", components.map { "\($0)=\($1)" } as [String])
            }

            func encodesParametersInURL(_ method: Method) -> Bool {
                switch method {
                case .GET, .HEAD, .DELETE:
                    return true
                default:
                    return false
                }
            }

            if let method = Method(rawValue: mutableURLRequest.httpMethod), encodesParametersInURL(method) {
                if let URLComponents = URLComponents(url: mutableURLRequest.url!, resolvingAgainstBaseURL: false) {
                    URLComponents.percentEncodedQuery = (URLComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters!)
                    mutableURLRequest.url = URLComponents.url
                }
            } else {
                if mutableURLRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                    mutableURLRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                }

                mutableURLRequest.httpBody = query(parameters!).data(using: String.Encoding.utf8, allowLossyConversion: false)
            }
        case .json:
            let options = JSONSerialization.WritingOptions.allZeros

            if let data = JSONSerialization.dataWithJSONObject(parameters!, options: options, error: &error) {
                mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                mutableURLRequest.HTTPBody = data
            }
        case .propertyList(let (format, options)):
            if let data = PropertyListSerialization.dataWithPropertyList(parameters!, format: format, options: options, error: &error) {
                mutableURLRequest.setValue("application/x-plist", forHTTPHeaderField: "Content-Type")
                mutableURLRequest.HTTPBody = data
            }
        case .custom(let closure):
            (mutableURLRequest, error) = closure(mutableURLRequest, parameters)
        }

        return (mutableURLRequest, error)
    }

    func queryComponents(_ key: String, _ value: AnyObject) -> [(String, String)] {
        var components: [(String, String)] = []
        if let dictionary = value as? [String: AnyObject] {
            for (nestedKey, value) in dictionary {
                components += queryComponents("\(key)[\(nestedKey)]", value)
            }
        } else if let array = value as? [AnyObject] {
            for value in array {
                components += queryComponents("\(key)[]", value)
            }
        } else {
            components.append((escape(key), escape("\(value)")))
        }

        return components
    }

    /**
        Returns a percent escaped string following RFC 3986 for query string formatting.

        RFC 3986 states that the following characters are "reserved" characters.

        - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
        - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="

        Core Foundation interprets RFC 3986 in terms of legal and illegal characters.

        - Legal Numbers: "0123456789"
        - Legal Letters: "abcdefghijklmnopqrstuvwxyz", "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        - Legal Characters: "!", "$", "&", "'", "(", ")", "*", "+", ",", "-",
                            ".", "/", ":", ";", "=", "?", "@", "_", "~", "\""
        - Illegal Characters: All characters not listed as Legal

        While the Core Foundation `CFURLCreateStringByAddingPercentEscapes` documentation states
        that it follows RFC 3986, the headers actually point out that it follows RFC 2396. This
        explains why it does not consider "[", "]" and "#" to be "legal" characters even though 
        they are specified as "reserved" characters in RFC 3986. The following rdar has been filed
        to hopefully get the documentation updated.

        - https://openradar.appspot.com/radar?id=5058257274011648

        In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
        query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
        should be percent escaped in the query string.

        :param: string The string to be percent escaped.

        :returns: The percent escaped string.
    */
    func escape(_ string: String) -> String {
        let generalDelimiters = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimiters = "!$&'()*+,;="

        let legalURLCharactersToBeEscaped: CFString = generalDelimiters + subDelimiters

        return CFURLCreateStringByAddingPercentEscapes(nil, string as CFString!, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
    }
}
