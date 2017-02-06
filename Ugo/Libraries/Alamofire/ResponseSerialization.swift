// ResponseSerialization.swift
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

// MARK: - ResponseSerializer

/**
    The type in which all response serializers must conform to in order to serialize a response.
*/
public protocol ResponseSerializer {
    /// The type of serialized object to be created by this `ResponseSerializer`.
    associatedtype SerializedObject

    /// A closure used by response handlers that takes a request, response, and data and returns a serialized object and any error that occured in the process.
    var serializeResponse: (Foundation.URLRequest?, HTTPURLResponse?, Data?) -> (SerializedObject?, NSError?) { get }
}

/**
    A generic `ResponseSerializer` used to serialize a request, response, and data into a serialized object.
*/
public struct GenericResponseSerializer<T>: ResponseSerializer {
    /// The type of serialized object to be created by this `ResponseSerializer`.
    public typealias SerializedObject = T

    /// A closure used by response handlers that takes a request, response, and data and returns a serialized object and any error that occured in the process.
    public var serializeResponse: (Foundation.URLRequest?, HTTPURLResponse?, Data?) -> (SerializedObject?, NSError?)

    /**
        Initializes the `GenericResponseSerializer` instance with the given serialize response closure.

        :param: serializeResponse The closure used to serialize the response.

        :returns: The new generic response serializer instance.
    */
    public init(serializeResponse: @escaping (Foundation.URLRequest?, HTTPURLResponse?, Data?) -> (SerializedObject?, NSError?)) {
        self.serializeResponse = serializeResponse
    }
}

// MARK: - Default

extension Request {

    /**
        Adds a handler to be called once the request has finished.

        :param: queue The queue on which the completion handler is dispatched.
        :param: responseSerializer The response serializer responsible for serializing the request, response, and data.
        :param: completionHandler The code to be executed once the request has finished.

        :returns: The request.
    */
    public func response<T: ResponseSerializer, V>(
        _ queue: DispatchQueue? = nil,
        responseSerializer: T,
        completionHandler: @escaping (Foundation.URLRequest, HTTPURLResponse?, V?, NSError?) -> Void)
        -> Self where T.SerializedObject == V
    {
        delegate.queue.addOperation {
            let result: V?
            let error: NSError?

            (result, error) = responseSerializer.serializeResponse(self.request, self.response, self.delegate.data)

            (queue ?? DispatchQueue.main).async {
                completionHandler(self.request, self.response, result, self.delegate.error ?? error)
            }
        }

        return self
    }
}

// MARK: - Data

extension Request {

    /**
        Creates a response serializer that returns the associated data as-is.

        :returns: A data response serializer.
    */
    public static func dataResponseSerializer() -> GenericResponseSerializer<Data> {
        return GenericResponseSerializer { request, response, data in
            return (data, nil)
        }
    }

    /**
        Adds a handler to be called once the request has finished.

        :param: completionHandler The code to be executed once the request has finished.

        :returns: The request.
    */
    public func response(_ completionHandler: (Foundation.URLRequest, HTTPURLResponse?, Data?, NSError?) -> Void) -> Self {
        return response(responseSerializer: Request.dataResponseSerializer(), completionHandler: completionHandler)
    }
}

// MARK: - String

extension Request {

    /**
        Creates a response serializer that returns a string initialized from the response data with the specified string encoding.

        :param: encoding The string encoding. If `nil`, the string encoding will be determined from the server response, falling back to the default HTTP default character set, ISO-8859-1.

        :returns: A string response serializer.
    */
    public static func stringResponseSerializer(_ encoding: String.Encoding? = nil) -> GenericResponseSerializer<String> {
        var encoding = encoding
        return GenericResponseSerializer { _, response, data in
            if data == nil || data?.count == 0 {
                return (nil, nil)
            }

            if let encodingName = response?.textEncodingName, encoding == nil {
                encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(encodingName as CFString!)))
            }

            let string = NSString(data: data!, encoding: encoding.map { $0.rawValue } ?? String.Encoding.isoLatin1.rawValue) as? String

            return (string, nil)
        }
    }

    /**
        Adds a handler to be called once the request has finished.

        :param: encoding The string encoding. If `nil`, the string encoding will be determined from the server response, falling back to the default HTTP default character set, ISO-8859-1.
        :param: completionHandler A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the string, if one could be created from the URL response and data, and any error produced while creating the string.

        :returns: The request.
    */
    public func responseString(
        _ encoding: String.Encoding? = nil,
        completionHandler: (Foundation.URLRequest, HTTPURLResponse?, String?, NSError?) -> Void)
        -> Self
    {
        return response(
            responseSerializer: Request.stringResponseSerializer(encoding: encoding),
            completionHandler: completionHandler
        )
    }
}

// MARK: - JSON

extension Request {

    /**
        Creates a response serializer that returns a JSON object constructed from the response data using `NSJSONSerialization` with the specified reading options.

        :param: options The JSON serialization reading options. `.AllowFragments` by default.

        :returns: A JSON object response serializer.
    */
    public static func JSONResponseSerializer(_ options: JSONSerialization.ReadingOptions = .allowFragments) -> GenericResponseSerializer<AnyObject> {
        return GenericResponseSerializer { request, response, data in
            if data == nil || data?.count == 0 {
                return (nil, nil)
            }

            var serializationError: NSError?
            let JSON: AnyObject? = JSONSerialization.JSONObjectWithData(data!, options: options, error: &serializationError)

            return (JSON, serializationError)
        }
    }

    /**
        Adds a handler to be called once the request has finished.

        :param: options The JSON serialization reading options. `.AllowFragments` by default.
        :param: completionHandler A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the JSON object, if one could be created from the URL response and data, and any error produced while creating the JSON object.

        :returns: The request.
    */
    public func responseJSON(
        _ options: JSONSerialization.ReadingOptions = .allowFragments,
        completionHandler: (Foundation.URLRequest, HTTPURLResponse?, AnyObject?, NSError?) -> Void)
        -> Self
    {
        return response(
            responseSerializer: Request.JSONResponseSerializer(options: options),
            completionHandler: completionHandler
        )
    }
}

// MARK: - Property List

extension Request {

    /**
        Creates a response serializer that returns an object constructed from the response data using `NSPropertyListSerialization` with the specified reading options.

        :param: options The property list reading options. `0` by default.

        :returns: A property list object response serializer.
    */
    public static func propertyListResponseSerializer(_ options: PropertyListSerialization.ReadOptions = 0) -> GenericResponseSerializer<AnyObject> {
        return GenericResponseSerializer { request, response, data in
            if data == nil || data?.count == 0 {
                return (nil, nil)
            }

            var propertyListSerializationError: NSError?
            let plist: AnyObject? = PropertyListSerialization.propertyListWithData(
                data!,
                options: options,
                format: nil,
                error: &propertyListSerializationError
            )

            return (plist, propertyListSerializationError)
        }
    }

    /**
        Adds a handler to be called once the request has finished.

        :param: options The property list reading options. `0` by default.
        :param: completionHandler A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the property list, if one could be created from the URL response and data, and any error produced while creating the property list.

        :returns: The request.
    */
    public func responsePropertyList(
        _ options: PropertyListSerialization.ReadOptions = 0,
        completionHandler: (Foundation.URLRequest, HTTPURLResponse?, AnyObject?, NSError?) -> Void)
        -> Self
    {
        return response(
            responseSerializer: Request.propertyListResponseSerializer(options: options),
            completionHandler: completionHandler
        )
    }
}
