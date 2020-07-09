//
// Created by g00dm0us3 on 6/28/20.
// Copyright (c) 2020 g00dm0us3. All rights reserved.
//

#include "MyersFastApproximateStringMatchingAlg.h"
#include <cassert>

/**
 Based on Gene Myers "A Fast Bit-Vector Algorithm for Approximate String Matching Based on Dynamic Programing"
 1999 ACM doi:0004-5411/99/0500-0395
 */

using namespace std;

#define SIGMA 256

#define MAX_RESULTS 100

#define DIV_CEIL(a,b) (a == 0 ? 1 : a/b+(a%b == 0 ? 0 : 1))

MyersFastApproximateStringMatchingAlg::MyersFastApproximateStringMatchingAlg(char *pattern, uint32_t length)
{
    ONE = (uint64_t)1;
    int w_bytes = sizeof(WORD);
    w = w_bytes * 8;

    didRun = false;

    precompute(pattern, length);
}

MyersFastApproximateStringMatchingAlg::~MyersFastApproximateStringMatchingAlg()
{
    free(P);
    free(M);

    for (int i = 0; i < SIGMA; i++) {
        free(Peq[i]);
    }

    free(Peq);
}

// pg. 405
void MyersFastApproximateStringMatchingAlg::precompute(char *pattern, int m)
{
    size_t w_bytes = sizeof(WORD);
    
    b_max = DIV_CEIL(m, w);
    W = w * b_max - m;
    HIGH_BIT = ONE << (w - 1);

    P = (WORD *) malloc(b_max * w_bytes);
    M = (WORD *) malloc(b_max * w_bytes);

    Peq = (WORD **) malloc(SIGMA * sizeof(WORD *));
    
    for (int c = 0; c < SIGMA; c++) {
        Peq[c] = (WORD *) malloc(b_max*w_bytes);
        memset(Peq[c], 0, b_max*w_bytes);
        for (int block = 0; block < b_max; block++) {
            WORD bitPos = (WORD) 1;
            for (int i = block * w; i < (block + 1) * w; ++i) {
                // fill the remainder after the last block with 1 (>m matches anything)
                if (i >= m || pattern[i] == c) {
                    Peq[c][block] |= bitPos;
                }
                bitPos <<= 1;
            }
        }
    }
}

// pg. 408
inline void MyersFastApproximateStringMatchingAlg::initBlock(int b)
{
    P[b] = (WORD) -1;//Ones
    M[b] = 0;
}

// pg. 408
inline int MyersFastApproximateStringMatchingAlg::advanceBlock(int b, uint8_t c, int hIn)
{
    WORD Pv = P[b];
    WORD Mv = M[b];
    WORD Eq = Peq[c][b];

    WORD Xv, Xh;
    WORD Ph, Mh;

    int h_out = 0;

    Xv = Eq | Mv;
    if (hIn < 0) {
        Eq |= ONE;
    }
    Xh = (((Eq & Pv) + Pv) ^ Pv) | Eq;

    Ph = Mv | (~(Xh | Pv));
    Mh = Pv & Xh;

    if (Ph & HIGH_BIT) {
        h_out += 1;
    }
    if (Mh & HIGH_BIT) {
        h_out -= 1;
    }

    Ph <<= 1;
    Mh <<= 1;

    if (hIn < 0) {
        Mh |= ONE;
    } else if (hIn > 0) {
        Ph |= ONE;
    }
    Pv = Mh | (~(Xv | Ph));
    Mv = Ph & Xv;

    P[b] = Pv;
    M[b] = Mv;

    return h_out;
}

bool MyersFastApproximateStringMatchingAlg::compareSearchResults(SearchResult &first, SearchResult &second)
{
    return first.distance < second.distance;
}

// pg. 409-410
forward_list<SearchResult> *MyersFastApproximateStringMatchingAlg::findPatternInText(char *text, uint32_t length, uint32_t maxEditDistance)
{
    if (didRun) {
        return NULL;
    }

    int y = DIV_CEIL(maxEditDistance, w) - 1;

    uint32_t *score = (uint32_t *) malloc(b_max * sizeof(uint32_t));

    forward_list<SearchResult> *result = new forward_list<SearchResult>();

    for (int b = 0; b <= y; b++) {
        initBlock(b);
        score[b] = (uint32_t)(b + 1) * w;
    }

    for (int i = 0; i < length+W; i++) {
        uint8_t c = (uint8_t)text[i];
        int carry = 0;
        
        for (int b = 0; b <= y; b++) {
            carry = advanceBlock(b, c, carry);
            score[b] += carry;
        }

        if ((score[y] - carry <= maxEditDistance) && (y < (b_max - 1)) && ((Peq[c][y + 1] & ONE) || (carry < 0))) {
            y += 1;
            initBlock(y);
            score[y] = score[y - 1] + w - carry + advanceBlock(y, c, carry);
        } else {
            while (score[y] >= (maxEditDistance + w)) {
                if (y == 0) break;
                y -= 1;
            }
        }

        if (y == (b_max - 1) && score[y] <= maxEditDistance) {
            assert(i - W >= 0);
            result->push_front(SearchResult(score[y], (uint32_t)(i - W)));
        }
    }

    result->reverse();
    result->sort(MyersFastApproximateStringMatchingAlg::compareSearchResults);

    free(score);

    didRun = true;

    return result;
}

SearchResult::SearchResult(uint32_t distance, uint32_t position)
{
    this->position = position;
    this->distance = distance;
}
