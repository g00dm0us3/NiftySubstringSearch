# NiftySubstringSearch
## What is it?
This is an Objective-C framework which implements Gene Myers's algorithm for approximate string matching. For more information please visit: [https://g00dm0us3.blogspot.com/2020/07/approximate-string-matching-for-ios-dev.html](https://g00dm0us3.blogspot.com/2020/07/approximate-string-matching-for-ios-dev.html)

Or just look at the usage example

## Installation Guide

Checkout and download the project, then build. Then add the framework to your Swift or Objective-C project. Don't forget to update custom "Framework Search Paths" in your project settings, or you'll get a linker error: "Module not found".

P.S. pod is coming shortly.

## Structure of the Solution

/Core/Alg/Myers contains the C++ implementation of Myers algorithm for approximate string matching.

/Core/Alg/Levenstein Edit Distance contains method for calculating edit distance between two strings

/Core/Services contains class exposing methods for approximate string lookup and suffix resolution.

In tests:
/NiftySubstringSearchTests.m contains tests of the algorithm along with some code used to verify some previous results (see the article above).

## Usage Example

Myers algorithm searches for all positions j in a text (where we are looking), where for a part of a this text lying in range of indicies [0..j] there is a suffix (some part of a string ending at index j and beggining somewhere before it), which is within a given maximum edit distance from pattern (what we are looking for). Once the location is found, we can lookup a suffix (currently only one out of all possible).

Here is a short sample usage in Swift:

```swift
import NiftySubstringSearch

let search = FuzzySubstringSearch(string: "abcdefghijklmnop")
guard let result = search?.substring("dde", maxEditDistance: 1) else { return }
let nsstring = NSString("abcdefghijklmnop")
        
    for res in result {
            
        print("Possible match at position: \(res.position), with edit distance: \(res.editDistance)")
        if let suffixRange = try! search?.resolveSuffix(for: res, substring: "dde") {
                print ("Suffix matching \("dde") with edit distance 1: \(nsstring.substring(with: suffixRange.rangeValue))")
            }
        }

```

The code above should yield the following output:
>Possible match at position: 4, with edit distance: 1

>Suffix matching "dde" with edit distance 1: de

However, there are at least two suffixes for position 4 at edit distance 1 from "dde": "de", "cde". This implementation returns only the first one it finds.
