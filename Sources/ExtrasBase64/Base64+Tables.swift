// This base64 implementation is heavily inspired by:

// https://github.com/lemire/fastbase64/blob/master/src/chromiumbase64.c
/*
 Copyright (c) 2015-2016, Wojciech Muła, Alfred Klomp,  Daniel Lemire
 (Unless otherwise stated in the source code)
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// https://github.com/client9/stringencoders/blob/master/src/modp_b64.c
/*
 The MIT License (MIT)

 Copyright (c) 2016 Nick Galbreath

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

// MARK: - Lookup tables -

extension Base64 {
    @usableFromInline
    static let encodePaddingCharacter: UInt8 = 61

    @usableFromInline
    static let encoding0: [UInt8] = [
        UInt8(ascii: "A"), UInt8(ascii: "A"), UInt8(ascii: "A"), UInt8(ascii: "A"), UInt8(ascii: "B"), UInt8(ascii: "B"), UInt8(ascii: "B"),
        UInt8(ascii: "B"), UInt8(ascii: "C"), UInt8(ascii: "C"),
        UInt8(ascii: "C"), UInt8(ascii: "C"), UInt8(ascii: "D"), UInt8(ascii: "D"), UInt8(ascii: "D"), UInt8(ascii: "D"), UInt8(ascii: "E"),
        UInt8(ascii: "E"), UInt8(ascii: "E"), UInt8(ascii: "E"),
        UInt8(ascii: "F"), UInt8(ascii: "F"), UInt8(ascii: "F"), UInt8(ascii: "F"), UInt8(ascii: "G"), UInt8(ascii: "G"), UInt8(ascii: "G"),
        UInt8(ascii: "G"), UInt8(ascii: "H"), UInt8(ascii: "H"),
        UInt8(ascii: "H"), UInt8(ascii: "H"), UInt8(ascii: "I"), UInt8(ascii: "I"), UInt8(ascii: "I"), UInt8(ascii: "I"), UInt8(ascii: "J"),
        UInt8(ascii: "J"), UInt8(ascii: "J"), UInt8(ascii: "J"),
        UInt8(ascii: "K"), UInt8(ascii: "K"), UInt8(ascii: "K"), UInt8(ascii: "K"), UInt8(ascii: "L"), UInt8(ascii: "L"), UInt8(ascii: "L"),
        UInt8(ascii: "L"), UInt8(ascii: "M"), UInt8(ascii: "M"),
        UInt8(ascii: "M"), UInt8(ascii: "M"), UInt8(ascii: "N"), UInt8(ascii: "N"), UInt8(ascii: "N"), UInt8(ascii: "N"), UInt8(ascii: "O"),
        UInt8(ascii: "O"), UInt8(ascii: "O"), UInt8(ascii: "O"),
        UInt8(ascii: "P"), UInt8(ascii: "P"), UInt8(ascii: "P"), UInt8(ascii: "P"), UInt8(ascii: "Q"), UInt8(ascii: "Q"), UInt8(ascii: "Q"),
        UInt8(ascii: "Q"), UInt8(ascii: "R"), UInt8(ascii: "R"),
        UInt8(ascii: "R"), UInt8(ascii: "R"), UInt8(ascii: "S"), UInt8(ascii: "S"), UInt8(ascii: "S"), UInt8(ascii: "S"), UInt8(ascii: "T"),
        UInt8(ascii: "T"), UInt8(ascii: "T"), UInt8(ascii: "T"),
        UInt8(ascii: "U"), UInt8(ascii: "U"), UInt8(ascii: "U"), UInt8(ascii: "U"), UInt8(ascii: "V"), UInt8(ascii: "V"), UInt8(ascii: "V"),
        UInt8(ascii: "V"), UInt8(ascii: "W"), UInt8(ascii: "W"),
        UInt8(ascii: "W"), UInt8(ascii: "W"), UInt8(ascii: "X"), UInt8(ascii: "X"), UInt8(ascii: "X"), UInt8(ascii: "X"), UInt8(ascii: "Y"),
        UInt8(ascii: "Y"), UInt8(ascii: "Y"), UInt8(ascii: "Y"),
        UInt8(ascii: "Z"), UInt8(ascii: "Z"), UInt8(ascii: "Z"), UInt8(ascii: "Z"), UInt8(ascii: "a"), UInt8(ascii: "a"), UInt8(ascii: "a"),
        UInt8(ascii: "a"), UInt8(ascii: "b"), UInt8(ascii: "b"),
        UInt8(ascii: "b"), UInt8(ascii: "b"), UInt8(ascii: "c"), UInt8(ascii: "c"), UInt8(ascii: "c"), UInt8(ascii: "c"), UInt8(ascii: "d"),
        UInt8(ascii: "d"), UInt8(ascii: "d"), UInt8(ascii: "d"),
        UInt8(ascii: "e"), UInt8(ascii: "e"), UInt8(ascii: "e"), UInt8(ascii: "e"), UInt8(ascii: "f"), UInt8(ascii: "f"), UInt8(ascii: "f"),
        UInt8(ascii: "f"), UInt8(ascii: "g"), UInt8(ascii: "g"),
        UInt8(ascii: "g"), UInt8(ascii: "g"), UInt8(ascii: "h"), UInt8(ascii: "h"), UInt8(ascii: "h"), UInt8(ascii: "h"), UInt8(ascii: "i"),
        UInt8(ascii: "i"), UInt8(ascii: "i"), UInt8(ascii: "i"),
        UInt8(ascii: "j"), UInt8(ascii: "j"), UInt8(ascii: "j"), UInt8(ascii: "j"), UInt8(ascii: "k"), UInt8(ascii: "k"), UInt8(ascii: "k"),
        UInt8(ascii: "k"), UInt8(ascii: "l"), UInt8(ascii: "l"),
        UInt8(ascii: "l"), UInt8(ascii: "l"), UInt8(ascii: "m"), UInt8(ascii: "m"), UInt8(ascii: "m"), UInt8(ascii: "m"), UInt8(ascii: "n"),
        UInt8(ascii: "n"), UInt8(ascii: "n"), UInt8(ascii: "n"),
        UInt8(ascii: "o"), UInt8(ascii: "o"), UInt8(ascii: "o"), UInt8(ascii: "o"), UInt8(ascii: "p"), UInt8(ascii: "p"), UInt8(ascii: "p"),
        UInt8(ascii: "p"), UInt8(ascii: "q"), UInt8(ascii: "q"),
        UInt8(ascii: "q"), UInt8(ascii: "q"), UInt8(ascii: "r"), UInt8(ascii: "r"), UInt8(ascii: "r"), UInt8(ascii: "r"), UInt8(ascii: "s"),
        UInt8(ascii: "s"), UInt8(ascii: "s"), UInt8(ascii: "s"),
        UInt8(ascii: "t"), UInt8(ascii: "t"), UInt8(ascii: "t"), UInt8(ascii: "t"), UInt8(ascii: "u"), UInt8(ascii: "u"), UInt8(ascii: "u"),
        UInt8(ascii: "u"), UInt8(ascii: "v"), UInt8(ascii: "v"),
        UInt8(ascii: "v"), UInt8(ascii: "v"), UInt8(ascii: "w"), UInt8(ascii: "w"), UInt8(ascii: "w"), UInt8(ascii: "w"), UInt8(ascii: "x"),
        UInt8(ascii: "x"), UInt8(ascii: "x"), UInt8(ascii: "x"),
        UInt8(ascii: "y"), UInt8(ascii: "y"), UInt8(ascii: "y"), UInt8(ascii: "y"), UInt8(ascii: "z"), UInt8(ascii: "z"), UInt8(ascii: "z"),
        UInt8(ascii: "z"), UInt8(ascii: "0"), UInt8(ascii: "0"),
        UInt8(ascii: "0"), UInt8(ascii: "0"), UInt8(ascii: "1"), UInt8(ascii: "1"), UInt8(ascii: "1"), UInt8(ascii: "1"), UInt8(ascii: "2"),
        UInt8(ascii: "2"), UInt8(ascii: "2"), UInt8(ascii: "2"),
        UInt8(ascii: "3"), UInt8(ascii: "3"), UInt8(ascii: "3"), UInt8(ascii: "3"), UInt8(ascii: "4"), UInt8(ascii: "4"), UInt8(ascii: "4"),
        UInt8(ascii: "4"), UInt8(ascii: "5"), UInt8(ascii: "5"),
        UInt8(ascii: "5"), UInt8(ascii: "5"), UInt8(ascii: "6"), UInt8(ascii: "6"), UInt8(ascii: "6"), UInt8(ascii: "6"), UInt8(ascii: "7"),
        UInt8(ascii: "7"), UInt8(ascii: "7"), UInt8(ascii: "7"),
        UInt8(ascii: "8"), UInt8(ascii: "8"), UInt8(ascii: "8"), UInt8(ascii: "8"), UInt8(ascii: "9"), UInt8(ascii: "9"), UInt8(ascii: "9"),
        UInt8(ascii: "9"), UInt8(ascii: "+"), UInt8(ascii: "+"),
        UInt8(ascii: "+"), UInt8(ascii: "+"), UInt8(ascii: "/"), UInt8(ascii: "/"), UInt8(ascii: "/"), UInt8(ascii: "/"),
    ]

    @usableFromInline
    static let encoding1: [UInt8] = [
        UInt8(ascii: "A"), UInt8(ascii: "B"), UInt8(ascii: "C"), UInt8(ascii: "D"), UInt8(ascii: "E"), UInt8(ascii: "F"), UInt8(ascii: "G"),
        UInt8(ascii: "H"), UInt8(ascii: "I"), UInt8(ascii: "J"),
        UInt8(ascii: "K"), UInt8(ascii: "L"), UInt8(ascii: "M"), UInt8(ascii: "N"), UInt8(ascii: "O"), UInt8(ascii: "P"), UInt8(ascii: "Q"),
        UInt8(ascii: "R"), UInt8(ascii: "S"), UInt8(ascii: "T"),
        UInt8(ascii: "U"), UInt8(ascii: "V"), UInt8(ascii: "W"), UInt8(ascii: "X"), UInt8(ascii: "Y"), UInt8(ascii: "Z"), UInt8(ascii: "a"),
        UInt8(ascii: "b"), UInt8(ascii: "c"), UInt8(ascii: "d"),
        UInt8(ascii: "e"), UInt8(ascii: "f"), UInt8(ascii: "g"), UInt8(ascii: "h"), UInt8(ascii: "i"), UInt8(ascii: "j"), UInt8(ascii: "k"),
        UInt8(ascii: "l"), UInt8(ascii: "m"), UInt8(ascii: "n"),
        UInt8(ascii: "o"), UInt8(ascii: "p"), UInt8(ascii: "q"), UInt8(ascii: "r"), UInt8(ascii: "s"), UInt8(ascii: "t"), UInt8(ascii: "u"),
        UInt8(ascii: "v"), UInt8(ascii: "w"), UInt8(ascii: "x"),
        UInt8(ascii: "y"), UInt8(ascii: "z"), UInt8(ascii: "0"), UInt8(ascii: "1"), UInt8(ascii: "2"), UInt8(ascii: "3"), UInt8(ascii: "4"),
        UInt8(ascii: "5"), UInt8(ascii: "6"), UInt8(ascii: "7"),
        UInt8(ascii: "8"), UInt8(ascii: "9"), UInt8(ascii: "+"), UInt8(ascii: "/"), UInt8(ascii: "A"), UInt8(ascii: "B"), UInt8(ascii: "C"),
        UInt8(ascii: "D"), UInt8(ascii: "E"), UInt8(ascii: "F"),
        UInt8(ascii: "G"), UInt8(ascii: "H"), UInt8(ascii: "I"), UInt8(ascii: "J"), UInt8(ascii: "K"), UInt8(ascii: "L"), UInt8(ascii: "M"),
        UInt8(ascii: "N"), UInt8(ascii: "O"), UInt8(ascii: "P"),
        UInt8(ascii: "Q"), UInt8(ascii: "R"), UInt8(ascii: "S"), UInt8(ascii: "T"), UInt8(ascii: "U"), UInt8(ascii: "V"), UInt8(ascii: "W"),
        UInt8(ascii: "X"), UInt8(ascii: "Y"), UInt8(ascii: "Z"),
        UInt8(ascii: "a"), UInt8(ascii: "b"), UInt8(ascii: "c"), UInt8(ascii: "d"), UInt8(ascii: "e"), UInt8(ascii: "f"), UInt8(ascii: "g"),
        UInt8(ascii: "h"), UInt8(ascii: "i"), UInt8(ascii: "j"),
        UInt8(ascii: "k"), UInt8(ascii: "l"), UInt8(ascii: "m"), UInt8(ascii: "n"), UInt8(ascii: "o"), UInt8(ascii: "p"), UInt8(ascii: "q"),
        UInt8(ascii: "r"), UInt8(ascii: "s"), UInt8(ascii: "t"),
        UInt8(ascii: "u"), UInt8(ascii: "v"), UInt8(ascii: "w"), UInt8(ascii: "x"), UInt8(ascii: "y"), UInt8(ascii: "z"), UInt8(ascii: "0"),
        UInt8(ascii: "1"), UInt8(ascii: "2"), UInt8(ascii: "3"),
        UInt8(ascii: "4"), UInt8(ascii: "5"), UInt8(ascii: "6"), UInt8(ascii: "7"), UInt8(ascii: "8"), UInt8(ascii: "9"), UInt8(ascii: "+"),
        UInt8(ascii: "/"), UInt8(ascii: "A"), UInt8(ascii: "B"),
        UInt8(ascii: "C"), UInt8(ascii: "D"), UInt8(ascii: "E"), UInt8(ascii: "F"), UInt8(ascii: "G"), UInt8(ascii: "H"), UInt8(ascii: "I"),
        UInt8(ascii: "J"), UInt8(ascii: "K"), UInt8(ascii: "L"),
        UInt8(ascii: "M"), UInt8(ascii: "N"), UInt8(ascii: "O"), UInt8(ascii: "P"), UInt8(ascii: "Q"), UInt8(ascii: "R"), UInt8(ascii: "S"),
        UInt8(ascii: "T"), UInt8(ascii: "U"), UInt8(ascii: "V"),
        UInt8(ascii: "W"), UInt8(ascii: "X"), UInt8(ascii: "Y"), UInt8(ascii: "Z"), UInt8(ascii: "a"), UInt8(ascii: "b"), UInt8(ascii: "c"),
        UInt8(ascii: "d"), UInt8(ascii: "e"), UInt8(ascii: "f"),
        UInt8(ascii: "g"), UInt8(ascii: "h"), UInt8(ascii: "i"), UInt8(ascii: "j"), UInt8(ascii: "k"), UInt8(ascii: "l"), UInt8(ascii: "m"),
        UInt8(ascii: "n"), UInt8(ascii: "o"), UInt8(ascii: "p"),
        UInt8(ascii: "q"), UInt8(ascii: "r"), UInt8(ascii: "s"), UInt8(ascii: "t"), UInt8(ascii: "u"), UInt8(ascii: "v"), UInt8(ascii: "w"),
        UInt8(ascii: "x"), UInt8(ascii: "y"), UInt8(ascii: "z"),
        UInt8(ascii: "0"), UInt8(ascii: "1"), UInt8(ascii: "2"), UInt8(ascii: "3"), UInt8(ascii: "4"), UInt8(ascii: "5"), UInt8(ascii: "6"),
        UInt8(ascii: "7"), UInt8(ascii: "8"), UInt8(ascii: "9"),
        UInt8(ascii: "+"), UInt8(ascii: "/"), UInt8(ascii: "A"), UInt8(ascii: "B"), UInt8(ascii: "C"), UInt8(ascii: "D"), UInt8(ascii: "E"),
        UInt8(ascii: "F"), UInt8(ascii: "G"), UInt8(ascii: "H"),
        UInt8(ascii: "I"), UInt8(ascii: "J"), UInt8(ascii: "K"), UInt8(ascii: "L"), UInt8(ascii: "M"), UInt8(ascii: "N"), UInt8(ascii: "O"),
        UInt8(ascii: "P"), UInt8(ascii: "Q"), UInt8(ascii: "R"),
        UInt8(ascii: "S"), UInt8(ascii: "T"), UInt8(ascii: "U"), UInt8(ascii: "V"), UInt8(ascii: "W"), UInt8(ascii: "X"), UInt8(ascii: "Y"),
        UInt8(ascii: "Z"), UInt8(ascii: "a"), UInt8(ascii: "b"),
        UInt8(ascii: "c"), UInt8(ascii: "d"), UInt8(ascii: "e"), UInt8(ascii: "f"), UInt8(ascii: "g"), UInt8(ascii: "h"), UInt8(ascii: "i"),
        UInt8(ascii: "j"), UInt8(ascii: "k"), UInt8(ascii: "l"),
        UInt8(ascii: "m"), UInt8(ascii: "n"), UInt8(ascii: "o"), UInt8(ascii: "p"), UInt8(ascii: "q"), UInt8(ascii: "r"), UInt8(ascii: "s"),
        UInt8(ascii: "t"), UInt8(ascii: "u"), UInt8(ascii: "v"),
        UInt8(ascii: "w"), UInt8(ascii: "x"), UInt8(ascii: "y"), UInt8(ascii: "z"), UInt8(ascii: "0"), UInt8(ascii: "1"), UInt8(ascii: "2"),
        UInt8(ascii: "3"), UInt8(ascii: "4"), UInt8(ascii: "5"),
        UInt8(ascii: "6"), UInt8(ascii: "7"), UInt8(ascii: "8"), UInt8(ascii: "9"), UInt8(ascii: "+"), UInt8(ascii: "/"),
    ]

    @usableFromInline
    static let encoding0url: [UInt8] = [
        UInt8(ascii: "A"), UInt8(ascii: "A"), UInt8(ascii: "A"), UInt8(ascii: "A"), UInt8(ascii: "B"), UInt8(ascii: "B"), UInt8(ascii: "B"),
        UInt8(ascii: "B"), UInt8(ascii: "C"), UInt8(ascii: "C"),
        UInt8(ascii: "C"), UInt8(ascii: "C"), UInt8(ascii: "D"), UInt8(ascii: "D"), UInt8(ascii: "D"), UInt8(ascii: "D"), UInt8(ascii: "E"),
        UInt8(ascii: "E"), UInt8(ascii: "E"), UInt8(ascii: "E"),
        UInt8(ascii: "F"), UInt8(ascii: "F"), UInt8(ascii: "F"), UInt8(ascii: "F"), UInt8(ascii: "G"), UInt8(ascii: "G"), UInt8(ascii: "G"),
        UInt8(ascii: "G"), UInt8(ascii: "H"), UInt8(ascii: "H"),
        UInt8(ascii: "H"), UInt8(ascii: "H"), UInt8(ascii: "I"), UInt8(ascii: "I"), UInt8(ascii: "I"), UInt8(ascii: "I"), UInt8(ascii: "J"),
        UInt8(ascii: "J"), UInt8(ascii: "J"), UInt8(ascii: "J"),
        UInt8(ascii: "K"), UInt8(ascii: "K"), UInt8(ascii: "K"), UInt8(ascii: "K"), UInt8(ascii: "L"), UInt8(ascii: "L"), UInt8(ascii: "L"),
        UInt8(ascii: "L"), UInt8(ascii: "M"), UInt8(ascii: "M"),
        UInt8(ascii: "M"), UInt8(ascii: "M"), UInt8(ascii: "N"), UInt8(ascii: "N"), UInt8(ascii: "N"), UInt8(ascii: "N"), UInt8(ascii: "O"),
        UInt8(ascii: "O"), UInt8(ascii: "O"), UInt8(ascii: "O"),
        UInt8(ascii: "P"), UInt8(ascii: "P"), UInt8(ascii: "P"), UInt8(ascii: "P"), UInt8(ascii: "Q"), UInt8(ascii: "Q"), UInt8(ascii: "Q"),
        UInt8(ascii: "Q"), UInt8(ascii: "R"), UInt8(ascii: "R"),
        UInt8(ascii: "R"), UInt8(ascii: "R"), UInt8(ascii: "S"), UInt8(ascii: "S"), UInt8(ascii: "S"), UInt8(ascii: "S"), UInt8(ascii: "T"),
        UInt8(ascii: "T"), UInt8(ascii: "T"), UInt8(ascii: "T"),
        UInt8(ascii: "U"), UInt8(ascii: "U"), UInt8(ascii: "U"), UInt8(ascii: "U"), UInt8(ascii: "V"), UInt8(ascii: "V"), UInt8(ascii: "V"),
        UInt8(ascii: "V"), UInt8(ascii: "W"), UInt8(ascii: "W"),
        UInt8(ascii: "W"), UInt8(ascii: "W"), UInt8(ascii: "X"), UInt8(ascii: "X"), UInt8(ascii: "X"), UInt8(ascii: "X"), UInt8(ascii: "Y"),
        UInt8(ascii: "Y"), UInt8(ascii: "Y"), UInt8(ascii: "Y"),
        UInt8(ascii: "Z"), UInt8(ascii: "Z"), UInt8(ascii: "Z"), UInt8(ascii: "Z"), UInt8(ascii: "a"), UInt8(ascii: "a"), UInt8(ascii: "a"),
        UInt8(ascii: "a"), UInt8(ascii: "b"), UInt8(ascii: "b"),
        UInt8(ascii: "b"), UInt8(ascii: "b"), UInt8(ascii: "c"), UInt8(ascii: "c"), UInt8(ascii: "c"), UInt8(ascii: "c"), UInt8(ascii: "d"),
        UInt8(ascii: "d"), UInt8(ascii: "d"), UInt8(ascii: "d"),
        UInt8(ascii: "e"), UInt8(ascii: "e"), UInt8(ascii: "e"), UInt8(ascii: "e"), UInt8(ascii: "f"), UInt8(ascii: "f"), UInt8(ascii: "f"),
        UInt8(ascii: "f"), UInt8(ascii: "g"), UInt8(ascii: "g"),
        UInt8(ascii: "g"), UInt8(ascii: "g"), UInt8(ascii: "h"), UInt8(ascii: "h"), UInt8(ascii: "h"), UInt8(ascii: "h"), UInt8(ascii: "i"),
        UInt8(ascii: "i"), UInt8(ascii: "i"), UInt8(ascii: "i"),
        UInt8(ascii: "j"), UInt8(ascii: "j"), UInt8(ascii: "j"), UInt8(ascii: "j"), UInt8(ascii: "k"), UInt8(ascii: "k"), UInt8(ascii: "k"),
        UInt8(ascii: "k"), UInt8(ascii: "l"), UInt8(ascii: "l"),
        UInt8(ascii: "l"), UInt8(ascii: "l"), UInt8(ascii: "m"), UInt8(ascii: "m"), UInt8(ascii: "m"), UInt8(ascii: "m"), UInt8(ascii: "n"),
        UInt8(ascii: "n"), UInt8(ascii: "n"), UInt8(ascii: "n"),
        UInt8(ascii: "o"), UInt8(ascii: "o"), UInt8(ascii: "o"), UInt8(ascii: "o"), UInt8(ascii: "p"), UInt8(ascii: "p"), UInt8(ascii: "p"),
        UInt8(ascii: "p"), UInt8(ascii: "q"), UInt8(ascii: "q"),
        UInt8(ascii: "q"), UInt8(ascii: "q"), UInt8(ascii: "r"), UInt8(ascii: "r"), UInt8(ascii: "r"), UInt8(ascii: "r"), UInt8(ascii: "s"),
        UInt8(ascii: "s"), UInt8(ascii: "s"), UInt8(ascii: "s"),
        UInt8(ascii: "t"), UInt8(ascii: "t"), UInt8(ascii: "t"), UInt8(ascii: "t"), UInt8(ascii: "u"), UInt8(ascii: "u"), UInt8(ascii: "u"),
        UInt8(ascii: "u"), UInt8(ascii: "v"), UInt8(ascii: "v"),
        UInt8(ascii: "v"), UInt8(ascii: "v"), UInt8(ascii: "w"), UInt8(ascii: "w"), UInt8(ascii: "w"), UInt8(ascii: "w"), UInt8(ascii: "x"),
        UInt8(ascii: "x"), UInt8(ascii: "x"), UInt8(ascii: "x"),
        UInt8(ascii: "y"), UInt8(ascii: "y"), UInt8(ascii: "y"), UInt8(ascii: "y"), UInt8(ascii: "z"), UInt8(ascii: "z"), UInt8(ascii: "z"),
        UInt8(ascii: "z"), UInt8(ascii: "0"), UInt8(ascii: "0"),
        UInt8(ascii: "0"), UInt8(ascii: "0"), UInt8(ascii: "1"), UInt8(ascii: "1"), UInt8(ascii: "1"), UInt8(ascii: "1"), UInt8(ascii: "2"),
        UInt8(ascii: "2"), UInt8(ascii: "2"), UInt8(ascii: "2"),
        UInt8(ascii: "3"), UInt8(ascii: "3"), UInt8(ascii: "3"), UInt8(ascii: "3"), UInt8(ascii: "4"), UInt8(ascii: "4"), UInt8(ascii: "4"),
        UInt8(ascii: "4"), UInt8(ascii: "5"), UInt8(ascii: "5"),
        UInt8(ascii: "5"), UInt8(ascii: "5"), UInt8(ascii: "6"), UInt8(ascii: "6"), UInt8(ascii: "6"), UInt8(ascii: "6"), UInt8(ascii: "7"),
        UInt8(ascii: "7"), UInt8(ascii: "7"), UInt8(ascii: "7"),
        UInt8(ascii: "8"), UInt8(ascii: "8"), UInt8(ascii: "8"), UInt8(ascii: "8"), UInt8(ascii: "9"), UInt8(ascii: "9"), UInt8(ascii: "9"),
        UInt8(ascii: "9"), UInt8(ascii: "-"), UInt8(ascii: "-"),
        UInt8(ascii: "-"), UInt8(ascii: "-"), UInt8(ascii: "_"), UInt8(ascii: "_"), UInt8(ascii: "_"), UInt8(ascii: "_"),
    ]

    @usableFromInline
    static let encoding1url: [UInt8] = [
        UInt8(ascii: "A"), UInt8(ascii: "B"), UInt8(ascii: "C"), UInt8(ascii: "D"), UInt8(ascii: "E"), UInt8(ascii: "F"), UInt8(ascii: "G"),
        UInt8(ascii: "H"), UInt8(ascii: "I"), UInt8(ascii: "J"),
        UInt8(ascii: "K"), UInt8(ascii: "L"), UInt8(ascii: "M"), UInt8(ascii: "N"), UInt8(ascii: "O"), UInt8(ascii: "P"), UInt8(ascii: "Q"),
        UInt8(ascii: "R"), UInt8(ascii: "S"), UInt8(ascii: "T"),
        UInt8(ascii: "U"), UInt8(ascii: "V"), UInt8(ascii: "W"), UInt8(ascii: "X"), UInt8(ascii: "Y"), UInt8(ascii: "Z"), UInt8(ascii: "a"),
        UInt8(ascii: "b"), UInt8(ascii: "c"), UInt8(ascii: "d"),
        UInt8(ascii: "e"), UInt8(ascii: "f"), UInt8(ascii: "g"), UInt8(ascii: "h"), UInt8(ascii: "i"), UInt8(ascii: "j"), UInt8(ascii: "k"),
        UInt8(ascii: "l"), UInt8(ascii: "m"), UInt8(ascii: "n"),
        UInt8(ascii: "o"), UInt8(ascii: "p"), UInt8(ascii: "q"), UInt8(ascii: "r"), UInt8(ascii: "s"), UInt8(ascii: "t"), UInt8(ascii: "u"),
        UInt8(ascii: "v"), UInt8(ascii: "w"), UInt8(ascii: "x"),
        UInt8(ascii: "y"), UInt8(ascii: "z"), UInt8(ascii: "0"), UInt8(ascii: "1"), UInt8(ascii: "2"), UInt8(ascii: "3"), UInt8(ascii: "4"),
        UInt8(ascii: "5"), UInt8(ascii: "6"), UInt8(ascii: "7"),
        UInt8(ascii: "8"), UInt8(ascii: "9"), UInt8(ascii: "-"), UInt8(ascii: "_"), UInt8(ascii: "A"), UInt8(ascii: "B"), UInt8(ascii: "C"),
        UInt8(ascii: "D"), UInt8(ascii: "E"), UInt8(ascii: "F"),
        UInt8(ascii: "G"), UInt8(ascii: "H"), UInt8(ascii: "I"), UInt8(ascii: "J"), UInt8(ascii: "K"), UInt8(ascii: "L"), UInt8(ascii: "M"),
        UInt8(ascii: "N"), UInt8(ascii: "O"), UInt8(ascii: "P"),
        UInt8(ascii: "Q"), UInt8(ascii: "R"), UInt8(ascii: "S"), UInt8(ascii: "T"), UInt8(ascii: "U"), UInt8(ascii: "V"), UInt8(ascii: "W"),
        UInt8(ascii: "X"), UInt8(ascii: "Y"), UInt8(ascii: "Z"),
        UInt8(ascii: "a"), UInt8(ascii: "b"), UInt8(ascii: "c"), UInt8(ascii: "d"), UInt8(ascii: "e"), UInt8(ascii: "f"), UInt8(ascii: "g"),
        UInt8(ascii: "h"), UInt8(ascii: "i"), UInt8(ascii: "j"),
        UInt8(ascii: "k"), UInt8(ascii: "l"), UInt8(ascii: "m"), UInt8(ascii: "n"), UInt8(ascii: "o"), UInt8(ascii: "p"), UInt8(ascii: "q"),
        UInt8(ascii: "r"), UInt8(ascii: "s"), UInt8(ascii: "t"),
        UInt8(ascii: "u"), UInt8(ascii: "v"), UInt8(ascii: "w"), UInt8(ascii: "x"), UInt8(ascii: "y"), UInt8(ascii: "z"), UInt8(ascii: "0"),
        UInt8(ascii: "1"), UInt8(ascii: "2"), UInt8(ascii: "3"),
        UInt8(ascii: "4"), UInt8(ascii: "5"), UInt8(ascii: "6"), UInt8(ascii: "7"), UInt8(ascii: "8"), UInt8(ascii: "9"), UInt8(ascii: "-"),
        UInt8(ascii: "_"), UInt8(ascii: "A"), UInt8(ascii: "B"),
        UInt8(ascii: "C"), UInt8(ascii: "D"), UInt8(ascii: "E"), UInt8(ascii: "F"), UInt8(ascii: "G"), UInt8(ascii: "H"), UInt8(ascii: "I"),
        UInt8(ascii: "J"), UInt8(ascii: "K"), UInt8(ascii: "L"),
        UInt8(ascii: "M"), UInt8(ascii: "N"), UInt8(ascii: "O"), UInt8(ascii: "P"), UInt8(ascii: "Q"), UInt8(ascii: "R"), UInt8(ascii: "S"),
        UInt8(ascii: "T"), UInt8(ascii: "U"), UInt8(ascii: "V"),
        UInt8(ascii: "W"), UInt8(ascii: "X"), UInt8(ascii: "Y"), UInt8(ascii: "Z"), UInt8(ascii: "a"), UInt8(ascii: "b"), UInt8(ascii: "c"),
        UInt8(ascii: "d"), UInt8(ascii: "e"), UInt8(ascii: "f"),
        UInt8(ascii: "g"), UInt8(ascii: "h"), UInt8(ascii: "i"), UInt8(ascii: "j"), UInt8(ascii: "k"), UInt8(ascii: "l"), UInt8(ascii: "m"),
        UInt8(ascii: "n"), UInt8(ascii: "o"), UInt8(ascii: "p"),
        UInt8(ascii: "q"), UInt8(ascii: "r"), UInt8(ascii: "s"), UInt8(ascii: "t"), UInt8(ascii: "u"), UInt8(ascii: "v"), UInt8(ascii: "w"),
        UInt8(ascii: "x"), UInt8(ascii: "y"), UInt8(ascii: "z"),
        UInt8(ascii: "0"), UInt8(ascii: "1"), UInt8(ascii: "2"), UInt8(ascii: "3"), UInt8(ascii: "4"), UInt8(ascii: "5"), UInt8(ascii: "6"),
        UInt8(ascii: "7"), UInt8(ascii: "8"), UInt8(ascii: "9"),
        UInt8(ascii: "-"), UInt8(ascii: "_"), UInt8(ascii: "A"), UInt8(ascii: "B"), UInt8(ascii: "C"), UInt8(ascii: "D"), UInt8(ascii: "E"),
        UInt8(ascii: "F"), UInt8(ascii: "G"), UInt8(ascii: "H"),
        UInt8(ascii: "I"), UInt8(ascii: "J"), UInt8(ascii: "K"), UInt8(ascii: "L"), UInt8(ascii: "M"), UInt8(ascii: "N"), UInt8(ascii: "O"),
        UInt8(ascii: "P"), UInt8(ascii: "Q"), UInt8(ascii: "R"),
        UInt8(ascii: "S"), UInt8(ascii: "T"), UInt8(ascii: "U"), UInt8(ascii: "V"), UInt8(ascii: "W"), UInt8(ascii: "X"), UInt8(ascii: "Y"),
        UInt8(ascii: "Z"), UInt8(ascii: "a"), UInt8(ascii: "b"),
        UInt8(ascii: "c"), UInt8(ascii: "d"), UInt8(ascii: "e"), UInt8(ascii: "f"), UInt8(ascii: "g"), UInt8(ascii: "h"), UInt8(ascii: "i"),
        UInt8(ascii: "j"), UInt8(ascii: "k"), UInt8(ascii: "l"),
        UInt8(ascii: "m"), UInt8(ascii: "n"), UInt8(ascii: "o"), UInt8(ascii: "p"), UInt8(ascii: "q"), UInt8(ascii: "r"), UInt8(ascii: "s"),
        UInt8(ascii: "t"), UInt8(ascii: "u"), UInt8(ascii: "v"),
        UInt8(ascii: "w"), UInt8(ascii: "x"), UInt8(ascii: "y"), UInt8(ascii: "z"), UInt8(ascii: "0"), UInt8(ascii: "1"), UInt8(ascii: "2"),
        UInt8(ascii: "3"), UInt8(ascii: "4"), UInt8(ascii: "5"),
        UInt8(ascii: "6"), UInt8(ascii: "7"), UInt8(ascii: "8"), UInt8(ascii: "9"), UInt8(ascii: "-"), UInt8(ascii: "_"),
    ]

    @usableFromInline
    static let badCharacter: UInt32 = 0x01FF_FFFF

    @usableFromInline
    static let decoding0: [UInt32] = [
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x0000_00F8, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x0000_00FC,
        0x0000_00D0, 0x0000_00D4, 0x0000_00D8, 0x0000_00DC, 0x0000_00E0, 0x0000_00E4,
        0x0000_00E8, 0x0000_00EC, 0x0000_00F0, 0x0000_00F4, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x0000_0000,
        0x0000_0004, 0x0000_0008, 0x0000_000C, 0x0000_0010, 0x0000_0014, 0x0000_0018,
        0x0000_001C, 0x0000_0020, 0x0000_0024, 0x0000_0028, 0x0000_002C, 0x0000_0030,
        0x0000_0034, 0x0000_0038, 0x0000_003C, 0x0000_0040, 0x0000_0044, 0x0000_0048,
        0x0000_004C, 0x0000_0050, 0x0000_0054, 0x0000_0058, 0x0000_005C, 0x0000_0060,
        0x0000_0064, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x0000_0068, 0x0000_006C, 0x0000_0070, 0x0000_0074, 0x0000_0078,
        0x0000_007C, 0x0000_0080, 0x0000_0084, 0x0000_0088, 0x0000_008C, 0x0000_0090,
        0x0000_0094, 0x0000_0098, 0x0000_009C, 0x0000_00A0, 0x0000_00A4, 0x0000_00A8,
        0x0000_00AC, 0x0000_00B0, 0x0000_00B4, 0x0000_00B8, 0x0000_00BC, 0x0000_00C0,
        0x0000_00C4, 0x0000_00C8, 0x0000_00CC, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
    ]

    @usableFromInline
    static let decoding1: [UInt32] = [
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x0000_E003, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x0000_F003,
        0x0000_4003, 0x0000_5003, 0x0000_6003, 0x0000_7003, 0x0000_8003, 0x0000_9003,
        0x0000_A003, 0x0000_B003, 0x0000_C003, 0x0000_D003, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x0000_0000,
        0x0000_1000, 0x0000_2000, 0x0000_3000, 0x0000_4000, 0x0000_5000, 0x0000_6000,
        0x0000_7000, 0x0000_8000, 0x0000_9000, 0x0000_A000, 0x0000_B000, 0x0000_C000,
        0x0000_D000, 0x0000_E000, 0x0000_F000, 0x0000_0001, 0x0000_1001, 0x0000_2001,
        0x0000_3001, 0x0000_4001, 0x0000_5001, 0x0000_6001, 0x0000_7001, 0x0000_8001,
        0x0000_9001, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x0000_A001, 0x0000_B001, 0x0000_C001, 0x0000_D001, 0x0000_E001,
        0x0000_F001, 0x0000_0002, 0x0000_1002, 0x0000_2002, 0x0000_3002, 0x0000_4002,
        0x0000_5002, 0x0000_6002, 0x0000_7002, 0x0000_8002, 0x0000_9002, 0x0000_A002,
        0x0000_B002, 0x0000_C002, 0x0000_D002, 0x0000_E002, 0x0000_F002, 0x0000_0003,
        0x0000_1003, 0x0000_2003, 0x0000_3003, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
    ]

    @usableFromInline
    static let decoding2: [UInt32] = [
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x0080_0F00, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x00C0_0F00,
        0x0000_0D00, 0x0040_0D00, 0x0080_0D00, 0x00C0_0D00, 0x0000_0E00, 0x0040_0E00,
        0x0080_0E00, 0x00C0_0E00, 0x0000_0F00, 0x0040_0F00, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x0000_0000,
        0x0040_0000, 0x0080_0000, 0x00C0_0000, 0x0000_0100, 0x0040_0100, 0x0080_0100,
        0x00C0_0100, 0x0000_0200, 0x0040_0200, 0x0080_0200, 0x00C0_0200, 0x0000_0300,
        0x0040_0300, 0x0080_0300, 0x00C0_0300, 0x0000_0400, 0x0040_0400, 0x0080_0400,
        0x00C0_0400, 0x0000_0500, 0x0040_0500, 0x0080_0500, 0x00C0_0500, 0x0000_0600,
        0x0040_0600, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x0080_0600, 0x00C0_0600, 0x0000_0700, 0x0040_0700, 0x0080_0700,
        0x00C0_0700, 0x0000_0800, 0x0040_0800, 0x0080_0800, 0x00C0_0800, 0x0000_0900,
        0x0040_0900, 0x0080_0900, 0x00C0_0900, 0x0000_0A00, 0x0040_0A00, 0x0080_0A00,
        0x00C0_0A00, 0x0000_0B00, 0x0040_0B00, 0x0080_0B00, 0x00C0_0B00, 0x0000_0C00,
        0x0040_0C00, 0x0080_0C00, 0x00C0_0C00, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
    ]

    @usableFromInline
    static let decoding3: [UInt32] = [
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x003E_0000, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x003F_0000,
        0x0034_0000, 0x0035_0000, 0x0036_0000, 0x0037_0000, 0x0038_0000, 0x0039_0000,
        0x003A_0000, 0x003B_0000, 0x003C_0000, 0x003D_0000, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x0000_0000,
        0x0001_0000, 0x0002_0000, 0x0003_0000, 0x0004_0000, 0x0005_0000, 0x0006_0000,
        0x0007_0000, 0x0008_0000, 0x0009_0000, 0x000A_0000, 0x000B_0000, 0x000C_0000,
        0x000D_0000, 0x000E_0000, 0x000F_0000, 0x0010_0000, 0x0011_0000, 0x0012_0000,
        0x0013_0000, 0x0014_0000, 0x0015_0000, 0x0016_0000, 0x0017_0000, 0x0018_0000,
        0x0019_0000, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x001A_0000, 0x001B_0000, 0x001C_0000, 0x001D_0000, 0x001E_0000,
        0x001F_0000, 0x0020_0000, 0x0021_0000, 0x0022_0000, 0x0023_0000, 0x0024_0000,
        0x0025_0000, 0x0026_0000, 0x0027_0000, 0x0028_0000, 0x0029_0000, 0x002A_0000,
        0x002B_0000, 0x002C_0000, 0x002D_0000, 0x002E_0000, 0x002F_0000, 0x0030_0000,
        0x0031_0000, 0x0032_0000, 0x0033_0000, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
    ]

    @usableFromInline
    static let decoding0url: [UInt32] = [
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 0
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 6
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 12
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 18
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 24
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 30
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 36
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x0000_00F8, 0x01FF_FFFF, 0x01FF_FFFF,  // 42
        0x0000_00D0, 0x0000_00D4, 0x0000_00D8, 0x0000_00DC, 0x0000_00E0, 0x0000_00E4,  // 48
        0x0000_00E8, 0x0000_00EC, 0x0000_00F0, 0x0000_00F4, 0x01FF_FFFF, 0x01FF_FFFF,  // 54
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x0000_0000,  // 60
        0x0000_0004, 0x0000_0008, 0x0000_000C, 0x0000_0010, 0x0000_0014, 0x0000_0018,  // 66
        0x0000_001C, 0x0000_0020, 0x0000_0024, 0x0000_0028, 0x0000_002C, 0x0000_0030,  // 72
        0x0000_0034, 0x0000_0038, 0x0000_003C, 0x0000_0040, 0x0000_0044, 0x0000_0048,  // 78
        0x0000_004C, 0x0000_0050, 0x0000_0054, 0x0000_0058, 0x0000_005C, 0x0000_0060,  // 84
        0x0000_0064, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x0000_00FC,  // 90
        0x01FF_FFFF, 0x0000_0068, 0x0000_006C, 0x0000_0070, 0x0000_0074, 0x0000_0078,
        0x0000_007C, 0x0000_0080, 0x0000_0084, 0x0000_0088, 0x0000_008C, 0x0000_0090,
        0x0000_0094, 0x0000_0098, 0x0000_009C, 0x0000_00A0, 0x0000_00A4, 0x0000_00A8,
        0x0000_00AC, 0x0000_00B0, 0x0000_00B4, 0x0000_00B8, 0x0000_00BC, 0x0000_00C0,
        0x0000_00C4, 0x0000_00C8, 0x0000_00CC, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
    ]

    @usableFromInline
    static let decoding1url: [UInt32] = [
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 0
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 6
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 12
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 18
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 24
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 30
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 36
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x0000_E003, 0x01FF_FFFF, 0x01FF_FFFF,  // 42
        0x0000_4003, 0x0000_5003, 0x0000_6003, 0x0000_7003, 0x0000_8003, 0x0000_9003,  // 48
        0x0000_A003, 0x0000_B003, 0x0000_C003, 0x0000_D003, 0x01FF_FFFF, 0x01FF_FFFF,  // 54
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x0000_0000,  // 60
        0x0000_1000, 0x0000_2000, 0x0000_3000, 0x0000_4000, 0x0000_5000, 0x0000_6000,  // 66
        0x0000_7000, 0x0000_8000, 0x0000_9000, 0x0000_A000, 0x0000_B000, 0x0000_C000,  // 72
        0x0000_D000, 0x0000_E000, 0x0000_F000, 0x0000_0001, 0x0000_1001, 0x0000_2001,  // 78
        0x0000_3001, 0x0000_4001, 0x0000_5001, 0x0000_6001, 0x0000_7001, 0x0000_8001,  // 84
        0x0000_9001, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x0000_F003,  // 90
        0x01FF_FFFF, 0x0000_A001, 0x0000_B001, 0x0000_C001, 0x0000_D001, 0x0000_E001,
        0x0000_F001, 0x0000_0002, 0x0000_1002, 0x0000_2002, 0x0000_3002, 0x0000_4002,
        0x0000_5002, 0x0000_6002, 0x0000_7002, 0x0000_8002, 0x0000_9002, 0x0000_A002,
        0x0000_B002, 0x0000_C002, 0x0000_D002, 0x0000_E002, 0x0000_F002, 0x0000_0003,
        0x0000_1003, 0x0000_2003, 0x0000_3003, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
    ]

    @usableFromInline
    static let decoding2url: [UInt32] = [
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 0
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 6
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 12
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 18
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 24
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 30
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 36
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x0080_0F00, 0x01FF_FFFF, 0x01FF_FFFF,  // 42
        0x0000_0D00, 0x0040_0D00, 0x0080_0D00, 0x00C0_0D00, 0x0000_0E00, 0x0040_0E00,  // 48
        0x0080_0E00, 0x00C0_0E00, 0x0000_0F00, 0x0040_0F00, 0x01FF_FFFF, 0x01FF_FFFF,  // 54
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x0000_0000,  // 60
        0x0040_0000, 0x0080_0000, 0x00C0_0000, 0x0000_0100, 0x0040_0100, 0x0080_0100,  // 66
        0x00C0_0100, 0x0000_0200, 0x0040_0200, 0x0080_0200, 0x00C0_0200, 0x0000_0300,  // 72
        0x0040_0300, 0x0080_0300, 0x00C0_0300, 0x0000_0400, 0x0040_0400, 0x0080_0400,  // 78
        0x00C0_0400, 0x0000_0500, 0x0040_0500, 0x0080_0500, 0x00C0_0500, 0x0000_0600,  // 84
        0x0040_0600, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x00C0_0F00,  // 90
        0x01FF_FFFF, 0x0080_0600, 0x00C0_0600, 0x0000_0700, 0x0040_0700, 0x0080_0700,
        0x00C0_0700, 0x0000_0800, 0x0040_0800, 0x0080_0800, 0x00C0_0800, 0x0000_0900,
        0x0040_0900, 0x0080_0900, 0x00C0_0900, 0x0000_0A00, 0x0040_0A00, 0x0080_0A00,
        0x00C0_0A00, 0x0000_0B00, 0x0040_0B00, 0x0080_0B00, 0x00C0_0B00, 0x0000_0C00,
        0x0040_0C00, 0x0080_0C00, 0x00C0_0C00, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
    ]

    @usableFromInline
    static let decoding3url: [UInt32] = [
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 0
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 6
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 12
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 18
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 24
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 30
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,  // 36
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x003E_0000, 0x01FF_FFFF, 0x01FF_FFFF,  // 42
        0x0034_0000, 0x0035_0000, 0x0036_0000, 0x0037_0000, 0x0038_0000, 0x0039_0000,  // 48
        0x003A_0000, 0x003B_0000, 0x003C_0000, 0x003D_0000, 0x01FF_FFFF, 0x01FF_FFFF,  // 54
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x0000_0000,  // 60
        0x0001_0000, 0x0002_0000, 0x0003_0000, 0x0004_0000, 0x0005_0000, 0x0006_0000,  // 66
        0x0007_0000, 0x0008_0000, 0x0009_0000, 0x000A_0000, 0x000B_0000, 0x000C_0000,  // 72
        0x000D_0000, 0x000E_0000, 0x000F_0000, 0x0010_0000, 0x0011_0000, 0x0012_0000,  // 78
        0x0013_0000, 0x0014_0000, 0x0015_0000, 0x0016_0000, 0x0017_0000, 0x0018_0000,  // 84
        0x0019_0000, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x003F_0000,  // 90
        0x01FF_FFFF, 0x001A_0000, 0x001B_0000, 0x001C_0000, 0x001D_0000, 0x001E_0000,
        0x001F_0000, 0x0020_0000, 0x0021_0000, 0x0022_0000, 0x0023_0000, 0x0024_0000,
        0x0025_0000, 0x0026_0000, 0x0027_0000, 0x0028_0000, 0x0029_0000, 0x002A_0000,
        0x002B_0000, 0x002C_0000, 0x002D_0000, 0x002E_0000, 0x002F_0000, 0x0030_0000,
        0x0031_0000, 0x0032_0000, 0x0033_0000, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
        0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF, 0x01FF_FFFF,
    ]
}
