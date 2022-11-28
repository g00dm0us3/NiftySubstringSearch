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

Myers algorithm is a substring search algorithm, which allows for non-zero edit distance between string and substring. 

To illustrate the idea let's consider a classical substring search problem: given a string (haystack) and a pattern (needle) find one (or all) positions k in a haystack, such that:
haystack[k..k+n] = needle[0..n]. It's worth noting, that this problem can be solved in O(n) time. It is easy to see that for this problem we need to find exact matche between needle and a portion of the haystack.

However what if we want to allow for some non-exact matches? Say we are looking for a needle "sam" in the haystack "pam", and we are ok if there is no "sam" but there is "pam" (in this case we allow for edit distance to equal 1)? What we coud do is we could take each position in a haystack and calculate edit distance from needle, until we hit our target condition: edit_distance(haystack[k..k+n], needle[0..n]) <= target. The runtime of this algorithm is at least O(m*(s*n)), given the haystack is of length m, and s is the edit distance. Now imagine that your haystack is ~ 10^8 and your needle is ~10^5. You're screwed right? 

Wrong! Myers algorithm to the rescue! Given haystack, needle and a target edit distance Myers algorithm will promptly spit out a position j such as:
in haystack[0..j] there exists a suffix at a given distance from a needle. While you're imagining all the incredible things you can do given a marvellous tool which does exactly what I told that it does in the previous sentence, allow me to introduce the runtime for such a deed: O(sm/w), where
there is a new letter w, denoting the number of bits in your arch. Now all you need is to resolve the suffix. This is being done under the hood.

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
