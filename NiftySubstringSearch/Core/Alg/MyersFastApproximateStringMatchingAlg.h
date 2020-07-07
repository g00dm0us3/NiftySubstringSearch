//
// Created by g00dm0us3 on 6/28/20.
// Copyright (c) 2020 g00dm0us3. All rights reserved.
//

#ifndef NIFTYSUBSTRINGSEARCH_MYERSFASTAPPROXIMATESTRINGMATCHINGALG_H
#define NIFTYSUBSTRINGSEARCH_MYERSFASTAPPROXIMATESTRINGMATCHINGALG_H


#include <cstdint>
#include <forward_list>

#define WORD uint64_t

struct SearchResult
{
    uint32_t distance;
    uint32_t position;

    SearchResult(uint32_t distance, uint32_t position);
};

class MyersFastApproximateStringMatchingAlg
{
public:
    MyersFastApproximateStringMatchingAlg(char *pattern, uint32_t length);
    ~MyersFastApproximateStringMatchingAlg();

    std::forward_list<SearchResult> *findPatternInText(char *text, uint32_t length, uint32_t maxEditDistance);

private:
    void precompute(char *pattern, int m);
    void initBlock(int b);
    int advanceBlock(int b, uint8_t c, int hIn);
    static bool compareSearchResults(SearchResult &first, SearchResult &second);

    bool didRun;

    size_t W;
    size_t b_max;
    int w;
    WORD ONE;
    WORD *P;
    WORD *M;
    WORD **Peq;
    WORD Mbit;

};


#endif //NIFTYSUBSTRINGSEARCH_MYERSFASTAPPROXIMATESTRINGMATCHINGALG_H
