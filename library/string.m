%---------------------------------------------------------------------------%
% Copyright (C) 1993-2005 The University of Melbourne.
% This file may only be copied under the terms of the GNU Library General
% Public License - see the file COPYING.LIB in the Mercury distribution.
%---------------------------------------------------------------------------%

% Main authors: fjh, petdr.
% Stability: medium to high.

% This modules provides basic string handling facilities.

% Note that in the current implementation, strings are represented as in C,
% using a null character as the string terminator. Future implementations,
% however, might allow null characters in strings. Programmers should
% avoid creating strings that might contain null characters.

%-----------------------------------------------------------------------------%

:- module string.

:- interface.
:- import_module list, char.
:- import_module deconstruct.
:- import_module ops.

	% Determine the length of a string.
	% An empty string has length zero.
	%
:- func string__length(string) = int.
:- mode string__length(in) = uo is det.
:- pred string__length(string, int).
:- mode string__length(in, uo) is det.
:- mode string__length(ui, uo) is det.

	% Append two strings together.
	%
:- func string__append(string, string) = string.
:- mode string__append(in, in) = uo is det.

:- pred string__append(string, string, string).
:- mode string__append(in, in, in) is semidet.	% implied
:- mode string__append(in, uo, in) is semidet.
:- mode string__append(in, in, uo) is det.
:- mode string__append(out, out, in) is multi.
% The following mode is semidet in the sense that it doesn't succeed more
% than once - but it does create a choice-point, which means it's inefficient
% and that the compiler can't deduce that it is semidet.
% Use string__remove_suffix instead.
% :- mode string__append(out, in, in) is semidet.

	% S1 ++ S2 = S :- string__append(S1, S2, S).
	%
	% Nicer syntax.
:- func string ++ string = string.
:- mode in ++ in = uo is det.

	% string__remove_suffix(String, Suffix, Prefix):
	% The same as string__append(Prefix, Suffix, String) except that
	% this is semidet whereas string__append(out, in, in) is nondet.
	%
:- pred string__remove_suffix(string::in, string::in, string::out) is semidet.

	% string__prefix(String, Prefix) is true iff Prefix is a
	% prefix of String. Same as string__append(Prefix, _, String).
	%
:- pred string__prefix(string, string).
:- mode string__prefix(in, in) is semidet.
:- mode string__prefix(in, out) is multi.

	% string__suffix(String, Suffix) is true iff Suffix is a
	% suffix of String. Same as string__append(_, Suffix, String).
	%
:- pred string__suffix(string, string).
:- mode string__suffix(in, in) is semidet.
:- mode string__suffix(in, out) is multi.

	% string__string(X): Returns a canonicalized string
	% representation of the value X using the standard Mercury operators.
	%
:- func string__string(T) = string.

	% As above, but using the supplied table of operators.
	%
:- func string__string(ops__table, T) = string.

	% string__string(NonCanon, OpsTable, X, String)
	%
	% As above, but the caller specifies what behaviour should
	% occur for non-canonical terms (i.e. terms where multiple
	% representations may compare as equal):
	%	- `do_not_allow' will throw an exception if (any subterm of)
	%	   the argument is not canonical;
	%	- `canonicalize' will substitute a string indicating the
	%	   presence of a non-canonical subterm;
	%	- `include_details_cc' will show the structure of any
	%	   non-canonical subterms, but can only be called from a
	%	   committed choice context.
	%
:- pred string__string(deconstruct__noncanon_handling, ops__table, T, string).
:- mode string__string(in(do_not_allow), in, in, out) is det.
:- mode string__string(in(canonicalize), in, in, out) is det.
:- mode string__string(in(include_details_cc), in, in, out) is cc_multi.
:- mode string__string(in, in, in, out) is cc_multi.
	
	% string__char_to_string(Char, String).
	% Converts a character (single-character atom) to a string
	% or vice versa.
	%
:- func string__char_to_string(char) = string.
:- mode string__char_to_string(in) = uo is det.
:- pred string__char_to_string(char, string).
:- mode string__char_to_string(in, uo) is det.
:- mode string__char_to_string(out, in) is semidet.

	% A synonym for string.char_to_string/1.
	%
:- func string__from_char(char::in) = (string::uo) is det.

	% Convert an integer to a string.
	%
:- func string__int_to_string(int) = string.
:- mode string__int_to_string(in) = uo is det.
:- pred string__int_to_string(int, string).
:- mode string__int_to_string(in, uo) is det.

	% A synonym for string.int_to_string/1.
	%
:- func string__from_int(int::in) = (string::uo) is det.

	% string__int_to_base_string(Int, Base, String):
	% Convert an integer to a string in a given Base (between 2 and 36).
	%
:- func string__int_to_base_string(int, int) = string.
:- mode string__int_to_base_string(in, in) = uo is det.
:- pred string__int_to_base_string(int, int, string).
:- mode string__int_to_base_string(in, in, uo) is det.

	% Convert a float to a string.
	% In the current implementation the resulting float will be in the
	% form that it was printed using the format string "%#.<prec>g".
	% <prec> will be in the range p to (p+2)
	% where p = floor(mantissa_digits * log2(base_radix) / log2(10)).
	% The precision chosen from this range will be such to allow a
	% successful decimal -> binary conversion of the float.
	%
:- func string__float_to_string(float) = string.
:- mode string__float_to_string(in) = uo is det.
:- pred string__float_to_string(float, string).
:- mode string__float_to_string(in, uo) is det.

	% A synonym for string.float_to_string/1.
	%
:- func string__from_float(float::in) = (string::uo) is det.

	% string__first_char(String, Char, Rest) is true iff Char is
	% the first character of String, and Rest is the remainder.
	%
	% WARNING: string__first_char makes a copy of Rest because the
	% garbage collector doesn't handle references into the middle
	% of an object, at least not the way we use it.
	% Repeated use of string__first_char to iterate
	% over a string will result in very poor performance.
	% Use string__foldl or string__to_char_list instead.
	%
:- pred string__first_char(string, char, string).
:- mode string__first_char(in, in, in) is semidet.	% implied
:- mode string__first_char(in, uo, in) is semidet.	% implied
:- mode string__first_char(in, in, uo) is semidet.	% implied
:- mode string__first_char(in, uo, uo) is semidet.
:- mode string__first_char(uo, in, in) is det.

	% string__replace(String0, Search, Replace, String):
	% string__replace replaces the first occurrence of Search in String0
	% with Replace to give String. It fails if Search does not occur
	% in String0.
	% 
:- pred string__replace(string::in, string::in, string::in, string::uo)
	is semidet.

	% string__replace_all(String0, Search, Replace, String):
	% string__replace_all replaces any occurrences of Search in
	% String0 with Replace to give String.
	%
:- func string__replace_all(string, string, string) = string.
:- mode string__replace_all(in, in, in) = uo is det.
:- pred string__replace_all(string, string, string, string).
:- mode string__replace_all(in, in, in, uo) is det.

	% Converts a string to lowercase.
	% 
:- func string__to_lower(string) = string.
:- mode string__to_lower(in) = uo is det.
:- pred string__to_lower(string, string).
:- mode string__to_lower(in, uo) is det.
:- mode string__to_lower(in, in) is semidet.		% implied

	% Converts a string to uppercase.
	% 
:- func string__to_upper(string) = string.
:- mode string__to_upper(in) = uo is det.
:- pred string__to_upper(string, string).
:- mode string__to_upper(in, uo) is det.
:- mode string__to_upper(in, in) is semidet.		% implied

	% Convert the first character (if any) of a string to uppercase.
	%
:- func string__capitalize_first(string) = string.
:- pred string__capitalize_first(string::in, string::out) is det.

	% Convert the first character (if any) of a string to lowercase.
	%
:- func string__uncapitalize_first(string) = string.
:- pred string__uncapitalize_first(string::in, string::out) is det.

	% Convert the string to a list of characters.
	%
:- func string__to_char_list(string) = list(char).
:- pred string__to_char_list(string, list(char)).
:- mode string__to_char_list(in, out) is det.
:- mode string__to_char_list(uo, in) is det.

	% Convert a list of characters to a string.
	%
:- func string__from_char_list(list(char)) = string.
:- mode string__from_char_list(in) = uo is det.
:- pred string__from_char_list(list(char), string).
:- mode string__from_char_list(in, uo) is det.
:- mode string__from_char_list(out, in) is det.

	% Same as string__from_char_list, except that it reverses the order
	% of the characters.
	%
:- func string__from_rev_char_list(list(char)) = string.
:- mode string__from_rev_char_list(in) = uo is det.
:- pred string__from_rev_char_list(list(char), string).
:- mode string__from_rev_char_list(in, uo) is det.

	% Converts a signed base 10 string to an int; throws an exception
	% if the string argument does not match the regexp [+-]?[0-9]+
	%
:- func string__det_to_int(string) = int.

	% Convert a string to an int. The string must contain only digits,
	% optionally preceded by a plus or minus sign. If the string does
	% not match this syntax, string__to_int fails.
:- pred string__to_int(string::in, int::out) is semidet.

	% Convert a string in the specified base (2-36) to an int. The
	% string must contain one or more digits in the specified base,
	% optionally preceded by a plus or minus sign. For bases > 10,
	% digits 10 to 35 are represented by the letters A-Z or a-z. If
	% the string does not match this syntax, the predicate fails.
	%
:- pred string__base_string_to_int(int::in, string::in, int::out) is semidet.

	% Converts a signed base N string to an int; throws an exception
	% if the string argument is not precisely an optional sign followed
	% by a non-empty string of base N digits.
	%
:- func string__det_base_string_to_int(int, string) = int.

	% Convert a string to a float.  Throws an exception if the string
	% is not a syntactically correct float literal.
	%
:- func string__det_to_float(string) = float.

	% Convert a string to a float. If the string is not a syntactically
	% correct float literal, string__to_float fails.
	%
:- pred string__to_float(string::in, float::out) is semidet.

	% True if string contains only alphabetic characters (letters).
	%
:- pred string__is_alpha(string::in) is semidet.

	% True if string contains only alphabetic characters and underscores.
	%
:- pred string__is_alpha_or_underscore(string::in) is semidet.

	% True if string contains only letters, digits, and underscores.
	%
:- pred string__is_alnum_or_underscore(string::in) is semidet.

	% string__pad_left(String0, PadChar, Width, String):
	% Insert `PadChar's at the left of `String0' until it is at least
	% as long as `Width', giving `String'.
	%
:- func string__pad_left(string, char, int) = string.
:- pred string__pad_left(string::in, char::in, int::in, string::out) is det.

	% string__pad_right(String0, PadChar, Width, String):
	% Insert `PadChar's at the right of `String0' until it is at least
	% as long as `Width', giving `String'.
	%
:- func string__pad_right(string, char, int) = string.
:- pred string__pad_right(string::in, char::in, int::in, string::out) is det.

	% string__duplicate_char(Char, Count, String):
	% Construct a string consisting of `Count' occurrences of `Char'
	% in sequence.
	%
:- func string__duplicate_char(char::in, int::in) = (string::uo) is det.
:- pred string__duplicate_char(char::in, int::in, string::uo) is det.

	% string__contains_char(String, Char):
	% Succeed if `Char' occurs in `String'.
	%
:- pred string__contains_char(string::in, char::in) is semidet.

	% string__index(String, Index, Char):
	% `Char' is the (`Index' + 1)-th character of `String'.
	% Fails if `Index' is out of range (negative, or greater than or
	% equal to the length of `String').
	%
:- pred string__index(string::in, int::in, char::uo) is semidet.

	% string__index_det(String, Index, Char):
	% `Char' is the (`Index' + 1)-th character of `String'.
	% Calls error/1 if `Index' is out of range (negative, or greater than
	% or equal to the length of `String').
	%
:- func string__index_det(string, int) = char.
:- pred string__index_det(string::in, int::in, char::uo) is det.

	% A synonym for index_det/2:
	% String ^ elem(Index) = string__index_det(String, Index).
	%
:- func string ^ elem(int) = char.

	% string__unsafe_index(String, Index, Char):
	% `Char' is the (`Index' + 1)-th character of `String'.
	% WARNING: behavior is UNDEFINED if `Index' is out of range
	% (negative, or greater than or equal to the length of `String').
	% This version is constant time, whereas string__index_det
	% may be linear in the length of the string.
	% Use with care!
	%
:- func string__unsafe_index(string, int) = char.
:- pred string__unsafe_index(string::in, int::in, char::uo) is det.

	% A synonym for unsafe_index/2:
	% String ^ unsafe_elem(Index) = string__unsafe_index(String, Index).
	%
:- func string ^ unsafe_elem(int) = char.

	% string__chomp(String):
	% `String' minus any single trailing newline character.
	%
:- func string__chomp(string) = string.

	% string__lstrip(String):
	% `String' minus any initial whitespace characters.
	%
:- func string__lstrip(string) = string.

	% string__rstrip(String):
	% `String' minus any trailing whitespace characters.
	%
:- func string__rstrip(string) = string.

	% string__strip(String):
	% `String' minus any initial and trailing whitespace characters.
	%
:- func string__strip(string) = string.

	% string__lstrip(Pred, String):
	% `String' minus the maximal prefix consisting entirely of
	% chars satisfying `Pred'.
	%
:- func string__lstrip(pred(char)::in(pred(in) is semidet), string::in)
	= (string::out) is det.

	% string__rstrip(Pred, String):
	% `String' minus the maximal suffix consisting entirely of
	% chars satisfying `Pred'.
	%
:- func string__rstrip(pred(char)::in(pred(in) is semidet), string::in)
	= (string::out) is det.

	% string__prefix_length(Pred, String):
	% The length of the maximal prefix of `String' consisting entirely of
	% chars satisfying Pred.
	%
:- func string__prefix_length(pred(char)::in(pred(in) is semidet), string::in)
	= (int::out) is det.

	% string__suffix_length(Pred, String):
	% The length of the maximal suffix of `String' consisting entirely of
	% chars satisfying Pred.
	%
:- func suffix_length(pred(char)::in(pred(in) is semidet), string::in)
	= (int::out) is det.

	% string__set_char(Char, Index, String0, String):
	% `String' is `String0' with the (`Index' + 1)-th character
	% set to `Char'.
	% Fails if `Index' is out of range (negative, or greater than or
	% equal to the length of `String0').
	%
:- pred string__set_char(char, int, string, string).
:- mode string__set_char(in, in, in, out) is semidet.
% XXX This mode is disabled because the compiler puts constant
% strings into static data even when they might be updated.
%:- mode string__set_char(in, in, di, uo) is semidet.

	% string__set_char_det(Char, Index, String0, String):
	% `String' is `String0' with the (`Index' + 1)-th character
	% set to `Char'.
	% Calls error/1 if `Index' is out of range (negative, or greater than
	% or equal to the length of `String0').
	%
:- func string__set_char_det(char, int, string) = string.
:- pred string__set_char_det(char, int, string, string).
:- mode string__set_char_det(in, in, in, out) is det.
% XXX This mode is disabled because the compiler puts constant
% strings into static data even when they might be updated.
%:- mode string__set_char_det(in, in, di, uo) is det.

	% string__unsafe_set_char(Char, Index, String0, String):
	% `String' is `String0' with the (`Index' + 1)-th character
	% set to `Char'.
	% WARNING: behavior is UNDEFINED if `Index' is out of range
	% (negative, or greater than or equal to the length of `String0').
	% This version is constant time, whereas string__set_char_det
	% may be linear in the length of the string.
	% Use with care!
	%
:- func string__unsafe_set_char(char, int, string) = string.
:- mode string__unsafe_set_char(in, in, in) = out is det.
% XXX This mode is disabled because the compiler puts constant
% strings into static data even when they might be updated.
%:- mode string__unsafe_set_char(in, in, di) = uo is det.
:- pred string__unsafe_set_char(char, int, string, string).
:- mode string__unsafe_set_char(in, in, in, out) is det.
% XXX This mode is disabled because the compiler puts constant
% strings into static data even when they might be updated.
%:- mode string__unsafe_set_char(in, in, di, uo) is det.

	% string__foldl(Closure, String, Acc0, Acc):
	% `Closure' is an accumulator predicate which is to be called for each
	% character of the string `String' in turn. The initial value of the
	% accumulator is `Acc0' and the final value is `Acc'.
	% (string__foldl is equivalent to
	% 	string__to_char_list(String, Chars),
	% 	list__foldl(Closure, Chars, Acc0, Acc)
	% but is implemented more efficiently.)
	%
:- func string__foldl(func(char, T) = T, string, T) = T.
:- pred string__foldl(pred(char, T, T), string, T, T).
:- mode string__foldl(pred(in, in, out) is det, in, in, out) is det.
:- mode string__foldl(pred(in, di, uo) is det, in, di, uo) is det.
:- mode string__foldl(pred(in, in, out) is semidet, in, in, out) is semidet.
:- mode string__foldl(pred(in, in, out) is nondet, in, in, out) is nondet.
:- mode string__foldl(pred(in, in, out) is multi, in, in, out) is multi.

	% string__foldl_substring(Closure, String, Start, Count, !Acc)
	% is equivalent to string__foldl(Closure, SubString, !Acc)
	% where SubString = string__substring(String, Start, Count).
	%
:- func string__foldl_substring(func(char, T) = T, string, int, int, T) = T.
:- pred string__foldl_substring(pred(char, T, T), string, int, int, T, T).
:- mode string__foldl_substring(pred(in, in, out) is det, in, in, in,
	in, out) is det.
:- mode string__foldl_substring(pred(in, di, uo) is det, in, in, in,
	di, uo) is det.
:- mode string__foldl_substring(pred(in, in, out) is semidet, in, in, in,
	in, out) is semidet.
:- mode string__foldl_substring(pred(in, in, out) is nondet, in, in, in,
	in, out) is nondet.
:- mode string__foldl_substring(pred(in, in, out) is multi, in, in, in,
	in, out) is multi.

	% string__foldr(Closure, String, !Acc):
	% As string__foldl/4, except that processing proceeds right-to-left.
	%
:- func string__foldr(func(char, T) = T, string, T) = T.
:- pred string__foldr(pred(char, T, T), string, T, T).
:- mode string__foldr(pred(in, in, out) is det, in, in, out) is det.
:- mode string__foldr(pred(in, di, uo) is det, in, di, uo) is det.
:- mode string__foldr(pred(in, in, out) is semidet, in, in, out) is semidet.
:- mode string__foldr(pred(in, in, out) is nondet, in, in, out) is nondet.
:- mode string__foldr(pred(in, in, out) is multi, in, in, out) is multi.

	% string__foldr_substring(Closure, String, Start, Count, !Acc)
	% is equivalent to string__foldr(Closure, SubString, !Acc)
	% where SubString = string__substring(String, Start, Count).
	%
:- func string__foldr_substring(func(char, T) = T, string, int, int, T) = T.
:- pred string__foldr_substring(pred(char, T, T), string, int, int, T, T).
:- mode string__foldr_substring(pred(in, in, out) is det, in, in, in,
	in, out) is det.
:- mode string__foldr_substring(pred(in, di, uo) is det, in, in, in,
	di, uo) is det.
:- mode string__foldr_substring(pred(in, in, out) is semidet, in, in, in,
	in, out) is semidet.
:- mode string__foldr_substring(pred(in, in, out) is nondet, in, in, in,
	in, out) is nondet.
:- mode string__foldr_substring(pred(in, in, out) is multi, in, in, in,
	in, out) is multi.

	% string__words(SepP, String) returns the list of non-empty substrings
	% of String (in first to last order) that are delimited by non-empty
	% sequences of chars matched by SepP. For example,
	%
	% string__words(char__is_whitespace, " the cat  sat on the  mat") =
	% 	["the", "cat", "sat", "on", "the", "mat"]
	%
:- func string__words(pred(char), string) = list(string).
:- mode string__words(pred(in) is semidet, in) = out is det.

	% string__words(String) = string__words(char__is_whitespace, String).
:- func string__words(string) = list(string).

	% string__split(String, Count, LeftSubstring, RightSubstring):
	% `LeftSubstring' is the left-most `Count' characters of `String',
	% and `RightSubstring' is the remainder of `String'.
	% (If `Count' is out of the range [0, length of `String'], it is
	% treated as if it were the nearest end-point of that range.)
	%
:- pred string__split(string::in, int::in, string::uo, string::uo) is det.

	% string__left(String, Count, LeftSubstring):
	% `LeftSubstring' is the left-most `Count' characters of `String'.
	% (If `Count' is out of the range [0, length of `String'], it is
	% treated as if it were the nearest end-point of that range.)
	%
:- func string__left(string::in, int::in) = (string::uo) is det.
:- pred string__left(string::in, int::in, string::uo) is det.

	% string__right(String, Count, RightSubstring):
	% `RightSubstring' is the right-most `Count' characters of `String'.
	% (If `Count' is out of the range [0, length of `String'], it is
	% treated as if it were the nearest end-point of that range.)
	%
:- func string__right(string::in, int::in) = (string::uo) is det.
:- pred string__right(string::in, int::in, string::uo) is det.

	% string__substring(String, Start, Count, Substring):
	% `Substring' is first the `Count' characters in what would
	% remain of `String' after the first `Start' characters were
	% removed.
	% (If `Start' is out of the range [0, length of `String'], it is
	% treated as if it were the nearest end-point of that range.
	% If `Count' is out of the range [0, length of `String' - `Start'],
	% it is treated as if it were the nearest end-point of that range.)
	%
:- func string__substring(string, int, int) = string.
:- mode string__substring(in, in, in) = uo is det.
:- pred string__substring(string, int, int, string).
:- mode string__substring(in, in, in, uo) is det.

	% string__unsafe_substring(String, Start, Count, Substring):
	% `Substring' is first the `Count' characters in what would
	% remain of `String' after the first `Start' characters were
	% removed.
	% WARNING: if `Start' is out of the range [0, length of `String'],
	% or if `Count' is out of the range [0, length of `String' - `Start'],
	% then the behaviour is UNDEFINED.
	% Use with care!
	% This version takes time proportional to the length of the
	% substring, whereas string__substring may take time proportional
	% to the length of the whole string.
	% 
:- func string__unsafe_substring(string, int, int) = string.
:- mode string__unsafe_substring(in, in, in) = uo is det.
:- pred string__unsafe_substring(string, int, int, string).
:- mode string__unsafe_substring(in, in, in, uo) is det.

	% Append a list of strings together.
	% 
:- func string__append_list(list(string)::in) = (string::uo) is det.
:- pred string__append_list(list(string)::in, string::uo) is det.

	% string__join_list(Separator, Strings) = JoinedString:
	% Appends together the strings in Strings, putting Separator between
	% adjacent strings. If Strings is the empty list, returns the empty
	% string.
	%
:- func string__join_list(string::in, list(string)::in) = (string::uo) is det.

	% Compute a hash value for a string.
	%
:- func string__hash(string) = int.
:- pred string__hash(string::in, int::out) is det.

	% string__sub_string_search(String, SubString, Index).
	% `Index' is the position in `String' where the first occurrence of
	% `SubString' begins. Indices start at zero, so if `SubString'
	% is a prefix of `String', this will return Index = 0.
	%
:- pred string__sub_string_search(string::in, string::in, int::out) is semidet.

	% string__sub_string_search(String, SubString, BeginAt, Index).
	% `Index' is the position in `String' where the first occurrence of
	% `SubString' occurs such that 'Index' is greater than or equal to
	% `BeginAt'.  Indices start at zero,
	%
:- pred string__sub_string_search(string::in, string::in, int::in, int::out)
	is semidet.

	% A function similar to sprintf() in C.
	%
	% For example,
	% 	string__format("%s %i %c %f\n",
	% 		[s("Square-root of"), i(2), c('='), f(1.41)], String)
	% will return
	% 	String = "Square-root of 2 = 1.41\n".
	%
	% The following options available in C are supported: flags [0+-# ],
	% a field width (or *), and a precision (could be a ".*").
	%
	% Valid conversion character types are {dioxXucsfeEgGp%}. %n is not
	% supported. string__format will not return the length of the string.
	%
	% conv	var	output form.		effect of '#'.
	% char.	type.
	%
	% d	int	signed integer
	% i	int	signed integer
	% o	int	signed octal		with '0' prefix
	% x,X	int	signed hex		with '0x', '0X' prefix
	% u	int	unsigned integer
	% c	char	character
	% s	string	string
	% f	float	rational number		with '.', if precision 0
	% e,E	float	[-]m.dddddE+-xx		with '.', if precision 0
	% g,G	float	either e or f		with trailing zeros.
	% p	int	integer
	%
	% An option of zero will cause any padding to be zeros rather than
	% spaces. A '-' will cause the output to be left-justified in its
	% 'space'. (With a `-', the default is for fields to be
	% right-justified.)
	% A '+' forces a sign to be printed. This is not sensible for string
	% and character output. A ' ' causes a space to be printed before a
	% thing if there is no sign there. The other option is the '#', which
	% modifies the output string's format. These options are normally put
	% directly after the '%'.
	%
	% Note:
	% 	%#.0e, %#.0E now prints a '.' before the 'e'.
	%
	% 	Asking for more precision than a float actually has will
	% 	result in potentially misleading output.
	%
	% 	Numbers are now rounded by precision value, not
	% 	truncated as previously.
	%
	% 	The implementation uses the sprintf() function, so the
	% 	actual output will depend on the C standard library.
	%
:- func string__format(string, list(string__poly_type)) = string.
:- pred string__format(string::in, list(string__poly_type)::in, string::out)
	is det.

%------------------------------------------------------------------------------%

:- type string__poly_type
	--->	f(float)
	;	i(int)
	;	s(string)
	;	c(char).

%-----------------------------------------------------------------------------%
%-----------------------------------------------------------------------------%

:- implementation.
:- import_module array, bool, float, int, integer, require, std_util.
:- use_module rtti_implementation, term_io, type_desc.

string__replace(Str, Pat, Subst, Result) :-
	sub_string_search(Str, Pat, Index),

	Initial = string__unsafe_substring(Str, 0, Index),

	BeginAt = Index + string__length(Pat),
	Length = string__length(Str) - BeginAt,
	Final = string__unsafe_substring(Str, BeginAt, Length),

	Result = string__append_list([Initial, Subst, Final]).

string__replace_all(Str, Pat, Subst, Result) :-
	( Pat = "" ->
		F = (func(C, L) = [char_to_string(C) ++ Subst | L]),
		Foldl = string__foldl(F, Str, []),
		Result = append_list([Subst | list__reverse(Foldl)])
	;
		PatLength = string__length(Pat),
		ReversedChunks = replace_all(Str, Pat, Subst, PatLength, 0, []),
		Chunks = list__reverse(ReversedChunks),
		Result = string__append_list(Chunks)
	).

:- func string__replace_all(string, string, string,
			int, int, list(string)) = list(string).

string__replace_all(Str, Pat, Subst, PatLength, BeginAt, Result0) = Result :-
	( sub_string_search(Str, Pat, BeginAt, Index) ->
		Length = Index - BeginAt,
		Initial = string__unsafe_substring(Str, BeginAt, Length),
		Start = Index + PatLength,
		Result = string__replace_all(Str, Pat, Subst,
			PatLength, Start, [Subst, Initial | Result0])
	;
		Length = string__length(Str) - BeginAt,
		EndString = string__unsafe_substring(Str, BeginAt, Length),
		Result = [EndString | Result0]
	).

string__to_int(String, Int) :-
	string__base_string_to_int(10, String, Int).

string__base_string_to_int(Base, String, Int) :-
	string__index(String, 0, Char),
	Len = string__length(String),
	( Char = ('-') ->
		Len > 1,
		foldl_substring(accumulate_int(Base), String, 1, Len - 1, 0, N),
		Int = -N
	; Char = ('+') ->
		Len > 1,
		foldl_substring(accumulate_int(Base), String, 1, Len - 1, 0, N),
		Int = N
	;
		foldl_substring(accumulate_int(Base), String, 0, Len, 0, N),
		Int = N
	).

:- pred accumulate_int(int::in, char::in, int::in, int::out) is semidet.

accumulate_int(Base, Char, N, (Base * N) + M) :-
	char__digit_to_int(Char, M),
	M < Base.

% It's important to inline string__index and string__index_det.
% so that the compiler can do loop invariant hoisting
% on calls to string__length that occur in loops.
:- pragma inline(string__index_det/3).

string__index_det(String, Int, Char) :-
	( string__index(String, Int, Char0) ->
		Char = Char0
	;
		error("string__index_det: index out of range")
	).

String ^ elem(Index) = index_det(String, Index).

string__set_char_det(Char, Int, String0, String) :-
	( string__set_char(Char, Int, String0, String1) ->
		String = String1
	;
		error("string__set_char_det: index out of range")
	).

string__foldl(Closure, String, Acc0, Acc) :-
	string__length(String, Length),
	string__foldl_substring(Closure, String, 0, Length, Acc0, Acc).

string__foldl_substring(Closure, String, Start0, Count0, Acc0, Acc) :-
	Start = max(0, Start0),
	Count = min(Count0, length(String) - Start),
	string__foldl_substring_2(Closure, String,Start, Count, Acc0, Acc).

:- pred string__foldl_substring_2(pred(char, T, T), string, int, int, T, T).
:- mode string__foldl_substring_2(pred(in, in, out) is det, in, in, in,
	in, out) is det.
:- mode string__foldl_substring_2(pred(in, di, uo) is det, in, in, in,
	di, uo) is det.
:- mode string__foldl_substring_2(pred(in, in, out) is semidet, in, in, in,
	in, out) is semidet.
:- mode string__foldl_substring_2(pred(in, in, out) is nondet, in, in, in,
	in, out) is nondet.
:- mode string__foldl_substring_2(pred(in, in, out) is multi, in, in, in,
	in, out) is multi.

string__foldl_substring_2(Closure, String, I, Count, !Acc) :-
	( 0 < Count ->
		Closure(string__unsafe_index(String, I), !Acc),
		string__foldl_substring_2(Closure, String, I + 1, Count - 1,
			!Acc)
	;
		true
	).

string__foldr(F, String, Acc0) = Acc :-
	Closure = ( pred(X::in, Y::in, Z::out) is det :- Z = F(X, Y)),
	string__foldr(Closure, String, Acc0, Acc).

string__foldr_substring(F, String, Start, Count, Acc0) = Acc :-
	Closure = ( pred(X::in, Y::in, Z::out) is det :- Z = F(X, Y) ),
	string__foldr_substring(Closure, String, Start, Count, Acc0, Acc).

string__foldr(Closure, String, Acc0, Acc) :-
	string__foldr_substring(Closure, String, 0, length(String), Acc0, Acc).

string__foldr_substring(Closure, String, Start0, Count0, Acc0, Acc) :-
	Start = max(0, Start0),
	Count = min(Count0, length(String) - Start),
	string__foldr_substring_2(Closure, String, Start, Count, Acc0, Acc).

:- pred string__foldr_substring_2(pred(char, T, T), string, int, int, T, T).
:- mode string__foldr_substring_2(pred(in, in, out) is det, in, in, in,
	in, out) is det.
:- mode string__foldr_substring_2(pred(in, di, uo) is det, in, in, in,
	di, uo) is det.
:- mode string__foldr_substring_2(pred(in, in, out) is semidet, in, in, in,
	in, out) is semidet.
:- mode string__foldr_substring_2(pred(in, in, out) is nondet, in, in, in,
	in, out) is nondet.
:- mode string__foldr_substring_2(pred(in, in, out) is multi, in, in, in,
	in, out) is multi.

string__foldr_substring_2(Closure, String, I, Count, !Acc) :-
	( 0 < Count ->
		Closure(string__unsafe_index(String, I + Count - 1), !Acc),
		string__foldr_substring_2(Closure, String, I, Count - 1, !Acc)
	;
		true
	).

string__left(String, Count, LeftString) :-
	string__split(String, Count, LeftString, _RightString).

string__right(String, RightCount, RightString) :-
	string__length(String, Length),
	LeftCount = Length - RightCount,
	string__split(String, LeftCount, _LeftString, RightString).

string__remove_suffix(A, B, C) :-
	string__to_char_list(A, LA),
	string__to_char_list(B, LB),
	string__to_char_list(C, LC),
	char_list_remove_suffix(LA, LB, LC).

:- pragma promise_pure(string__prefix/2).

string__prefix(String::in, Prefix::in) :-
	Len    = length(String),
	PreLen = length(Prefix),
	PreLen =< Len,
	prefix_2_iii(String, Prefix, PreLen - 1).

:- pred prefix_2_iii(string::in, string::in, int::in) is semidet.

prefix_2_iii(String, Prefix, I) :-
	( 0 =< I ->
		(String `unsafe_index` I) =
			(Prefix `unsafe_index` I) `with_type` char,
		prefix_2_iii(String, Prefix, I - 1)
	;
		true
	).

string__prefix(String::in, Prefix::out) :-
	Len = length(String),
	prefix_2_ioii(String, Prefix, 0, Len).

:- pred prefix_2_ioii(string::in, string::out, int::in, int::in) is multi.

prefix_2_ioii(String, Prefix, PreLen, _Len) :-
	Prefix = unsafe_substring(String, 0, PreLen).

prefix_2_ioii(String, Prefix, PreLen, Len) :-
	PreLen < Len,
	prefix_2_ioii(String, Prefix, PreLen + 1, Len).

:- pragma promise_pure(string__suffix/2).

string__suffix(String::in, Suffix::in) :-
	Len    = length(String),
	PreLen = length(Suffix),
	PreLen =< Len,
	suffix_2_iiii(String, Suffix, 0, Len - PreLen, PreLen).

:- pred suffix_2_iiii(string::in, string::in, int::in, int::in, int::in)
	is semidet.

suffix_2_iiii(String, Suffix, I, Offset, Len) :-
	( I < Len ->
		(String `unsafe_index` (I + Offset)) =
			(Suffix `unsafe_index` I) `with_type` char,
		suffix_2_iiii(String, Suffix, I + 1, Offset, Len)
	;
		true
	).

string__suffix(String::in, Suffix::out) :-
	Len = length(String),
	suffix_2_ioii(String, Suffix, 0, Len).

:- pred suffix_2_ioii(string::in, string::out, int::in, int::in) is multi.

suffix_2_ioii(String, Suffix, SufLen, Len) :-
	Suffix = unsafe_substring(String, Len - SufLen, SufLen).

suffix_2_ioii(String, Suffix, SufLen, Len) :-
	SufLen < Len,
	suffix_2_ioii(String, Suffix, SufLen + 1, Len).

string__char_to_string(Char, String) :-
	string__to_char_list(String, [Char]).

string__from_char(Char) = string__char_to_string(Char).

string__int_to_string(N, Str) :-
	string__int_to_base_string(N, 10, Str).

string__from_int(N) = string__int_to_string(N).

string__int_to_base_string(N, Base, Str) :-
	(
		Base >= 2, Base =< 36
	->
		true
	;
		error("string__int_to_base_string: invalid base")
	),
	string__int_to_base_string_1(N, Base, Str).

:- pred string__int_to_base_string_1(int, int, string).
:- mode string__int_to_base_string_1(in, in, uo) is det.

string__int_to_base_string_1(N, Base, Str) :-
	% Note that in order to handle MININT correctly,
	% we need to do the conversion of the absolute
	% number into digits using negative numbers
	% (we can't use positive numbers, since -MININT overflows)
	(
		N < 0
	->
		string__int_to_base_string_2(N, Base, Str1),
		string__append("-", Str1, Str)
	;
		N1 = 0 - N,
		string__int_to_base_string_2(N1, Base, Str)
	).

:- pred string__int_to_base_string_2(int, int, string).
:- mode string__int_to_base_string_2(in, in, uo) is det.

string__int_to_base_string_2(NegN, Base, Str) :-
	(
		NegN > -Base
	->
		N = -NegN,
		char__det_int_to_digit(N, DigitChar),
		string__char_to_string(DigitChar, Str)
	;
		NegN1 = NegN // Base,
		N10 = (NegN1 * Base) - NegN,
		char__det_int_to_digit(N10, DigitChar),
		string__char_to_string(DigitChar, DigitString),
		string__int_to_base_string_2(NegN1, Base, Str1),
		string__append(Str1, DigitString, Str)
	).

string__from_char_list(CharList, Str) :-
	string__to_char_list(Str, CharList).

/*-----------------------------------------------------------------------*/

% :- pred string__to_char_list(string, list(char)).
% :- mode string__to_char_list(in, uo) is det.
% :- mode string__to_char_list(uo, in) is det.

:- pragma foreign_proc("C",
	string__to_char_list(Str::in, CharList::out),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	MR_ConstString p = Str + strlen(Str);
	CharList = MR_list_empty_msg(MR_PROC_LABEL);
	while (p > Str) {
		p--;
		CharList = MR_char_list_cons_msg((MR_UnsignedChar) *p, CharList,
			MR_PROC_LABEL);
	}
}").

:- pragma foreign_proc("C",
	string__to_char_list(Str::uo, CharList::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
		/* mode (uo, in) is det */
	MR_Word char_list_ptr;
	size_t size;

	/*
	** loop to calculate list length + sizeof(MR_Word) in `size'
	** using list in `char_list_ptr'
	*/
	size = sizeof(MR_Word);
	char_list_ptr = CharList;
	while (! MR_list_is_empty(char_list_ptr)) {
		size++;
		char_list_ptr = MR_list_tail(char_list_ptr);
	}

	/*
	** allocate (length + 1) bytes of heap space for string
	** i.e. (length + 1 + sizeof(MR_Word) - 1) / sizeof(MR_Word) words
	*/
	MR_allocate_aligned_string_msg(Str, size, MR_PROC_LABEL);

	/*
	** loop to copy the characters from the char_list to the string
	*/
	size = 0;
	char_list_ptr = CharList;
	while (! MR_list_is_empty(char_list_ptr)) {
		Str[size++] = MR_list_head(char_list_ptr);
		char_list_ptr = MR_list_tail(char_list_ptr);
	}
	/*
	** null terminate the string
	*/
	Str[size] = '\\0';
}").

:- pragma promise_pure(string__to_char_list/2).
string__to_char_list(Str::in, CharList::out) :-
	string__to_char_list_2(Str, 0, CharList).
string__to_char_list(Str::uo, CharList::in) :-
	( CharList = [],
		Str = ""
	; CharList = [C | Cs],
		string__to_char_list(Str0, Cs),
		string__first_char(Str, C, Str0)
	).

:- pred string__to_char_list_2(string::in, int::in, list(char)::uo) is det.
string__to_char_list_2(Str, Index, CharList) :-
	( string__index(Str, Index, Char) ->
		string__to_char_list_2(Str, Index + 1, CharList0),
		CharList = [Char | CharList0]
	;
		CharList = []
	).

/*-----------------------------------------------------------------------*/

%
% We could implement from_rev_char_list using list__reverse and from_char_list,
% but the optimized implementation in C below is there for efficiency since
% it improves the overall speed of parsing by about 7%.
%
:- pragma foreign_proc("C",
	string__from_rev_char_list(Chars::in, Str::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	MR_Word list_ptr;
	MR_Word size, len;

	/*
	** loop to calculate list length + sizeof(MR_Word) in `size'
	** using list in `list_ptr' and separately count the length of the
	** string
	*/
	size = sizeof(MR_Word);
	len = 1;
	list_ptr = Chars;
	while (!MR_list_is_empty(list_ptr)) {
		size++;
		len++;
		list_ptr = MR_list_tail(list_ptr);
	}

	/*
	** allocate (length + 1) bytes of heap space for string
	** i.e. (length + 1 + sizeof(MR_Word) - 1) / sizeof(MR_Word) words
	*/
	MR_allocate_aligned_string_msg(Str, size, MR_PROC_LABEL);

	/*
	** set size to be the offset of the end of the string
	** (ie the \\0) and null terminate the string.
	*/
	Str[--len] = '\\0';

	/*
	** loop to copy the characters from the list_ptr to the string
	** in reverse order.
	*/
	list_ptr = Chars;
	while (!MR_list_is_empty(list_ptr)) {
		Str[--len] = (MR_Char) MR_list_head(list_ptr);
		list_ptr = MR_list_tail(list_ptr);
	}
}").

string__from_rev_char_list(Chars::in, Str::uo) :-
	Str = string__from_char_list(list__reverse(Chars)).

string__to_upper(StrIn, StrOut) :-
	string__to_char_list(StrIn, List),
	string__char_list_to_upper(List, ListUpp),
	string__from_char_list(ListUpp, StrOut).

:- pred string__char_list_to_upper(list(char)::in, list(char)::out) is det.

string__char_list_to_upper([], []).
string__char_list_to_upper([X | Xs], [Y | Ys]) :-
	char__to_upper(X,Y),
	string__char_list_to_upper(Xs,Ys).

string__to_lower(StrIn, StrOut) :-
	string__to_char_list(StrIn, List),
	string__char_list_to_lower(List, ListLow),
	string__from_char_list(ListLow, StrOut).

:- pred string__char_list_to_lower(list(char)::in, list(char)::out) is det.

string__char_list_to_lower([], []).
string__char_list_to_lower([X | Xs], [Y | Ys]) :-
	char__to_lower(X,Y),
	string__char_list_to_lower(Xs,Ys).

string__capitalize_first(S0, S) :-
	( string__first_char(S0, C, S1) ->
		char__to_upper(C, UpperC),
		string__first_char(S, UpperC, S1)
	;
		S = S0
	).

string__uncapitalize_first(S0, S) :-
	( string__first_char(S0, C, S1) ->
		char__to_lower(C, LowerC),
		string__first_char(S, LowerC, S1)
	;
		S = S0
	).

:- pred string__all_match(pred(char)::in(pred(in) is semidet), string::in)
	is semidet.

string__all_match(P, String) :-
	all_match_2(string__length(String) - 1, P, String).

:- pred all_match_2(int::in, pred(char)::in(pred(in) is semidet), string::in)
	is semidet.

string__all_match_2(I, P, String) :-
	( I >= 0 ->
		P(string__unsafe_index(String, I)),
		string__all_match_2(I - 1, P, String)
	;
		true
	).

string__is_alpha(S) :-
	string__all_match(char__is_alpha, S).

string__is_alpha_or_underscore(S) :-
	string__all_match(char__is_alpha_or_underscore, S).

string__is_alnum_or_underscore(S) :-
	string__all_match(char__is_alnum_or_underscore, S).

string__pad_left(String0, PadChar, Width, String) :-
	string__length(String0, Length),
	( Length < Width ->
		Count = Width - Length,
		string__duplicate_char(PadChar, Count, PadString),
		string__append(PadString, String0, String)
	;
		String = String0
	).

string__pad_right(String0, PadChar, Width, String) :-
	string__length(String0, Length),
	( Length < Width ->
		Count = Width - Length,
		string__duplicate_char(PadChar, Count, PadString),
		string__append(String0, PadString, String)
	;
		String = String0
	).

string__duplicate_char(Char, Count, String) :-
	String = string__from_char_list(list__duplicate(Count, Char)).

%-----------------------------------------------------------------------------%

string__append_list(Lists, string__append_list(Lists)).

	% Implementation of string__append_list that uses C as this
	% minimises the amount of garbage created.
:- pragma foreign_proc("C",
	string__append_list(Strs::in) = (Str::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	MR_Word	list = Strs;
	MR_Word	tmp;
	size_t	len;

		/* Determine the total length of all strings */
	len = 0;
	while (!MR_list_is_empty(list)) {
		len += strlen((MR_String) MR_list_head(list));
		list = MR_list_tail(list);
	}

		/* Allocate enough word aligned memory for the string */
	MR_allocate_aligned_string_msg(Str, len, MR_PROC_LABEL);

		/* Copy the strings into the new memory */
	len = 0;
	list = Strs;
	while (!MR_list_is_empty(list)) {
		strcpy((MR_String) Str + len, (MR_String) MR_list_head(list));
		len += strlen((MR_String) MR_list_head(list));
		list = MR_list_tail(list);
	}

		/* Set the last character to the null char */
	Str[len] = '\\0';
}").

	% Implementation of string__join_list that uses C as this
	% minimises the amount of garbage created.
:- pragma foreign_proc("C",
	string__join_list(Sep::in, Strs::in) = (Str::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	MR_Word	list = Strs;
	MR_Word	tmp;
	size_t	len = 0;
	size_t	sep_len;
	MR_bool	add_sep;

	sep_len = strlen(Sep);

		/* Determine the total length of all strings */
	len = 0;
	add_sep = MR_FALSE;
	while (!MR_list_is_empty(list)) {
		if (add_sep) {
			len += sep_len;
		}

		len += strlen((MR_String) MR_list_head(list));
		list = MR_list_tail(list);
		add_sep = MR_TRUE;
	}

	MR_allocate_aligned_string_msg(Str, len, MR_PROC_LABEL);

		/* Copy the strings into the new memory */
	len = 0;
	list = Strs;
	add_sep = MR_FALSE;
	while (!MR_list_is_empty(list)) {
		if (add_sep) {
			strcpy((MR_String) Str + len, Sep);
			len += sep_len;
		}

		strcpy((MR_String) Str + len, (MR_String) MR_list_head(list));
		len += strlen((MR_String) MR_list_head(list));
		list = MR_list_tail(list);
		add_sep = MR_TRUE;
	}

		/* Set the last character to the null char */
	Str[len] = '\\0';
}").

string__append_list(Strs::in) = (Str::uo) :-
	( Strs = [X | Xs] ->
		Str = X ++ append_list(Xs)
	;
		Str = ""
	).

string__join_list(_, []) = "".
string__join_list(Sep, [H | T]) = H ++ string__join_list_2(Sep, T).

:- func string__join_list_2(string::in, list(string)::in) = (string::uo) is det.

string__join_list_2(_, []) = "".
string__join_list_2(Sep, [H | T]) = Sep ++ H ++ string__join_list_2(Sep, T).

%-----------------------------------------------------------------------------%

	% Note - string__hash is also defined in code/imp.h
	% The two definitions must be kept identical.

string__hash(String, HashVal) :-
	string__length(String, Length),
	string__hash_2(String, 0, Length, 0, HashVal0),
	HashVal = HashVal0 `xor` Length.

:- pred string__hash_2(string::in, int::in, int::in, int::in, int::out) is det.

string__hash_2(String, Index, Length, HashVal0, HashVal) :-
	( Index < Length ->
		string__combine_hash(HashVal0,
			char__to_int(string__unsafe_index(String, Index)),
			HashVal1),
		string__hash_2(String, Index + 1, Length, HashVal1, HashVal)
	;
		HashVal = HashVal0
	).

:- pred string__combine_hash(int::in, int::in, int::out) is det.

string__combine_hash(H0, X, H) :-
	H1 = H0 `xor` (H0 << 5),
	H = H1 `xor` X.

%-----------------------------------------------------------------------------%

string__sub_string_search(WholeString, Pattern, Index) :-
	sub_string_search(WholeString, Pattern, 0, Index).

:- pragma foreign_proc("C",
	sub_string_search(WholeString::in, Pattern::in, BeginAt::in, Index::out),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	char *match;
	match = strstr(WholeString + BeginAt, Pattern);
	if (match) {
		Index = match - WholeString;
		SUCCESS_INDICATOR = MR_TRUE;
	} else {
		SUCCESS_INDICATOR = MR_FALSE;
	}
}").

:- pragma foreign_proc("C#",
	sub_string_search(WholeString::in, Pattern::in, BeginAt::in, Index::out),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	Index = WholeString.IndexOf(Pattern, BeginAt);
	SUCCESS_INDICATOR = (Index >= 0);
}").

% This is only used if there is no matching foreign_proc definition
sub_string_search(String, SubString, BeginAt, Index) :-
	sub_string_search_2(String, SubString, BeginAt, length(String),
		length(SubString), Index).

	% Brute force string searching. For short Strings this is
	% good; for longer strings Boyer-Moore is much better.
:- pred sub_string_search_2(string::in, string::in, int::in, int::in, int::in,
	int::out) is semidet.

sub_string_search_2(String, SubString, I, Length, SubLength, Index) :-
	I < Length,
	(
		% XXX This is inefficient --
		% there is no (in, in, in) = in is semidet mode of
		% substring, so this ends up calling the
		% (in, in, in) = out mode and then doing the unification.
		% This will create a lot of unnecessary garbage.
		substring(String, I, SubLength) = SubString
	->
		Index = I
	;
		sub_string_search_2(String, SubString, I + 1,
			Length, SubLength, Index)
	).

%-----------------------------------------------------------------------------%

	% This predicate has been optimised to produce the least memory
	% possible -- memory usage is a significant problem for programs
	% which do a lot of formatted IO.
string__format(FormatString, PolyList, String) :-
	(
		format_string(Specifiers, PolyList, [],
			to_char_list(FormatString), [])
	->
		String = string__append_list(
			list__map(specifier_to_string, Specifiers))
	;
		error("string__format: format string invalid.")
	).

:- type string__specifier
	--->	conv(
			flags		:: list(char),
			width		:: maybe(list(char)),
			precision	:: maybe(list(char)),
			spec		:: spec
		)
	;	string(list(char)).

	%
	% A format string is parsed into alternate sections.
	% We alternate between the list of characters which don't
	% represent a conversion specifier and those that do.
	%
:- pred format_string(list(string__specifier)::out,
		list(string__poly_type)::in, list(string__poly_type)::out,
		list(char)::in, list(char)::out) is det.

format_string(Results, PolyTypes0, PolyTypes) -->
	other(NonConversionSpecChars),
	( conversion_specification(ConversionSpec, PolyTypes0, PolyTypes1) ->
		format_string(Results0, PolyTypes1, PolyTypes),
		{ Results = [string(NonConversionSpecChars),
			ConversionSpec | Results0] }
	;
		{ Results = [string(NonConversionSpecChars)] },
		{ PolyTypes = PolyTypes0 }
	).

	%
	% Parse a string which doesn't contain any conversion
	% specifications.
	%
:- pred other(list(char)::out, list(char)::in, list(char)::out) is det.

other(Result) -->
	( [Char], { Char \= '%' } ->
		other(Result0),
		{ Result = [Char | Result0] }
	;
		{ Result = [] }
	).

	%
	% Each conversion specification is introduced by the character
	% '%', and ends with a conversion specifier. In between there
	% may be (in this order) zero or more flags, an optional
	% minimum field width, and an optional precision.
	%
:- pred conversion_specification(string__specifier::out,
		list(string__poly_type)::in, list(string__poly_type)::out,
		list(char)::in, list(char)::out) is semidet.

conversion_specification(Specificier, PolyTypes0, PolyTypes) -->
	['%'],
	flags(Flags),
	optional(width, MaybeWidth, PolyTypes0, PolyTypes1),
	optional(prec, MaybePrec, PolyTypes1, PolyTypes2),
	( spec(Spec, PolyTypes2, PolyTypes3) ->
		{ Specificier = conv(Flags, MaybeWidth, MaybePrec, Spec) },
		{ PolyTypes = PolyTypes3 }
	;
		{ error("string__format: invalid conversion specifier.") }
	).

:- pred optional(
	pred(T, U, U, V, V)::in(pred(out, in, out, in, out) is semidet),
	maybe(T)::out, U::in, U::out, V::in, V::out) is det.

optional(P, MaybeOutput, Init, Final, !Acc) :-
	( P(Output, Init, Final0, !Acc) ->
		MaybeOutput = yes(Output),
		Final = Final0
	;
		MaybeOutput = no,
		Final = Init
	).

:- pred flags(list(char)::out, list(char)::in, list(char)::out) is semidet.

flags(Result) -->
	( [Char], { flag(Char) } ->
		flags(Result0),
		{ Result = [Char | Result0] }
	;
		{ Result = [] }
	).

	%
	% Is it a valid flag character?
	%
:- pred flag(char::in) is semidet.

flag('#').
flag('0').
flag('-').
flag(' ').
flag('+').

	%
	% Do we have a minimum field width?
	%
:- pred width(list(char)::out,
	list(string__poly_type)::in, list(string__poly_type)::out,
	list(char)::in, list(char)::out) is semidet.

width(Width, PolyTypes0, PolyTypes) -->
	( ['*'] ->
		{ PolyTypes0 = [i(Width0) | PolyTypes1] ->
				% XXX may be better done in C.
			Width = to_char_list(int_to_string(Width0)),
			PolyTypes = PolyTypes1
		;
			error("string__format: `*' width modifier " ++
				"not associated with an integer.")
		}
	;
		=(Init),
		non_zero_digit,
		zero_or_more_occurences(digit),
		=(Final),

		{ char_list_remove_suffix(Init, Final, Width) },
		{ PolyTypes = PolyTypes0 }
	).

	%
	% Do we have a precision?
	%
:- pred prec(list(char)::out,
	list(string__poly_type)::in, list(string__poly_type)::out,
	list(char)::in, list(char)::out) is semidet.

prec(Prec, PolyTypes0, PolyTypes) -->
	['.'],
	( ['*'] ->
		{ PolyTypes0 = [i(Prec0) | PolyTypes1] ->
				% XXX Best done in C
			Prec = to_char_list(int_to_string(Prec0)),
			PolyTypes = PolyTypes1
		;
			error("string__format: `*' precision modifier " ++
				"not associated with an integer.")
		}
	;
		=(Init),
		digit,
		zero_or_more_occurences(digit),
		=(Final)
	->
		{ char_list_remove_suffix(Init, Final, Prec) },
		{ PolyTypes = PolyTypes0 }
	;
			% When no number follows the '.' the precision
			% defaults to 0.
		{ Prec = ['0'] },
		{ PolyTypes = PolyTypes0 }
	).

% NB the capital letter specifiers are proceeded with a 'c'.
:- type spec
		% valid integer specifiers
	--->	d(int)
	;	i(int)
	;	o(int)
	;	u(int)
	;	x(int)
	;	cX(int)
	;	p(int)

		% valid float specifiers
	;	e(float)
	;	cE(float)
	;	f(float)
	;	cF(float)
	;	g(float)
	;	cG(float)

		% valid char specifiers
	;	c(char)

		% valid string specifiers
	;	s(string)

		% specifier representing "%%"
	;	percent
	.

	%
	% Do we have a valid conversion specifier?
	% We check to ensure that the specifier also matches the type
	% from the input list.
	%
:- pred spec(spec::out,
	list(string__poly_type)::in, list(string__poly_type)::out,
	list(char)::in, list(char)::out) is semidet.

	% valid integer conversion specifiers
spec(d(Int), [i(Int) | Ps], Ps) --> ['d'].
spec(i(Int), [i(Int) | Ps], Ps) --> ['i'].
spec(o(Int), [i(Int) | Ps], Ps) --> ['o'].
spec(u(Int), [i(Int) | Ps], Ps) --> ['u'].
spec(x(Int), [i(Int) | Ps], Ps) --> ['x'].
spec(cX(Int), [i(Int) | Ps], Ps) --> ['X'].
spec(p(Int), [i(Int) | Ps], Ps) --> ['p'].

	% valid float conversion specifiers
spec(e(Float), [f(Float) | Ps], Ps) --> ['e'].
spec(cE(Float), [f(Float) | Ps], Ps) --> ['E'].
spec(f(Float), [f(Float) | Ps], Ps) --> ['f'].
spec(cF(Float), [f(Float) | Ps], Ps) --> ['F'].
spec(g(Float), [f(Float) | Ps], Ps) --> ['g'].
spec(cG(Float), [f(Float) | Ps], Ps) --> ['G'].

	% valid char conversion specifiers
spec(c(Char), [c(Char) | Ps], Ps) --> ['c'].

	% valid string conversion specifiers
spec(s(Str), [s(Str) | Ps], Ps) --> ['s'].

	% conversion specifier representing the "%" sign
spec(percent, Ps, Ps) --> ['%'].

	% A digit in the range [1-9]
:- pred non_zero_digit(list(char)::in, list(char)::out) is semidet.

non_zero_digit -->
	[ Char ],
	{ char__is_digit(Char) },
	{ Char \= '0' }.

	% A digit in the range [0-9]
:- pred digit(list(char)::in, list(char)::out) is semidet.

digit -->
	[ Char ],
	{ char__is_digit(Char) }.

	% Zero or more occurences of the string parsed by the ho pred.
:- pred zero_or_more_occurences(
	pred(list(T), list(T))::in(pred(in, out) is semidet),
	list(T)::in, list(T)::out) is det.

zero_or_more_occurences(P, !Chars) :-
	( P(!Chars) ->
		zero_or_more_occurences(P, !Chars)
	;
		true
	).

:- func specifier_to_string(string__specifier) = string. 

specifier_to_string(conv(Flags, Width, Prec, Spec)) = String :-
	(
			% valid int conversion specifiers
		Spec = d(Int),
		( using_sprintf ->
			FormatStr = make_format(Flags, Width,
				Prec, int_length_modifer, "d"),
			String = native_format_int(FormatStr, Int)
		;
			String = format_int(Flags, conv(Width), conv(Prec),
				Int)
		)
	;
		Spec = i(Int),
		( using_sprintf ->
			FormatStr = make_format(Flags, Width,
				Prec, int_length_modifer, "i"),
			String = native_format_int(FormatStr, Int)
		;
			String = format_int(Flags, conv(Width), conv(Prec),
				Int)
		)
	;
		Spec = o(Int),
		( using_sprintf ->
			FormatStr = make_format(Flags, Width,
				Prec, int_length_modifer, "o"),
			String = native_format_int(FormatStr, Int)
		;
			String = format_unsigned_int(Flags, conv(Width),
				conv(Prec), 8, Int, no, "")
		)
	;
		Spec = u(Int),
		( using_sprintf ->
			FormatStr = make_format(Flags, Width,
				Prec, int_length_modifer, "u"),
			String = native_format_int(FormatStr, Int)
		;
			String = format_unsigned_int(Flags, conv(Width),
				conv(Prec), 10, Int, no, "")
		)
	;
		Spec = x(Int),
		( using_sprintf ->
			FormatStr = make_format(Flags, Width,
				Prec, int_length_modifer, "x"),
			String = native_format_int(FormatStr, Int)
		;
			String = format_unsigned_int(Flags, conv(Width),
				conv(Prec), 16, Int, no, "0x")
		)
	;
		Spec = cX(Int),
		( using_sprintf ->
			FormatStr = make_format(Flags, Width,
				Prec, int_length_modifer, "X"),
			String = native_format_int(FormatStr, Int)
		;
			String = format_unsigned_int(Flags, conv(Width),
				conv(Prec), 16, Int, no, "0X")
		)
	;
		Spec = p(Int),
		( using_sprintf ->
			FormatStr = make_format(Flags, Width,
				Prec, int_length_modifer, "p"),
			String = native_format_int(FormatStr, Int)
		;
			String = format_unsigned_int(['#' | Flags],
				conv(Width), conv(Prec), 16, Int, yes, "0x")
		)
	;
			% valid float conversion specifiers
		Spec = e(Float),
		( using_sprintf ->
			FormatStr = make_format(Flags, Width, Prec, "", "e"),
			String = native_format_float(FormatStr, Float)
		;
			String = format_scientific_number(Flags,
				conv(Width), conv(Prec), Float, "e")
		)
	;
		Spec = cE(Float),
		( using_sprintf ->
			FormatStr = make_format(Flags, Width, Prec, "", "E"),
			String = native_format_float(FormatStr, Float)
		;
			String = format_scientific_number(Flags,
				conv(Width), conv(Prec), Float, "E")
		)
	;
		Spec = f(Float),
		( using_sprintf ->
			FormatStr = make_format(Flags, Width, Prec, "", "f"),
			String = native_format_float(FormatStr, Float)
		;
			String = format_float(Flags, conv(Width), conv(Prec),
				Float)
		)
	;
		Spec = cF(Float),
		( using_sprintf ->
			FormatStr = make_format(Flags, Width, Prec, "", "F"),
			String = native_format_float(FormatStr, Float)
		;
			String = format_float(Flags, conv(Width), conv(Prec),
				Float)
		)
	;
		Spec = g(Float),
		( using_sprintf ->
			FormatStr = make_format(Flags, Width, Prec, "", "g"),
			String = native_format_float(FormatStr, Float)
		;
			String = format_scientific_number_g(Flags,
				conv(Width), conv(Prec), Float, "e")
		)
	;
		Spec = cG(Float),
		( using_sprintf ->
			FormatStr = make_format(Flags, Width, Prec, "", "G"),
			String = native_format_float(FormatStr, Float)
		;
			String = format_scientific_number_g(Flags,
				conv(Width), conv(Prec), Float, "E")
		)
	;
			% valid char conversion Specifiers
		Spec = c(Char),
		( using_sprintf ->
			FormatStr = make_format(Flags, Width, Prec, "", "c"),
			String = native_format_char(FormatStr, Char)
		;
			String = format_char(Flags, conv(Width), Char)
		)
	;
			% valid string conversion Specifiers
		Spec = s(Str),
		( using_sprintf ->
			FormatStr = make_format(Flags, Width, Prec, "", "s"),
			String = native_format_string(FormatStr, Str)
		;
			String = format_string(Flags,
				conv(Width), conv(Prec), Str)
		)
	;
			% conversion specifier representing the "%" sign
		Spec = percent,
		String = "%"
	).
specifier_to_string(string(Chars)) = from_char_list(Chars).

:- func conv(maybe(list(character))) = maybe(int).

conv(no) = no.
conv(yes(X)) = yes(string__det_to_int(from_char_list(X))).

%-----------------------------------------------------------------------------%

	% Construct a format string.
:- func make_format(list(char), maybe(list(char)),
	maybe(list(char)), string, string) = string.

make_format(Flags, MaybeWidth, MaybePrec, LengthMod, Spec) =
	( using_sprintf ->
		make_format_sprintf(Flags, MaybeWidth, MaybePrec, LengthMod,
			Spec)
	;
		make_format_dotnet(Flags, MaybeWidth, MaybePrec, LengthMod,
			Spec)
	).

	% Are we using C's sprintf? All backends other than C return false.
	% Note that any backends which return true for using_sprintf/0 must
	% also implement:
	%	int_length_modifer/0
	%	native_format_float/2
	%	native_format_int/2
	%	native_format_string/2
	%	native_format_char/2
:- pred using_sprintf is semidet.

:- pragma foreign_proc("C", using_sprintf,
	[will_not_call_mercury, promise_pure, thread_safe],
"
	SUCCESS_INDICATOR = MR_TRUE;
").
:- pragma foreign_proc("C#", using_sprintf,
	[will_not_call_mercury, promise_pure, thread_safe],
"
	SUCCESS_INDICATOR = false;
").
:- pragma foreign_proc("Java", using_sprintf,
	[will_not_call_mercury, promise_pure, thread_safe],
"
	succeeded = false;
").

	% Construct a format string suitable to passing to sprintf.
:- func make_format_sprintf(list(char), maybe(list(char)),
	maybe(list(char)), string, string) = string.

make_format_sprintf(Flags, MaybeWidth, MaybePrec, LengthMod, Spec) = String :-
	(
		MaybeWidth = yes(Width)
	;
		MaybeWidth = no,
		Width = []
	),
	(
		MaybePrec = yes(Prec0),
		Prec = ['.' | Prec0]
	;
		MaybePrec = no,
		Prec = []
	),
	String = string__append_list(["%", from_char_list(Flags),
		from_char_list(Width), from_char_list(Prec), LengthMod, Spec]).

	% Construct a format string suitable to passing to .NET's formatting
	% functions.
	% XXX this code is not yet complete. We need to do a lot more work
	% to make this work perfectly.
:- func make_format_dotnet(list(char), maybe(list(char)),
	maybe(list(char)), string, string) = string.

make_format_dotnet(_Flags, MaybeWidth, MaybePrec, _LengthMod, Spec0) = String :-
	(
		MaybeWidth = yes(Width0),
		Width = [',' | Width0]
	;
		MaybeWidth = no,
		Width = []
	),
	(
		MaybePrec = yes(Prec)
	;
		MaybePrec = no,
		Prec = []
	),
	(	Spec0 = "i" -> Spec = "d"
	;	Spec0 = "f" -> Spec = "e"
	;	Spec = Spec0
	),
	String = string__append_list([
		"{0",
		from_char_list(Width),
		":",
		Spec,
		from_char_list(Prec),
%		LengthMod,
%		from_char_list(Flags),
		"}"]).

:- func int_length_modifer = string.
:- pragma foreign_proc("C",
	int_length_modifer = (LengthModifier::out),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	MR_make_aligned_string(LengthModifier, MR_INTEGER_LENGTH_MODIFIER);
}").

% This predicate is only called if using_sprintf/0, so we produce an error
% by default.
int_length_modifer = _ :- error("string.int_length_modifer/0 not defined").

	% Create a string from a float using the format string.
	% Note it is the responsibility of the caller to ensure that the
	% format string is valid.
:- func native_format_float(string, float) = string.
:- pragma foreign_proc("C",
	native_format_float(FormatStr::in, Val::in) = (Str::out),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	MR_save_transient_hp();
	Str = MR_make_string(MR_PROC_LABEL, FormatStr, (double) Val);
	MR_restore_transient_hp();
}").
% This predicate is only called if using_sprintf/0, so we produce an error
% by default.
native_format_float(_, _) = _ :-
	error("string.native_format_float/2 not defined").

	% Create a string from a int using the format string.
	% Note it is the responsibility of the caller to ensure that the
	% format string is valid.
:- func native_format_int(string, int) = string.
:- pragma foreign_proc("C",
	native_format_int(FormatStr::in, Val::in) = (Str::out),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	MR_save_transient_hp();
	Str = MR_make_string(MR_PROC_LABEL, FormatStr, Val);
	MR_restore_transient_hp();
}").
% This predicate is only called if using_sprintf/0, so we produce an error
% by default.
native_format_int(_, _) = _ :-
	error("string.native_format_int/2 not defined").

	% Create a string from a string using the format string.
	% Note it is the responsibility of the caller to ensure that the
	% format string is valid.
:- func native_format_string(string, string) = string.
:- pragma foreign_proc("C",
	native_format_string(FormatStr::in, Val::in) = (Str::out),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	MR_save_transient_hp();
	Str = MR_make_string(MR_PROC_LABEL, FormatStr, Val);
	MR_restore_transient_hp();
}").
% This predicate is only called if using_sprintf/0, so we produce an error
% by default.
native_format_string(_, _) = _ :-
	error("string.native_format_string/2 not defined").

	% Create a string from a char using the format string.
	% Note it is the responsibility of the caller to ensure that the
	% format string is valid.
:- func native_format_char(string, char) = string.
:- pragma foreign_proc("C",
	native_format_char(FormatStr::in, Val::in) = (Str::out),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	MR_save_transient_hp();
	Str = MR_make_string(MR_PROC_LABEL, FormatStr, Val);
	MR_restore_transient_hp();
}").
% This predicate is only called if using_sprintf/0, so we produce an error
% by default.
native_format_char(_, _) = _ :-
	error("string.native_format_char/2 not defined").

%-----------------------------------------------------------------------------%

:- type flags == list(char).
:- type maybe_width == maybe(int).
:- type maybe_precision == maybe(int).

	%
	% Format a character (c).
	%
:- func format_char(flags, maybe_width, char) = string.
format_char(Flags, Width, Char) = String :-
	CharStr = string__char_to_string(Char),
	String = justify_string(Flags, Width, CharStr).

	%
	% Format a string (s).
	%
:- func format_string(flags, maybe_width, maybe_precision, string) = string.
format_string(Flags, Width, Prec, OldStr) = NewStr :-
	( Prec = yes(NumChars) ->
		PrecStr = string__substring(OldStr, 0, NumChars)
	;
		PrecStr = OldStr
	),
	NewStr = justify_string(Flags, Width, PrecStr).

:- func format_int(flags, maybe_width, maybe_precision, int) = string.

format_int(Flags, Width, Prec, Int) = String :-
	%
	% Find the integer's absolute value, and take care of the special
	% case of precision zero with an integer of 0.
	%
	( Int = 0, Prec = yes(0) ->
		AbsIntStr = ""
	;
		Integer = integer(Int),
		AbsInteger = integer__abs(Integer),
		AbsIntStr = integer__to_string(AbsInteger)
	),
	AbsIntStrLength = string__length(AbsIntStr),

	%
	% Do we need to increase precision?
	%
	( Prec = yes(Precision), Precision > AbsIntStrLength ->
		PrecStr = string__pad_left(AbsIntStr, '0', Precision)
	;
		PrecStr = AbsIntStr
	),

	%
	% Do we need to pad to the field width.
	%
	(
		Width = yes(FieldWidth),
		FieldWidth > string__length(PrecStr),
		member('0', Flags),
		\+ member('-', Flags),
		Prec = no
	->
		FieldStr = string__pad_left(PrecStr, '0', FieldWidth - 1),
		ZeroPadded = yes
	;
		FieldStr = PrecStr,
		ZeroPadded = no
	),

	%
	% Prefix with appropriate sign or zero padding.
	% The previous step has deliberately left room for this.
	%
	( Int < 0 ->
		SignedStr = "-" ++ FieldStr
	; member('+', Flags) ->
		SignedStr = "+" ++ FieldStr
	; member(' ', Flags) ->
		SignedStr = " " ++ FieldStr
	; ZeroPadded = yes ->
		SignedStr = "0" ++ FieldStr
	;
		SignedStr = FieldStr
	),

	String = justify_string(Flags, Width, SignedStr).

	%
	% Format an unsigned int, unsigned octal, or unsigned hexadecimal
	% (u,o,x,X).
	%
:- func format_unsigned_int(flags, maybe_width, maybe_precision,
	int, int, bool, string) = string.

format_unsigned_int(Flags, Width, Prec, Base, Int, IsTypeP, Prefix) = String :-
		%
		% Find the integer's absolute value, and take care of the
		% special case of precision zero with an integer of 0.
		%
	(
		Int = 0,
		Prec = yes(0)
	->
		AbsIntStr = ""
	;
		Div = integer__pow(integer(2), integer(int__bits_per_int)),
		UnsignedInteger = integer(Int) mod Div,
		( Base = 10 ->
			AbsIntStr0 = integer__to_string(UnsignedInteger)
		; Base = 8 ->
			AbsIntStr0 = to_octal(UnsignedInteger)
		; Prefix = "0x" ->
			AbsIntStr0 = to_hex(UnsignedInteger)
		;
			AbsIntStr0 = to_capital_hex(UnsignedInteger)
		),

			%
			% Just in case Int = 0 (base converters return "").
			%
		( AbsIntStr0 = "" ->
			AbsIntStr = "0"
		;
			AbsIntStr = AbsIntStr0
		)
	),
	AbsIntStrLength = string__length(AbsIntStr),

		%
		% Do we need to increase precision?
		%
	( Prec = yes(Precision), Precision > AbsIntStrLength ->
		PrecStr = string__pad_left(AbsIntStr, '0', Precision)
	;
		PrecStr = AbsIntStr
	),

		%
		% Do we need to increase the precision of an octal?
		%
	(
		Base = 8,
		member('#', Flags),
		\+ string__prefix(PrecStr, "0")
	->
		PrecModStr = append("0", PrecStr)
	;
		PrecModStr = PrecStr
	),

		%
		% Do we need to pad to the field width.
		%
	(
		Width = yes(FieldWidth),
		FieldWidth > string__length(PrecModStr),
		member('0', Flags),
		\+ member('-', Flags),
		Prec = no
	->
			%
			% Do we need to make room for "0x" or "0X" ?
			%
		(
			Base = 16,
			member('#', Flags),
			( Int \= 0 ; IsTypeP = yes )
		->
			FieldStr = string__pad_left(PrecModStr, '0',
				FieldWidth - 2)
		;
			FieldStr = string__pad_left(PrecModStr, '0',
				FieldWidth)
		)
	;
		FieldStr = PrecModStr
	),

		%
		% Do we have to prefix "0x" or "0X"?
		%
	(
		Base = 16,
		member('#', Flags),
		( Int \= 0
		; IsTypeP = yes
		)
	->
		FieldModStr = Prefix ++ FieldStr
	;
		FieldModStr = FieldStr
	),

	String = justify_string(Flags, Width, FieldModStr).

	%
	% Format a float (f)
	%
:- func format_float(flags, maybe_width, maybe_precision, float) = string.

format_float(Flags, Width, Prec, Float) = NewFloat :-

		%
		% Determine absolute value of string.
		%
	Abs = abs(Float),

		%
		% Change precision (default is 6)
		%
	AbsStr = convert_float_to_string(Abs),
	( is_nan_or_inf(Abs) ->
		PrecModStr = AbsStr
	;
		( Prec = yes(Precision) ->
			PrecStr = change_precision(Precision, AbsStr)
		;
			PrecStr = change_precision(6, AbsStr)
		),

			%
			% Do we need to remove the decimal point?
			%
		( \+ member('#', Flags), Prec = yes(0) ->
			PrecStrLen = string__length(PrecStr),
			PrecModStr = string__substring(PrecStr, 0,
				PrecStrLen - 1)
		;
			PrecModStr = PrecStr
		)
	),

		%
		% Do we need to change field width?
		%
	(
		Width = yes(FieldWidth),
		FieldWidth > string__length(PrecModStr),
		member('0', Flags),
		\+ member('-', Flags)
	->
		FieldStr = string__pad_left(PrecModStr, '0', FieldWidth - 1),
		ZeroPadded = yes
	;
		FieldStr = PrecModStr,
		ZeroPadded = no

	),
		%
		% Finishing up ..
		%
	( Float < 0.0 ->
		SignedStr = "-" ++ FieldStr
	; member('+', Flags) ->
		SignedStr = "+" ++ FieldStr
	; member(' ', Flags) ->
		SignedStr = " " ++ FieldStr
	; ZeroPadded = yes ->
		SignedStr = "0" ++ FieldStr
	;
		SignedStr = FieldStr
	),

	NewFloat = justify_string(Flags, Width, SignedStr).

	%
	% Format a scientific number to a specified number of significant
	% figures (g,G)
	%
:- func format_scientific_number_g(flags, maybe_width, maybe_precision,
	float, string) = string.

format_scientific_number_g(Flags, Width, Prec, Float, E) = NewFloat :-
		%
		% Determine absolute value of string.
		%
	Abs = abs(Float),

		%
		% Change precision (default is 6)
		%
	AbsStr = convert_float_to_string(Abs),
	( is_nan_or_inf(Abs) ->
		PrecStr = AbsStr
	;
		( Prec = yes(Precision) ->
			(Precision = 0 ->
				PrecStr = change_to_g_notation(AbsStr,
					1, E, Flags)
			;
				PrecStr = change_to_g_notation(AbsStr,
					Precision, E, Flags)
			)
		;
			PrecStr = change_to_g_notation(AbsStr, 6, E, Flags)
		)
	),

		%
		% Do we need to change field width?
		%
	(
		Width = yes(FieldWidth),
		FieldWidth > string__length(PrecStr),
		member('0', Flags),
		\+ member('-', Flags)
	->
		FieldStr = string__pad_left(PrecStr, '0', FieldWidth - 1),
		ZeroPadded = yes
	;
		FieldStr = PrecStr,
		ZeroPadded = no
	),

		%
		% Finishing up ..
		%
	( Float < 0.0 ->
		SignedStr = "-" ++ FieldStr
	; member('+', Flags) ->
		SignedStr = "+" ++ FieldStr
	; member(' ', Flags) ->
		SignedStr = " " ++ FieldStr
	; ZeroPadded = yes ->
		SignedStr = "0" ++ FieldStr
	;
		SignedStr = FieldStr
	),

	NewFloat = justify_string(Flags, Width, SignedStr).

	%
	% Format a scientific number (e,E)
	%
:- func format_scientific_number(flags, maybe_width, maybe_precision,
	float, string) = string.

format_scientific_number(Flags, Width, Prec, Float, E) = NewFloat :-
		%
		% Determine absolute value of string.
		%
	Abs = abs(Float),

		%
		% Change precision (default is 6)
		%
	AbsStr = convert_float_to_string(Abs),
	( is_nan_or_inf(Abs) ->
		PrecModStr = AbsStr
	;
		( Prec = yes(Precision) ->
			PrecStr = change_to_e_notation(AbsStr, Precision, E)
		;
			PrecStr = change_to_e_notation(AbsStr, 6, E)
		),

			%
			% Do we need to remove the decimal point?
			%
		( \+ member('#', Flags), Prec = yes(0) ->
			split_at_decimal_point(PrecStr, BaseStr, ExponentStr),
			PrecModStr = BaseStr ++ ExponentStr
		;
			PrecModStr = PrecStr
		)
	),

		%
		% Do we need to change field width?
		%
	(
		Width = yes(FieldWidth),
		FieldWidth > string__length(PrecModStr),
		member('0', Flags),
		\+ member('-', Flags)
	->
		FieldStr = string__pad_left(PrecModStr, '0', FieldWidth - 1),
		ZeroPadded = yes
	;
		FieldStr = PrecModStr,
		ZeroPadded = no
	),

		%
		% Finishing up ..
		%
	( Float < 0.0 ->
		SignedStr = "-" ++ FieldStr
	; member('+', Flags) ->
		SignedStr = "+" ++ FieldStr
	; member(' ', Flags) ->
		SignedStr = " " ++ FieldStr
	; ZeroPadded = yes ->
		SignedStr = "0" ++ FieldStr
	;
		SignedStr = FieldStr
	),

	NewFloat = justify_string(Flags, Width, SignedStr).

:- func justify_string(flags, maybe_width, string) = string.

justify_string(Flags, Width, Str) =
	( Width = yes(FWidth), FWidth > string__length(Str) ->
		( member('-', Flags) ->
			string__pad_right(Str, ' ', FWidth)
		;
			string__pad_left(Str, ' ', FWidth)
		)
	;
		Str
	).

	%
	% Convert an integer to an octal string.
	%
:- func to_octal(integer) = string.

to_octal(Num) = NumStr :-
	( Num > integer(0) ->
		Rest = to_octal(Num // integer(8)),
		Rem = Num rem integer(8),
		RemStr = integer__to_string(Rem),
		NumStr = append(Rest, RemStr)
	;
		NumStr = ""
	).

	%
	% Convert an integer to a hexadecimal string using a-f.
	%
:- func to_hex(integer) = string.

to_hex(Num) = NumStr :-
	( Num > integer(0) ->
		Rest = to_hex(Num // integer(16)),
		Rem = Num rem integer(16),
		RemStr = get_hex_int(Rem),
		NumStr = append(Rest, RemStr)
	;
		NumStr = ""
	).

	%
	% Convert an integer to a hexadecimal string using A-F.
	%
:- func to_capital_hex(integer) = string.

to_capital_hex(Num) = NumStr :-
	( Num > integer(0) ->
		Rest = to_capital_hex(Num // integer(16)),
		Rem = Num rem integer(16),
		RemStr = get_capital_hex_int(Rem),
		NumStr = append(Rest, RemStr)
	;
		NumStr = ""
	).

	%
	% Given a decimal integer, return the hexadecimal equivalent
	% (using % a-f).
	%
:- func get_hex_int(integer) = string.

get_hex_int(Int) = HexStr :-
	( Int < integer(10) ->
		HexStr = integer__to_string(Int)
	; Int = integer(10) ->
		HexStr = "a"
	; Int = integer(11) ->
		HexStr = "b"
	; Int = integer(12) ->
		HexStr = "c"
	; Int = integer(13) ->
		HexStr = "d"
	; Int = integer(14) ->
		HexStr = "e"
	;
		HexStr = "f"
	).

	%
	% Convert an integer to a hexadecimal string using A-F.
	%
:- func get_capital_hex_int(integer) = string.

get_capital_hex_int(Int) = HexStr :-
	( Int < integer(10) ->
		HexStr = integer__to_string(Int)
	; Int = integer(10) ->
		HexStr = "A"
	; Int = integer(11) ->
		HexStr = "B"
	; Int = integer(12) ->
		HexStr = "C"
	; Int = integer(13) ->
		HexStr = "D"
	; Int = integer(14) ->
		HexStr = "E"
	;
		HexStr = "F"
	).

	%
	% Unlike the standard library function, this function converts a float
	% to a string without resorting to scientific notation.
	%
	% This predicate relies on the fact that string__float_to_string
	% returns a float which is round-trippable, ie to the full precision
	% needed.
	%
:- func convert_float_to_string(float) = string.

convert_float_to_string(Float) = String :-
	string__lowlevel_float_to_string(Float, FloatStr),

		%
		% check for scientific representation.
		%
	(
		( string__contains_char(FloatStr, 'e')
		; string__contains_char(FloatStr, 'E')
		)
	->
		split_at_exponent(FloatStr, FloatPtStr, ExpStr),
		split_at_decimal_point(FloatPtStr, MantissaStr, FractionStr),

			%
			% what is the exponent?
			%
		ExpInt = string__det_to_int(ExpStr),
		( ExpInt >= 0 ->

				%
				% move decimal pt to the right.
				%
			ExtraDigits = ExpInt,
			PaddedFracStr = string__pad_right(FractionStr,
				'0', ExtraDigits),
			string__split(PaddedFracStr, ExtraDigits,
				MantissaRest, NewFraction),

			NewMantissa = MantissaStr ++ MantissaRest,
			MantAndPoint = NewMantissa ++ ".",
			( NewFraction = "" ->
				String = MantAndPoint ++ "0"
			;
				String = MantAndPoint ++ NewFraction
			)
		;
				%
				% move decimal pt to the left.
				%
			ExtraDigits = abs(ExpInt),
			PaddedMantissaStr = string__pad_left(MantissaStr,
				'0', ExtraDigits),
			string__split(PaddedMantissaStr,
				length(PaddedMantissaStr) - ExtraDigits,
				NewMantissa, FractionRest),

			( NewMantissa = "" ->
				MantAndPoint = "0."
			;
				MantAndPoint = NewMantissa ++ "."
			),
			String = MantAndPoint ++ FractionRest ++ FractionStr
		)
	;
		String = FloatStr
	).

	%
	% Converts a floating point number to a specified number of standard
	% figures. The style used depends on the value converted; style e (or
	% E) is used only if the exponent resulting from such a conversion is
	% less than -4 or greater than or equal to the precision. Trailing
	% zeros are removed from the fractional portion of the result unless
	% the # flag is specified: a decimal-point character appears only if it
	% is followed by a digit.
	%
:- func change_to_g_notation(string, int, string, flags) = string.

change_to_g_notation(Float, Prec, E, Flags) = FormattedFloat :-
	Exponent = size_of_required_exponent(Float, Prec),
	(
		Exponent >= -4,
		Exponent < Prec
	->
			% Float will be represented normally.
			% -----------------------------------
			% Need to calculate precision to pass to the
			% change_precision function, because the current
			% precision represents significant figures, not decimal
			% places.
			%
			% now change float's precision.
			%
		( Exponent =< 0 ->
				%
				% deal with floats such as 0.00000000xyz
				%
			DecimalPos = decimal_pos(Float),
			FormattedFloat0 = change_precision(
				abs(DecimalPos) - 1 + Prec, Float)
		;
				%
				% deal with floats such as ddddddd.mmmmmmmm
				%
			ScientificFloat = change_to_e_notation(Float,
				Prec - 1, "e"),
			split_at_exponent(ScientificFloat,
				BaseStr, ExponentStr),
			Exp = string__det_to_int(ExponentStr),
			split_at_decimal_point(BaseStr,
				MantissaStr, FractionStr),
			RestMantissaStr = substring(FractionStr, 0, Exp),
			NewFraction = substring(FractionStr,
				Exp, Prec - Exp - 1),
			FormattedFloat0 = MantissaStr ++
				RestMantissaStr ++ "." ++ NewFraction
		),

			%
			% Do we remove trailing zeros?
			%
		( member('#', Flags) ->
			FormattedFloat = FormattedFloat0
		;
			FormattedFloat = remove_trailing_zeros(FormattedFloat0)
		)
	;
			% Float will be represented in scientific notation.
			% -------------------------------------------------
			%
		UncheckedFloat = change_to_e_notation(Float, Prec - 1, E),

			%
			% Do we need to remove trailing zeros?
			%
		( member('#', Flags) ->
			FormattedFloat = UncheckedFloat
		;
			split_at_exponent(UncheckedFloat, BaseStr,
				ExponentStr),
			NewBaseStr = remove_trailing_zeros(BaseStr),
			FormattedFloat = NewBaseStr ++ E ++ ExponentStr
		)
	).

	%
	% convert floating point notation to scientific notation.
	%
:- func change_to_e_notation(string, int, string) = string.

change_to_e_notation(Float, Prec, E) = ScientificFloat :-
	UnsafeExponent = decimal_pos(Float),
	UnsafeBase = calculate_base_unsafe(Float, Prec),

		%
		% Is mantissa greater than one digit long?
		%
	split_at_decimal_point(UnsafeBase, MantissaStr, _FractionStr),
	( string__length(MantissaStr) > 1 ->
		% need to append 0, to fix the problem of having no numbers
		% after the decimal point.
		SafeBase = calculate_base_unsafe(
			string__append(UnsafeBase, "0"), Prec),
		SafeExponent = UnsafeExponent + 1
	;
		SafeBase = UnsafeBase,
		SafeExponent = UnsafeExponent
	),
		%
		% Creating exponent.
		%
	( SafeExponent >= 0 ->
		( SafeExponent < 10 ->
			ExponentStr = string__append_list(
				[E, "+0", string__int_to_string(SafeExponent)])
		;
			ExponentStr = string__append_list(
				[E, "+", string__int_to_string(SafeExponent)])
		)
	;
		( SafeExponent > -10 ->
			ExponentStr = string__append_list(
				[E, "-0", string__int_to_string(
					int__abs(SafeExponent))])
		;
			ExponentStr = E ++ string__int_to_string(SafeExponent)
		)
	),
	ScientificFloat = SafeBase ++ ExponentStr.

	%
	% Given a floating point number, this function calculates the size of
	% the exponent needed to represent the float in scientific notation.
	%
:- func size_of_required_exponent(string, int) = int.

size_of_required_exponent(Float, Prec) = Exponent :-
	UnsafeExponent = decimal_pos(Float),
	UnsafeBase = calculate_base_unsafe(Float, Prec),

		%
		% Is mantissa one digit long?
		%
	split_at_decimal_point(UnsafeBase, MantissaStr, _FractionStr),
	( string__length(MantissaStr) > 1 ->
			% we will need need to move decimal pt one place to the
			% left: therefore, increment exponent.
		Exponent = UnsafeExponent + 1
	;
		Exponent = UnsafeExponent
	).

	%
	% Given a string representing a floating point number, function returns
	% a string with all trailing zeros removed.
	%
:- func remove_trailing_zeros(string) = string.

remove_trailing_zeros(Float) = TrimmedFloat :-
	FloatCharList = string__to_char_list(Float),
	FloatCharListRev = list__reverse(FloatCharList),
	TrimmedFloatRevCharList = remove_zeros(FloatCharListRev),
	TrimmedFloatCharList = list__reverse(TrimmedFloatRevCharList),
	TrimmedFloat = string__from_char_list(TrimmedFloatCharList).

	%
	% Given a char list, this function removes all leading zeros, including
	% decimal point, if need be.
	%
:- func remove_zeros(list(char)) = list(char).

remove_zeros(CharNum) = TrimmedNum :-
	( CharNum = ['0' | Rest] ->
		TrimmedNum = remove_zeros(Rest)
	; CharNum = ['.' | Rest] ->
		TrimmedNum = Rest
	;
		TrimmedNum = CharNum
	).

	%
	% Determine the location of the decimal point in the string that
	% represents a floating point number.
	%
:- func decimal_pos(string) = int.

decimal_pos(Float) = Pos :-
	split_at_decimal_point(Float, MantissaStr, _FractionStr),
	NumZeros = string__length(MantissaStr) - 1,
	Pos = find_non_zero_pos(string__to_char_list(Float), NumZeros).

	%
	% Given a list of chars representing a floating point number, function
	% determines the the first position containing a non-zero digit.
	% Positions after the decimal point are negative, and those before the
	% decimal point are positive.
	%
:- func find_non_zero_pos(list(char), int) = int.

find_non_zero_pos(Xs, CurrentPos) = ActualPos :-
	( Xs = [Y | Ys] ->
		( is_decimal_point(Y) ->
			ActualPos = find_non_zero_pos(Ys, CurrentPos)
		; Y = '0' ->
			ActualPos = find_non_zero_pos(Ys, CurrentPos - 1)
		;
			ActualPos = CurrentPos
		)
	;
		ActualPos = 0
	).

	%
	% Representing a floating point number in scientific notation requires
	% a base and an exponent. This function returns the base. But it is
	% unsafe, since particular input result in the base having a mantissa
	% with more than one digit. Therefore, the calling function must check
	% for this problem.
	%
:- func calculate_base_unsafe(string, int) = string.

calculate_base_unsafe(Float, Prec) = Exp :-
	Place = decimal_pos(Float),
	split_at_decimal_point(Float, MantissaStr, FractionStr),
	( Place < 0 ->
		DecimalPos = abs(Place),
		PaddedMantissaStr = string__substring(FractionStr, 0,
			DecimalPos),

			%
			% get rid of superfluous zeros.
			%
		MantissaInt = string__det_to_int(PaddedMantissaStr),
		ExpMantissaStr = string__int_to_string(MantissaInt),

			%
			% create fractional part
			%
		PaddedFractionStr = pad_right(FractionStr, '0', Prec + 1),
		ExpFractionStr = string__substring(PaddedFractionStr,
			DecimalPos, Prec + 1)
	; Place > 0 ->
		ExpMantissaStr = string__substring(MantissaStr, 0, 1),
		FirstHalfOfFractionStr = string__substring(MantissaStr,
			1, Place),
		ExpFractionStr = FirstHalfOfFractionStr ++ FractionStr
	;
		ExpMantissaStr = MantissaStr,
		ExpFractionStr = FractionStr
	),
	MantissaAndPoint = ExpMantissaStr ++ ".",
	UnroundedExpStr = MantissaAndPoint ++ ExpFractionStr,
	Exp = change_precision(Prec, UnroundedExpStr).

	%
	% Change the precision of a float to a specified number of decimal
	% places.
	%
	% n.b. OldFloat must be positive for this function to work.
	%
:- func change_precision(int, string) = string.

change_precision(Prec, OldFloat) = NewFloat :-
	split_at_decimal_point(OldFloat, MantissaStr, FractionStr),
	FracStrLen = string__length(FractionStr),
	( Prec > FracStrLen ->
		PrecFracStr = string__pad_right(FractionStr, '0', Prec),
		PrecMantissaStr = MantissaStr
	; Prec < FracStrLen ->
		UnroundedFrac = string__substring(FractionStr, 0, Prec),
		NextDigit = string__index_det(FractionStr, Prec),
		(
			UnroundedFrac \= "",
			(char__to_int(NextDigit) - char__to_int('0')) >= 5
		->
			NewPrecFrac = string__det_to_int(UnroundedFrac) + 1,
			NewPrecFracStrNotOK = string__int_to_string(
				NewPrecFrac),
			NewPrecFracStr = string__pad_left(NewPrecFracStrNotOK,
				'0', Prec),
			(
				string__length(NewPrecFracStr) >
					string__length(UnroundedFrac)
			->
				PrecFracStr = substring(NewPrecFracStr,
					1, Prec),
				PrecMantissaInt = det_to_int(MantissaStr) + 1,
				PrecMantissaStr = int_to_string(PrecMantissaInt)
			;
				PrecFracStr = NewPrecFracStr,
				PrecMantissaStr = MantissaStr
			)

		;
			UnroundedFrac = "",
			(char__to_int(NextDigit) - char__to_int('0')) >= 5
		->
			PrecMantissaInt = det_to_int(MantissaStr) + 1,
			PrecMantissaStr = int_to_string(PrecMantissaInt),
			PrecFracStr = ""
		;
			PrecFracStr = UnroundedFrac,
			PrecMantissaStr = MantissaStr
		)
	;
		PrecFracStr = FractionStr,
		PrecMantissaStr = MantissaStr
	),
	HalfNewFloat = PrecMantissaStr ++ ".",
	NewFloat = HalfNewFloat ++ PrecFracStr.

:- pred split_at_exponent(string::in, string::out, string::out) is det.

split_at_exponent(Str, Float, Exponent) :-
	FloatAndExponent = string__words(is_exponent, Str),
	list__index0_det(FloatAndExponent, 0, Float),
	list__index0_det(FloatAndExponent, 1, Exponent).

:- pred split_at_decimal_point(string::in, string::out, string::out) is det.

split_at_decimal_point(Str, Mantissa, Fraction) :-
	MantAndFrac = string__words(is_decimal_point, Str),
	list__index0_det(MantAndFrac, 0, Mantissa),
	( list__index0(MantAndFrac, 1, Fraction0) ->
		Fraction = Fraction0
	;
		Fraction = ""
	).

:- pred is_decimal_point(char :: in) is semidet.

is_decimal_point('.').

:- pred is_exponent(char :: in) is semidet.

is_exponent('e').
is_exponent('E').

%-----------------------------------------------------------------------------%

% The remaining routines are implemented using the C interface.

:- pragma foreign_decl("C",
"
#include <ctype.h>
#include <string.h>
#include <stdio.h>

#include ""mercury_string.h""	/* for MR_allocate_aligned_string*() etc. */
#include ""mercury_tags.h""	/* for MR_list_cons*() */
").

%-----------------------------------------------------------------------------%

string__from_float(Flt) = string__float_to_string(Flt).

:- pragma foreign_proc("C",
	string__float_to_string(Flt::in, Str::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	/*
	** For efficiency reasons we duplicate the C implementation
	** of string__lowlevel_float_to_string
	*/
	MR_float_to_string(Flt, Str);
}").

	% XXX The unsafe_promise_unique is needed because in
	% string__float_to_string_2 the call to string__to_float doesn't
	% have a (ui, out) mode hence the output string cannot be unique.
string__float_to_string(Float, unsafe_promise_unique(String)) :-
	String = string__float_to_string_2(min_precision, Float).

:- func string__float_to_string_2(int, float) = (string) is det.

string__float_to_string_2(Prec, Float) = String :-
	string__format("%#." ++ int_to_string(Prec) ++ "g", [f(Float)], Tmp),
	( Prec = max_precision ->
		String = Tmp
	;
		( string__to_float(Tmp, Float) ->
			String = Tmp
		;
			String = string__float_to_string_2(Prec + 1, Float)
		)
	).

	% XXX For efficiency reasons we assume that on non-C backends that
	% we are using double precision floats, however the commented out
	% code provides a general mechanism for calculating the required
	% precision.
:- func min_precision = int.

min_precision = 15.

% min_precision =
%	floor_to_int(float(mantissa_digits) * log2(float(radix)) / log2(10.0)).

:- func max_precision = int.
max_precision = min_precision + 2.

%
% string__lowlevel_float_to_string differs from string__float_to_string in
% that it must be implemented without calling string__format (e.g. by
% invoking some foreign language routine to do the conversion) as this is
% the predicate string__format uses to get the initial string
% representation of a float.
%
% The string returned must match one of the following regular expression:
%	^[+-]?[0-9]*\.?[0-9]+((e|E)[0-9]+)?$
%	^[nN][aA][nN]$
%	^[+-]?[iI][nN][fF][iI][nN][iI][tT][yY]$
%	^[+-]?[iI][nN][fF]$
% and the string returned must have sufficient precision for representing
% the float.
%
:- pred string__lowlevel_float_to_string(float::in, string::uo) is det.

:- pragma foreign_proc("C",
	string__lowlevel_float_to_string(Flt::in, Str::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	/*
	** Note any changes here will require the same changes in
	** string__float_to_string.
	*/
	MR_float_to_string(Flt, Str);
}").

:- pragma foreign_proc("C#",
	string__lowlevel_float_to_string(FloatVal::in, FloatString::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"
		// The R format string prints the double out such that it
		// can be round-tripped.
		// XXX According to the documentation it tries the 15 digits of
		// precision, then 17 digits skipping 16 digits of precision.
		// unlike what we do for the C backend.
	FloatString = FloatVal.ToString(""R"");
").

:- pragma foreign_proc("Java",
	string__lowlevel_float_to_string(FloatVal::in, FloatString::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	FloatString = java.lang.Double.toString(FloatVal);
").

string__det_to_float(FloatString) =
	( if	string__to_float(FloatString, FloatVal)
	  then	FloatVal
	  else	func_error("string.det_to_float/1 - conversion failed.")
	).

:- pragma export(string__to_float(in, out), "ML_string_to_float").
:- pragma foreign_proc("C",
	string__to_float(FloatString::in, FloatVal::out),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	/*
	** The %c checks for any erroneous characters appearing after
	** the float; if there are then sscanf() will return 2 rather
	** than 1.
	*/
	char	tmpc;
	SUCCESS_INDICATOR =
		(!MR_isspace(FloatString[0])) &&
		(sscanf(FloatString, MR_FLT_FMT ""%c"", &FloatVal, &tmpc) == 1);
		/* MR_TRUE if sscanf succeeds, MR_FALSE otherwise */
}").

:- pragma foreign_proc("C#",
	string__to_float(FloatString::in, FloatVal::out),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	// leading or trailing whitespace is not allowed
	if (FloatString.Length == 0 ||
	    System.Char.IsWhiteSpace(FloatString, 0) ||
	    System.Char.IsWhiteSpace(FloatString, FloatString.Length - 1))
	{
		SUCCESS_INDICATOR = false;
	} else {
		/*
		** XXX should we also catch System.OverflowException?
		*/
		try {
			FloatVal = System.Convert.ToDouble(FloatString);
			SUCCESS_INDICATOR = true;
		} catch (System.FormatException e) {
			SUCCESS_INDICATOR = false;
		}
	}
}").

:- pragma foreign_proc("Java",
	string__to_float(FloatString::in, FloatVal::out),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	FloatVal = 0.0;		// FloatVal must be initialized to suppress
				// error messages when the predicate fails.

	// leading or trailing whitespace is not allowed
	if (FloatString.length() == 0 || FloatString.trim() != FloatString) {
		succeeded = false;
	} else {
		try {
			FloatVal = java.lang.Double.parseDouble(FloatString);
			succeeded = true;
		} catch(java.lang.NumberFormatException e) {

			// At this point it *should* in theory be safe just to
			// set succeeded = false, since the Java API claims
			// that Double.parseDouble() will handle all the cases
			// we require. However, it turns out that in practice
			// (tested with Sun's Java 2 SDK, Standard Edition,
			// version 1.3.1_04)
			// Java actually throws a NumberFormatException when
			// you give it NaN or infinity, so we handle these
			// cases below.

			if (FloatString.equalsIgnoreCase(""nan"")) {
				FloatVal = java.lang.Double.NaN;
				succeeded = true;
			} else if (FloatString.equalsIgnoreCase(""infinity""))
			{
				FloatVal = java.lang.Double.POSITIVE_INFINITY;
				succeeded = true;
			} else if (FloatString.substring(1).
				equalsIgnoreCase(""infinity""))
			{
				if (FloatString.charAt(0) == '+') {
					FloatVal = java.lang.Double.
						POSITIVE_INFINITY;
					succeeded = true;
				} else if (FloatString.charAt(0) == '-') {
					FloatVal = java.lang.Double.
						NEGATIVE_INFINITY;
					succeeded = true;
				} else {
					succeeded = false;
				}
			} else {
				succeeded = false;
			}
		}
	}
").

/*-----------------------------------------------------------------------*/

	% strchr always returns true when searching for '\0',
	% but the '\0' is an implementation detail which really
	% shouldn't be considered to be part of the string itself.
:- pragma foreign_proc("C",
	string__contains_char(Str::in, Ch::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	SUCCESS_INDICATOR = (strchr(Str, Ch) != NULL) && Ch != '\\0';
").
:- pragma foreign_proc("C#",
	string__contains_char(Str::in, Ch::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	SUCCESS_INDICATOR = (Str.IndexOf(Ch) != -1);
").
string__contains_char(String, Char) :-
	string__contains_char(String, Char, 0, string__length(String)).

:- pred string__contains_char(string::in, char::in,
		int::in, int::in) is semidet.

string__contains_char(Str, Char, Index, Length) :-
	( Index < Length ->
		string__unsafe_index(Str, Index, IndexChar),
		( IndexChar = Char ->
			true
		;
			string__contains_char(Str, Char, Index + 1, Length)
		)
	;
		fail
	).

/*-----------------------------------------------------------------------*/

% It's important to inline string__index and string__index_det.
% so that the compiler can do loop invariant hoisting
% on calls to string__length that occur in loops.
:- pragma inline(string__index/3).

string__index(Str, Index, Char) :-
	Len = string__length(Str),
	( string__index_check(Index, Len) ->
		string__unsafe_index(Str, Index, Char)
	;
		fail
	).

:- pred string__index_check(int::in, int::in) is semidet.

/* We should consider making this routine a compiler built-in. */
:- pragma foreign_proc("C",
	string__index_check(Index::in, Length::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	/*
	** We do not test for negative values of Index
	** because (a) MR_Unsigned is unsigned and hence a
	** negative argument will appear as a very large
	** positive one after the cast and (b) anybody
	** dealing with the case where strlen(Str) > MAXINT
	** is clearly barking mad (and one may well
	** get an integer overflow error in this case).
	*/
	SUCCESS_INDICATOR = ((MR_Unsigned) Index < (MR_Unsigned) Length);
").
:- pragma foreign_proc("C#",
	string__index_check(Index::in, Length::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	SUCCESS_INDICATOR = ((uint) Index < (uint) Length);
").
string__index_check(Index, Length) :-
	Index >= 0,
	Index < Length.

/*-----------------------------------------------------------------------*/

:- pragma foreign_proc("C",
	string__unsafe_index(Str::in, Index::in, Ch::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	Ch = Str[Index];
").
:- pragma foreign_proc("C#",
	string__unsafe_index(Str::in, Index::in, Ch::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	Ch = Str[Index];
").
:- pragma foreign_proc("Java",
	string__unsafe_index(Str::in, Index::in, Ch::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	Ch = Str.charAt(Index);
").
string__unsafe_index(Str, Index, Char) :-
	( string__first_char(Str, First, Rest) ->
		( Index = 0 ->
			Char = First
		;
			string__unsafe_index(Rest, Index - 1, Char)
		)
	;
		error("string__unsafe_index: out of bounds")
	).

String ^ unsafe_elem(Index) = unsafe_index(String, Index).

/*-----------------------------------------------------------------------*/

:- pragma foreign_decl("C",
"
#ifdef MR_USE_GCC_GLOBAL_REGISTERS
	/*
	** GNU C version egcs-1.1.2 crashes with `fixed or forbidden
	** register spilled' in grade asm_fast.gc.tr.debug
	** if we write this inline.
	*/
	extern void MR_set_char(MR_String str, MR_Integer ind, MR_Char ch);
#else
	#define MR_set_char(str, ind, ch) \\
		((str)[ind] = (ch))
#endif
").

:- pragma foreign_code("C",
"
#ifdef MR_USE_GCC_GLOBAL_REGISTERS
	/*
	** GNU C version egcs-1.1.2 crashes with `fixed or forbidden
	** register spilled' in grade asm_fast.gc.tr.debug
	** if we write this inline.
	*/
	void MR_set_char(MR_String str, MR_Integer ind, MR_Char ch)
	{
		str[ind] = ch;
	}
#endif
").

:- pragma foreign_proc("C",
	string__set_char(Ch::in, Index::in, Str0::in, Str::out),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	size_t len = strlen(Str0);
	if ((MR_Unsigned) Index >= len) {
		SUCCESS_INDICATOR = MR_FALSE;
	} else {
		SUCCESS_INDICATOR = MR_TRUE;
		MR_allocate_aligned_string_msg(Str, len, MR_PROC_LABEL);
		strcpy(Str, Str0);
		MR_set_char(Str, Index, Ch);
	}
").
:- pragma foreign_proc("C#",
	string__set_char(Ch::in, Index::in, Str0::in, Str::out),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	if (Index >= Str0.Length) {
		SUCCESS_INDICATOR = false;
	} else {
		Str = System.String.Concat(Str0.Substring(0, Index),
			System.Convert.ToString(Ch),
			Str0.Substring(Index + 1));
		SUCCESS_INDICATOR = true;
	}
").
string__set_char(Ch, Index, Str0, Str) :-
	string__to_char_list(Str0, List0),
	list__replace_nth(List0, Index + 1, Ch, List),
	string__to_char_list(Str, List).

% :- pragma foreign_proc("C",
% 	string__set_char(Ch::in, Index::in, Str0::di, Str::uo),
% 	[will_not_call_mercury, promise_pure, thread_safe],
% "
% 	if ((MR_Unsigned) Index >= strlen(Str0)) {
% 		SUCCESS_INDICATOR = MR_FALSE;
% 	} else {
% 		SUCCESS_INDICATOR = MR_TRUE;
% 		Str = Str0;
% 		MR_set_char(Str, Index, Ch);
% 	}
% ").
%
% :- pragma foreign_proc("C#",
% 	string__set_char(Ch::in, Index::in, Str0::di, Str::uo),
% 	[will_not_call_mercury, promise_pure, thread_safe],
% "
% 	if (Index >= Str0.Length) {
% 		SUCCESS_INDICATOR = false;
% 	} else {
% 		Str = System.String.Concat(Str0.Substring(0, Index),
% 			System.Convert.ToString(Ch),
% 			Str0.Substring(Index + 1));
% 		SUCCESS_INDICATOR = true;
% 	}
% ").

/*-----------------------------------------------------------------------*/

:- pragma foreign_proc("C",
	string__unsafe_set_char(Ch::in, Index::in, Str0::in, Str::out),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	size_t len = strlen(Str0);
	MR_allocate_aligned_string_msg(Str, len, MR_PROC_LABEL);
	strcpy(Str, Str0);
	MR_set_char(Str, Index, Ch);
").
:- pragma foreign_proc("C#",
	string__unsafe_set_char(Ch::in, Index::in, Str0::in, Str::out),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	Str = System.String.Concat(Str0.Substring(0, Index),
		System.Convert.ToString(Ch),
		Str0.Substring(Index + 1));
").
:- pragma foreign_proc("Java",
	string__unsafe_set_char(Ch::in, Index::in, Str0::in, Str::out),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	Str = Str0.substring(0, Index) + Ch + Str0.substring(Index + 1);
").

% :- pragma foreign_proc("C",
% 	string__unsafe_set_char(Ch::in, Index::in, Str0::di, Str::uo),
% 	[will_not_call_mercury, promise_pure, thread_safe],
% "
% 	Str = Str0;
% 	MR_set_char(Str, Index, Ch);
% ").
% :- pragma foreign_proc("C#",
% 	string__unsafe_set_char(Ch::in, Index::in, Str0::di, Str::uo),
% 	[will_not_call_mercury, promise_pure, thread_safe],
% "
% 	Str = System.String.Concat(Str0.Substring(0, Index),
% 		System.Convert.ToString(Ch),
% 		Str0.Substring(Index + 1));
% ").
% :- pragma foreign_proc("Java",
% 	string__unsafe_set_char(Ch::in, Index::in, Str0::di, Str::uo),
% 	[will_not_call_mercury, promise_pure, thread_safe],
% "
% 	Str = Str0.substring(0, Index) + Ch + Str0.substring(Index + 1);
% ").

/*-----------------------------------------------------------------------*/

:- pragma foreign_proc("C",
	string__length(Str::in, Length::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	Length = strlen(Str);
").
:- pragma foreign_proc("C#",
	string__length(Str::in, Length::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	Length = Str.Length;
").
:- pragma foreign_proc("Java",
	string__length(Str::in, Length::uo),
		[will_not_call_mercury, promise_pure, thread_safe], "
	Length = Str.length();
").

:- pragma foreign_proc("C",
	string__length(Str::ui, Length::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	Length = strlen(Str);
").
:- pragma foreign_proc("C#",
	string__length(Str::ui, Length::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	Length = Str.Length;
").
:- pragma foreign_proc("Java",
	string__length(Str::ui, Length::uo),
		[will_not_call_mercury, promise_pure, thread_safe], "
	Length = Str.length();
").

:- pragma promise_pure(string__length/2).

string__length(Str0, Len) :-
		% XXX This copy is only necessary because of the ui.
	copy(Str0, Str),
	string__length_2(Str, 0, Len).

:- pred string__length_2(string::in, int::in, int::out) is det.

string__length_2(Str, Index, Length) :-
	( string__index(Str, Index, _) ->
		string__length_2(Str, Index + 1, Length)
	;
		Length = Index
	).

/*-----------------------------------------------------------------------*/

:- pragma promise_pure(string__append/3).

string__append(S1::in, S2::in, S3::in) :-
	string__append_iii(S1, S2, S3).
string__append(S1::in, S2::uo, S3::in) :-
	string__append_ioi(S1, S2, S3).
string__append(S1::in, S2::in, S3::uo) :-
	string__append_iio(S1, S2, S3).
string__append(S1::out, S2::out, S3::in) :-
	string__append_ooi(S1, S2, S3).

:- pred string__append_iii(string::in, string::in, string::in) is semidet.

:- pragma foreign_proc("C",
	string__append_iii(S1::in, S2::in, S3::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	size_t len_1 = strlen(S1);
	SUCCESS_INDICATOR = (
		strncmp(S1, S3, len_1) == 0 &&
		strcmp(S2, S3 + len_1) == 0
	);
}").

:- pragma foreign_proc("C#",
	string__append_iii(S1::in, S2::in, S3::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	SUCCESS_INDICATOR = S3.Equals(System.String.Concat(S1, S2));
}").

string__append_iii(X, Y, Z) :-
	string__mercury_append(X, Y, Z).

:- pred string__append_ioi(string::in, string::uo, string::in) is semidet.

:- pragma foreign_proc("C",
	string__append_ioi(S1::in, S2::uo, S3::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	size_t len_1, len_2, len_3;

	len_1 = strlen(S1);
	if (strncmp(S1, S3, len_1) != 0) {
		SUCCESS_INDICATOR = MR_FALSE;
	} else {
		len_3 = strlen(S3);
		len_2 = len_3 - len_1;
		/*
		** We need to make a copy to ensure that the pointer is
		** word-aligned.
		*/
		MR_allocate_aligned_string_msg(S2, len_2, MR_PROC_LABEL);
		strcpy(S2, S3 + len_1);
		SUCCESS_INDICATOR = MR_TRUE;
	}
}").

:- pragma foreign_proc("C#",
	string__append_ioi(S1::in, S2::uo, S3::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	if (S3.StartsWith(S1)) {
		S2 = S3.Remove(0, S1.Length);
		SUCCESS_INDICATOR = true;
	} else {
		SUCCESS_INDICATOR = false;
	}
}").

string__append_ioi(X, Y, Z) :-
	string__mercury_append(X, Y, Z).

:- pred string__append_iio(string::in, string::in, string::uo) is det.

:- pragma foreign_proc("C",
	string__append_iio(S1::in, S2::in, S3::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	size_t len_1, len_2;
	len_1 = strlen(S1);
	len_2 = strlen(S2);
	MR_allocate_aligned_string_msg(S3, len_1 + len_2, MR_PROC_LABEL);
	strcpy(S3, S1);
	strcpy(S3 + len_1, S2);
}").

:- pragma foreign_proc("C#",
	string__append_iio(S1::in, S2::in, S3::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	S3 = System.String.Concat(S1, S2);
}").

string__append_iio(X, Y, Z) :-
	string__mercury_append(X, Y, Z).

:- pred string__append_ooi(string::out, string::out, string::in) is multi.

string__append_ooi(S1, S2, S3) :-
	S3Len = string__length(S3),
	string__append_ooi_2(0, S3Len, S1, S2, S3).

:- pred string__append_ooi_2(int::in, int::in, string::out, string::out,
	string::in) is multi.

string__append_ooi_2(NextS1Len, S3Len, S1, S2, S3) :-
	( NextS1Len = S3Len ->
		string__append_ooi_3(NextS1Len, S3Len, S1, S2, S3)
	;
		(
			string__append_ooi_3(NextS1Len, S3Len,
				S1, S2, S3)
		;
			string__append_ooi_2(NextS1Len + 1, S3Len,
				S1, S2, S3)
		)
	).

:- pred string__append_ooi_3(int::in, int::in, string::out,
	string::out, string::in) is det.

:- pragma foreign_proc("C",
	string__append_ooi_3(S1Len::in, S3Len::in, S1::out, S2::out, S3::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	MR_allocate_aligned_string_msg(S1, S1Len, MR_PROC_LABEL);
	MR_memcpy(S1, S3, S1Len);
	S1[S1Len] = '\\0';
	MR_allocate_aligned_string_msg(S2, S3Len - S1Len, MR_PROC_LABEL);
	strcpy(S2, S3 + S1Len);
}").

:- pragma foreign_proc("C#",
	string__append_ooi_3(S1Len::in, _S3Len::in, S1::out, S2::out, S3::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	S1 = S3.Substring(0, S1Len);
	S2 = S3.Substring(S1Len);
").

string__append_ooi_3(S1Len, _S3Len, S1, S2, S3) :-
	string__split(S3, S1Len, S1, S2).

:- pred string__mercury_append(string, string, string).
:- mode string__mercury_append(in, in, in) is semidet.	% implied
:- mode string__mercury_append(in, uo, in) is semidet.
:- mode string__mercury_append(in, in, uo) is det.
:- mode string__mercury_append(uo, uo, in) is multi.

string__mercury_append(X, Y, Z) :-
	string__to_char_list(X, XList),
	string__to_char_list(Y, YList),
	string__to_char_list(Z, ZList),
	list__append(XList, YList, ZList).

/*-----------------------------------------------------------------------*/

string__substring(Str::in, Start::in, Count::in, SubStr::uo) :-
	End = min(Start + Count, string__length(Str)),
	SubStr = string__from_char_list(strchars(Start, End, Str)).

:- func strchars(int, int, string) = list(char).

strchars(I, End, Str) =
	(
		( I < 0
		; End =< I
		)
	->
		[]
	;
		[string__index_det(Str, I) | strchars(I + 1, End, Str)]
	).

:- pragma foreign_proc("C",
	string__substring(Str::in, Start::in, Count::in, SubString::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	MR_Integer	len;
	MR_Word		tmp;

	if (Start < 0) Start = 0;
	if (Count <= 0) {
		MR_make_aligned_string(SubString, """");
	} else {
		len = strlen(Str);
		if (Start > len) Start = len;
		if (Count > len - Start) Count = len - Start;
		MR_allocate_aligned_string_msg(SubString, Count, MR_PROC_LABEL);
		MR_memcpy(SubString, Str + Start, Count);
		SubString[Count] = '\\0';
	}
}").

:- pragma foreign_proc("C",
	string__unsafe_substring(Str::in, Start::in, Count::in, SubString::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	MR_Integer len;

	MR_allocate_aligned_string_msg(SubString, Count, MR_PROC_LABEL);
	MR_memcpy(SubString, Str + Start, Count);
	SubString[Count] = '\\0';
}").
:- pragma foreign_proc("C#",
	string__unsafe_substring(Str::in, Start::in, Count::in, SubString::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	SubString = Str.Substring(Start, Count);
}").
:- pragma foreign_proc("Java",
	string__unsafe_substring(Str::in, Start::in, Count::in, SubString::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	SubString = Str.substring(Start, Start + Count);
").

:- pragma foreign_proc("C",
	string__split(Str::in, Count::in, Left::uo, Right::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	MR_Integer	len;
	MR_Word		tmp;

	if (Count <= 0) {
		MR_make_aligned_string(Left, """");
		Right = Str;
	} else {
		len = strlen(Str);
		if (Count > len) Count = len;
		MR_allocate_aligned_string_msg(Left, Count, MR_PROC_LABEL);
		MR_memcpy(Left, Str, Count);
		Left[Count] = '\\0';
		/*
		** We need to make a copy to ensure that the pointer is
		** word-aligned.
		*/
		MR_allocate_aligned_string_msg(Right, len - Count,
			MR_PROC_LABEL);
		strcpy(Right, Str + Count);
	}
}").

:- pragma foreign_proc("C#",
	string__split(Str::in, Count::in, Left::uo, Right::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	int len;
	if (Count <= 0) {
		Left = """";
		Right = Str;
	} else {
		len = Str.Length;
		if (Count > len) {
			Count = len;
		}
		Left = Str.Substring(0, Count);
		Right = Str.Substring(Count);
	}
}").

string__split(Str, Count, Left, Right) :-
	( Count =< 0 ->
		Left = "",
		copy(Str, Right)
	;
		string__to_char_list(Str, List),
		Len = string__length(Str),
		( Count > Len ->
			Num = Len
		;
			Num = Count
		),
		( list__split_list(Num, List, LeftList, RightList) ->
			string__to_char_list(Left, LeftList),
			string__to_char_list(Right, RightList)
		;
			error("string__split")
		)
	).

/*-----------------------------------------------------------------------*/

:- pragma foreign_proc("C",
	string__first_char(Str::in, First::in, Rest::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	SUCCESS_INDICATOR = (
		Str[0] == First &&
		First != '\\0' &&
		strcmp(Str + 1, Rest) == 0
	);
").
:- pragma foreign_proc("C#",
	string__first_char(Str::in, First::in, Rest::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	int len = Str.Length;
	SUCCESS_INDICATOR = (
		len > 0 &&
		Str[0] == First &&
		System.String.Compare(Str, 1, Rest, 0, len) == 0
	);
").
:- pragma foreign_proc("Java",
	string__first_char(Str::in, First::in, Rest::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	succeeded = (Str.length() == Rest.length() + 1 &&
		Str.charAt(0) == First &&
		Str.endsWith(Rest));
").

:- pragma foreign_proc("C",
	string__first_char(Str::in, First::uo, Rest::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	First = Str[0];
	SUCCESS_INDICATOR = (First != '\\0' && strcmp(Str + 1, Rest) == 0);
").
:- pragma foreign_proc("C#",
	string__first_char(Str::in, First::uo, Rest::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"
	int len = Str.Length;
	if (len > 0) {
		SUCCESS_INDICATOR =
			(System.String.Compare(Str, 1, Rest, 0, len) == 0);
		First = Str[0];
	} else {
		SUCCESS_INDICATOR = false;
	}
").
:- pragma foreign_proc("Java",
	string__first_char(Str::in, First::uo, Rest::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"

	if (Str.length() == Rest.length() + 1
		&& Str.endsWith(Rest))
	{
		succeeded = true;
		First = Str.charAt(0);
	} else {
		succeeded = false;
		// XXX to avoid uninitialized var warning
		First = (char) 0;
	}
").

:- pragma foreign_proc("C",
	string__first_char(Str::in, First::in, Rest::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	if (Str[0] != First || First == '\\0') {
		SUCCESS_INDICATOR = MR_FALSE;
	} else {
		Str++;
		/*
		** We need to make a copy to ensure that the pointer is
		** word-aligned.
		*/
		MR_allocate_aligned_string_msg(Rest, strlen(Str),
			MR_PROC_LABEL);
		strcpy(Rest, Str);
		SUCCESS_INDICATOR = MR_TRUE;
	}
}").
:- pragma foreign_proc("C#",
	string__first_char(Str::in, First::in, Rest::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	int len = Str.Length;
	if (len > 0) {
		SUCCESS_INDICATOR = (First == Str[0]);
		Rest = Str.Substring(1);
	} else {
		SUCCESS_INDICATOR = false;
	}
}").
:- pragma foreign_proc("Java",
	string__first_char(Str::in, First::in, Rest::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	int len = Str.length();
	if (len > 0) {
		succeeded = (First == Str.charAt(0));
		Rest = Str.substring(1);
	} else {
		succeeded = false;
		// XXX to avoid uninitialized var warning
		Rest = null;
	}
}").

:- pragma foreign_proc("C",
	string__first_char(Str::in, First::uo, Rest::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	First = Str[0];
	if (First == '\\0') {
		SUCCESS_INDICATOR = MR_FALSE;
	} else {
		Str++;
		/*
		** We need to make a copy to ensure that the pointer is
		** word-aligned.
		*/
		MR_allocate_aligned_string_msg(Rest, strlen(Str),
			MR_PROC_LABEL);
		strcpy(Rest, Str);
		SUCCESS_INDICATOR = MR_TRUE;
	}
}").
:- pragma foreign_proc("C#",
	string__first_char(Str::in, First::uo, Rest::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	if (Str.Length == 0) {
		SUCCESS_INDICATOR = false;
	} else {
		First = Str[0];
		Rest = Str.Substring(1);
		SUCCESS_INDICATOR = true;
	}
}").
:- pragma foreign_proc("Java",
	string__first_char(Str::in, First::uo, Rest::uo),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	if (Str.length() == 0) {
		succeeded = false;
		// XXX to avoid uninitialized var warnings:
		First = (char) 0;
		Rest = null;
	} else {
		First = Str.charAt(0);
		Rest = Str.substring(1);
		succeeded = true;
	}
}").

:- pragma foreign_proc("C",
	string__first_char(Str::uo, First::in, Rest::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	size_t len = strlen(Rest) + 1;
	MR_allocate_aligned_string_msg(Str, len, MR_PROC_LABEL);
	Str[0] = First;
	strcpy(Str + 1, Rest);
}").
:- pragma foreign_proc("C#",
	string__first_char(Str::uo, First::in, Rest::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	string FirstStr;
	FirstStr = new System.String(First, 1);
	Str = System.String.Concat(FirstStr, Rest);
}").
:- pragma foreign_proc("Java",
	string__first_char(Str::uo, First::in, Rest::in),
	[will_not_call_mercury, promise_pure, thread_safe],
"{
	java.lang.String FirstStr = java.lang.String.valueOf(First);
	Str = FirstStr.concat(Rest);
}").

%-----------------------------------------------------------------------------%
%-----------------------------------------------------------------------------%
% Ralph Becket <rwab1@cl.cam.ac.uk> 27/04/99
% Functional forms added.

string__length(S) = L :-
	string__length(S, L).

string__append(S1, S2) = S3 :-
	string__append(S1, S2, S3).

string__char_to_string(C) = S1 :-
	string__char_to_string(C, S1).

string__int_to_string(N) = S1 :-
	string__int_to_string(N, S1).

string__int_to_base_string(N1, N2) = S2 :-
	string__int_to_base_string(N1, N2, S2).

string__float_to_string(R) = S2 :-
	string__float_to_string(R, S2).

string__replace_all(S1, S2, S3) = S4 :-
	string__replace_all(S1, S2, S3, S4).

string__to_lower(S1) = S2 :-
	string__to_lower(S1, S2).

string__to_upper(S1) = S2 :-
	string__to_upper(S1, S2).

string__capitalize_first(S1) = S2 :-
	string__capitalize_first(S1, S2).

string__uncapitalize_first(S1) = S2 :-
	string__uncapitalize_first(S1, S2).

string__to_char_list(S) = Cs :-
	string__to_char_list(S, Cs).

string__from_char_list(Cs) = S :-
	string__from_char_list(Cs, S).

string__from_rev_char_list(Cs) = S :-
	string__from_rev_char_list(Cs, S).

string__pad_left(S1, C, N) = S2 :-
	string__pad_left(S1, C, N, S2).

string__pad_right(S1, C, N) = S2 :-
	string__pad_right(S1, C, N, S2).

string__duplicate_char(C, N) = S :-
	string__duplicate_char(C, N, S).

string__index_det(S, N) = C :-
	string__index_det(S, N, C).

string__unsafe_index(S, N) = C :-
	string__unsafe_index(S, N, C).

string__set_char_det(C, N, S0) = S :-
	string__set_char_det(C, N, S0, S).

string__unsafe_set_char(C, N, S0) = S :-
	string__unsafe_set_char(C, N, S0, S).

string__foldl(F, S, A) = B :-
	P = ( pred(X::in, Y::in, Z::out) is det :- Z = F(X, Y) ),
	string__foldl(P, S, A, B).

string__foldl_substring(F, S, Start, Count, A) = B :-
	P = ( pred(X::in, Y::in, Z::out) is det :- Z = F(X, Y) ),
	string__foldl_substring(P, S, Start, Count, A, B).

string__left(S1, N) = S2 :-
	string__left(S1, N, S2).

string__right(S1, N) = S2 :-
	string__right(S1, N, S2).

string__substring(S1, N1, N2) = S2 :-
	string__substring(S1, N1, N2, S2).

string__unsafe_substring(S1, N1, N2) = S2 :-
	string__unsafe_substring(S1, N1, N2, S2).

string__hash(S) = N :-
	string__hash(S, N).

string__format(S1, PT) = S2 :-
	string__format(S1, PT, S2).

%------------------------------------------------------------------------------%

string__words(SepP, String) = Words :-
	I = preceding_boundary(isnt(SepP), String, string__length(String) - 1),
	Words = words_2(SepP, String, I, []).

%------------------------------------------------------------------------------%

:- func words_2(pred(char)::in(pred(in) is semidet), string::in, int::in,
	list(string)::in) = (list(string)::out) is det.

words_2(SepP, String, WordEnd, Words0) = Words :-
	( WordEnd < 0 ->
		Words = Words0
	;
		WordPre = preceding_boundary(SepP, String, WordEnd),
		Word = string__unsafe_substring(String, WordPre + 1,
			WordEnd - WordPre),
		PrevWordEnd = preceding_boundary(isnt(SepP), String, WordPre),
		Words = words_2(SepP, String, PrevWordEnd, [Word | Words0])
	).

%------------------------------------------------------------------------------%

string__words(String) = string__words(char__is_whitespace, String).

%------------------------------------------------------------------------------%

	% preceding_boundary(SepP, String, I) returns the largest index J =< I
	% in String of the char that is SepP and min(-1, I) if there is no
	% such J. preceding_boundary/3 is intended for finding (in reverse)
	% consecutive maximal sequences of chars satisfying some property.
	% Note that I *must not* exceed the largest valid index for String.

:- func preceding_boundary(pred(char)::in(pred(in) is semidet), string::in,
	int::in) = (int::out) is det.

preceding_boundary(SepP, String, I) =
	( I < 0 ->
		I
	; SepP(string__unsafe_index(String, I)) ->
		I
	;
		preceding_boundary(SepP, String, I - 1)
	).

%------------------------------------------------------------------------------%

S1 ++ S2 = string__append(S1, S2).

%------------------------------------------------------------------------------%

string__det_to_int(S) = string__det_base_string_to_int(10, S).

%------------------------------------------------------------------------------%

string__det_base_string_to_int(Base, S) = N :-
	( string__base_string_to_int(Base, S, N0) ->
		N = N0
	;
		error("string__det_base_string_to_int/2: conversion failed")
	).

%-----------------------------------------------------------------------------%

chomp(S) =
	( index(S, length(S) - 1, '\n') ->
		left(S, length(S) - 1)
	;
		S
	).

%-----------------------------------------------------------------------------%

rstrip(S) = rstrip(is_whitespace, S).

%-----------------------------------------------------------------------------%

lstrip(S) = lstrip(is_whitespace, S).

%-----------------------------------------------------------------------------%

strip(S0) = S :-
	L = prefix_length(is_whitespace, S0),
	R = suffix_length(is_whitespace, S0),
	S = substring(S0, L, length(S0) - L - R).

%-----------------------------------------------------------------------------%

rstrip(P, S) = left(S, length(S) - suffix_length(P, S)).

%-----------------------------------------------------------------------------%

lstrip(P, S) = right(S, length(S) - prefix_length(P, S)).

%-----------------------------------------------------------------------------%

prefix_length(P, S) = prefix_length_2(0, length(S), P, S).

:- func prefix_length_2(int::in, int::in, pred(char)::in(pred(in) is semidet),
	string::in) = (int::out) is det.

prefix_length_2(I, N, P, S) =
	% XXX We are using if-then-elses to get ordered conjunction.
	( I < N ->
		( P(S ^ unsafe_elem(I)) ->
			prefix_length_2(I + 1, N, P, S)
		;
			I
		)
	;
		I
	).

%-----------------------------------------------------------------------------%

suffix_length(P, S) = suffix_length_2(length(S) - 1, length(S), P, S).

:- func suffix_length_2(int::in, int::in, pred(char)::in(pred(in) is semidet),
	string::in) = (int::out) is det.

suffix_length_2(I, N, P, S) =
	% XXX We are using if-then-elses to get ordered conjunction.
	( 0 =< I ->
		( P(S ^ unsafe_elem(I)) ->
			suffix_length_2(I - 1, N, P, S)
		;
			N - (I + 1)
		)
	;
		N - (I + 1)
	).

%------------------------------------------------------------------------------%

	% For efficiency, these predicates collect a list of strings
	% which, when concatenated in reverse order, produce the final
	% output.
	%
:- type revstrings == list(string).

	% Utility predicate.
	%
:- pred add_revstring(string, revstrings, revstrings).
:- mode add_revstring(in,     in,         out       ) is det.

add_revstring(String, RevStrings, [String | RevStrings]).



% various different versions of univ_to_string.

string__string(Univ) = String :-
	string__string(canonicalize, ops__init_mercury_op_table, Univ, String).

string__string(OpsTable, Univ) = String :-
	string__string(canonicalize, OpsTable, Univ, String).



string__string(NonCanon, OpsTable, X, String) :-
	value_to_revstrings(NonCanon, OpsTable, X, [], RevStrings),
	String = string__append_list(list__reverse(RevStrings)).



:- pred value_to_revstrings(deconstruct__noncanon_handling,
	ops__table, T, revstrings, revstrings).
:- mode value_to_revstrings(in(do_not_allow), in, in, in, out) is det.
:- mode value_to_revstrings(in(canonicalize), in, in, in, out) is det.
:- mode value_to_revstrings(in(include_details_cc), in, in, in, out)
	is cc_multi.
:- mode value_to_revstrings(in, in, in, in, out)
	is cc_multi.

value_to_revstrings(NonCanon, OpsTable, X, !Rs) :-
	Priority = ops__max_priority(OpsTable) + 1,
	value_to_revstrings(NonCanon, OpsTable, Priority, X, !Rs).



:- pred value_to_revstrings(deconstruct__noncanon_handling,
	ops__table, ops__priority, T, revstrings, revstrings).
:- mode value_to_revstrings(in(do_not_allow), in, in, in, in, out) is det.
:- mode value_to_revstrings(in(canonicalize), in, in, in, in, out) is det.
:- mode value_to_revstrings(in(include_details_cc), in, in, in, in, out)
	is cc_multi.
:- mode value_to_revstrings(in, in, in, in, in, out)
	is cc_multi.

value_to_revstrings(NonCanon, OpsTable, Priority, X, !Rs) :-
	%
	% we need to special-case the builtin types:
	%	int, char, float, string
	%	type_info, univ, c_pointer, array
	%	and private_builtin:type_info
	%
	( dynamic_cast(X, String) ->
		add_revstring(term_io__quoted_string(String), !Rs)
	; dynamic_cast(X, Char) ->
		add_revstring(term_io__quoted_char(Char), !Rs)
	; dynamic_cast(X, Int) ->
		add_revstring(string__int_to_string(Int), !Rs)
	; dynamic_cast(X, Float) ->
		add_revstring(string__float_to_string(Float), !Rs)
	; dynamic_cast(X, TypeDesc) ->
		type_desc_to_revstrings(TypeDesc, !Rs)
	; dynamic_cast(X, TypeCtorDesc) ->
		type_ctor_desc_to_revstrings(TypeCtorDesc, !Rs)
	; dynamic_cast(X, C_Pointer) ->
		add_revstring(c_pointer_to_string(C_Pointer), !Rs)
	;
		%
		% Check if the type is array:array/1.
		% We can't just use dynamic_cast here since 
		% array:array/1 is a polymorphic type.
		%
		% The calls to type_ctor_name and type_ctor_module_name
		% are not really necessary -- we could use dynamic_cast
		% in the condition instead of det_dynamic_cast in the body.
		% However, this way of doing things is probably more efficient
		% in the common case when the thing being printed is
		% *not* of type array:array/1.
		%
		% The ordering of the tests here (arity, then name, then
		% module name, rather than the reverse) is also chosen
		% for efficiency, to find failure cheaply in the common cases,
		% rather than for readability.
		%
		type_desc__type_ctor_and_args(type_of(X), TypeCtor, ArgTypes),
		ArgTypes = [ElemType],
		type_desc__type_ctor_name(TypeCtor) = "array",
		type_desc__type_ctor_module_name(TypeCtor) = "array"
	->
		%
		% Now that we know the element type, we can
		% constrain the type of the variable `Array'
		% so that we can use det_dynamic_cast.
		%
		type_desc__has_type(Elem, ElemType),
		same_array_elem_type(Array, Elem),
		det_dynamic_cast(X, Array),
		array_to_revstrings(NonCanon, OpsTable, Array, !Rs)
	; 
		%
		% Check if the type is private_builtin:type_info/1.
		% See the comments above for array:array/1.
		%
		type_desc__type_ctor_and_args(type_of(X), TypeCtor, ArgTypes),
		ArgTypes = [ElemType],
		type_desc__type_ctor_name(TypeCtor) = "type_info",
		type_desc__type_ctor_module_name(TypeCtor) = "private_builtin"
	->
		type_desc__has_type(Elem, ElemType),
		same_private_builtin_type(PrivateBuiltinTypeInfo, Elem),
		det_dynamic_cast(X, PrivateBuiltinTypeInfo),
		private_builtin_type_info_to_revstrings(
			PrivateBuiltinTypeInfo, !Rs)
	; 
		ordinary_term_to_revstrings(NonCanon, OpsTable, Priority,
			X, !Rs)
	).



:- pred same_array_elem_type(array(T), T).
:- mode same_array_elem_type(unused, unused) is det.
same_array_elem_type(_, _).



:- pred same_private_builtin_type(private_builtin__type_info(T), T).
:- mode same_private_builtin_type(unused, unused) is det.
same_private_builtin_type(_, _).



:- pred ordinary_term_to_revstrings(deconstruct__noncanon_handling,
	ops__table, ops__priority, T, revstrings, revstrings).
:- mode ordinary_term_to_revstrings(in(do_not_allow), in, in, in, in, out)
	is det.
:- mode ordinary_term_to_revstrings(in(canonicalize), in, in, in, in, out)
	is det.
:- mode ordinary_term_to_revstrings(in(include_details_cc), in, in, in, in, out)
	is cc_multi.
:- mode ordinary_term_to_revstrings(in, in, in, in, in, out)
	is cc_multi.

ordinary_term_to_revstrings(NonCanon, OpsTable, Priority, X, !Rs) :-
	deconstruct__deconstruct(X, NonCanon, Functor, _Arity, Args),
	(
		Functor = "[|]",
		Args = [ListHead, ListTail]
	->
		add_revstring("[", !Rs),
		arg_to_revstrings(NonCanon, OpsTable, ListHead, !Rs),
		univ_list_tail_to_revstrings(NonCanon, OpsTable, ListTail, 
			!Rs),
		add_revstring("]", !Rs)
	;
		Functor = "[]",
		Args = []
	->
		add_revstring("[]", !Rs)
	;
		Functor = "{}",
		Args = [BracedTerm]
	->
		add_revstring("{ ", !Rs),
		value_to_revstrings(NonCanon, OpsTable,
			univ_value(BracedTerm), !Rs),
		add_revstring(" }", !Rs)
	;
		Functor = "{}",
		Args = [BracedHead | BracedTail]
	->
		add_revstring("{", !Rs),
		arg_to_revstrings(NonCanon, OpsTable, BracedHead, !Rs),
		term_args_to_revstrings(NonCanon, OpsTable, BracedTail, !Rs),
		add_revstring("}", !Rs)
	;
		Args = [PrefixArg],
		ops__lookup_prefix_op(OpsTable, Functor,
			OpPriority, OpAssoc)
	->
		maybe_add_revstring("(", Priority, OpPriority, !Rs),
		add_revstring(term_io__quoted_atom(Functor), !Rs),
		add_revstring(" ", !Rs),
		adjust_priority(OpPriority, OpAssoc, NewPriority),
		value_to_revstrings(NonCanon, OpsTable, NewPriority,
			univ_value(PrefixArg), !Rs),
		maybe_add_revstring(")", Priority, OpPriority, !Rs)
	;
		Args = [PostfixArg],
		ops__lookup_postfix_op(OpsTable, Functor,
			OpPriority, OpAssoc)
	->
		maybe_add_revstring("(", Priority, OpPriority, !Rs),
		adjust_priority(OpPriority, OpAssoc, NewPriority),
		value_to_revstrings(NonCanon, OpsTable, NewPriority,
			univ_value(PostfixArg), !Rs),
		add_revstring(" ", !Rs),
		add_revstring(term_io__quoted_atom(Functor), !Rs),
		maybe_add_revstring(")", Priority, OpPriority, !Rs)
	;
		Args = [Arg1, Arg2],
		ops__lookup_infix_op(OpsTable, Functor, 
			OpPriority, LeftAssoc, RightAssoc)
	->
		maybe_add_revstring("(", Priority, OpPriority, !Rs),
		adjust_priority(OpPriority, LeftAssoc, LeftPriority),
		value_to_revstrings(NonCanon, OpsTable, LeftPriority,
			univ_value(Arg1), !Rs),
		( Functor = "," ->
			add_revstring(", ", !Rs)
		;
			add_revstring(" ", !Rs),
			add_revstring(term_io__quoted_atom(Functor), !Rs),
			add_revstring(" ", !Rs)
		),
		adjust_priority(OpPriority, RightAssoc, RightPriority),
		value_to_revstrings(NonCanon, OpsTable, RightPriority,
			univ_value(Arg2), !Rs),
		maybe_add_revstring(")", Priority, OpPriority, !Rs)
	;
		Args = [Arg1, Arg2],
		ops__lookup_binary_prefix_op(OpsTable, Functor,
			OpPriority, FirstAssoc, SecondAssoc)
	->
		maybe_add_revstring("(", Priority, OpPriority, !Rs),
		add_revstring(term_io__quoted_atom(Functor), !Rs),
		add_revstring(" ", !Rs),
		adjust_priority(OpPriority, FirstAssoc, FirstPriority),
		value_to_revstrings(NonCanon, OpsTable, FirstPriority,
			univ_value(Arg1), !Rs),
		add_revstring(" ", !Rs),
		adjust_priority(OpPriority, SecondAssoc, SecondPriority),
		value_to_revstrings(NonCanon, OpsTable, SecondPriority,
			univ_value(Arg2), !Rs),
		maybe_add_revstring(")", Priority, OpPriority, !Rs)
	;
		(
			Args = [],
			ops__lookup_op(OpsTable, Functor),
			Priority =< ops__max_priority(OpsTable)
		->
			add_revstring("(", !Rs),
			add_revstring(term_io__quoted_atom(Functor), !Rs),
			add_revstring(")", !Rs)
		;
			add_revstring(
				term_io__quoted_atom(Functor,
				    term_io__maybe_adjacent_to_graphic_token),
				!Rs
			)
		),
		(
			Args = [Y | Ys]
		->
			add_revstring("(", !Rs),
			arg_to_revstrings(NonCanon, OpsTable, Y, !Rs),
			term_args_to_revstrings(NonCanon, OpsTable, Ys, !Rs),
			add_revstring(")", !Rs)
		;
			true
		)
	).



:- pred maybe_add_revstring(string, ops__priority, ops__priority,
			revstrings, revstrings).
:- mode maybe_add_revstring(in, in, in, in, out) is det.

maybe_add_revstring(String, Priority, OpPriority, !Rs) :-
	( OpPriority > Priority ->
		add_revstring(String, !Rs)
	;
		true
	).



:- pred adjust_priority(ops__priority, ops__assoc, ops__priority).
:- mode adjust_priority(in, in, out) is det.

adjust_priority(Priority, ops__y, Priority).
adjust_priority(Priority, ops__x, Priority - 1).



:- pred univ_list_tail_to_revstrings(deconstruct__noncanon_handling,
	ops__table, univ, revstrings, revstrings).
:- mode univ_list_tail_to_revstrings(in(do_not_allow), in, in, in, out) is det.
:- mode univ_list_tail_to_revstrings(in(canonicalize), in, in, in, out) is det.
:- mode univ_list_tail_to_revstrings(in(include_details_cc), in, in, in, out)
	is cc_multi.
:- mode univ_list_tail_to_revstrings(in, in, in, in, out) is cc_multi.

univ_list_tail_to_revstrings(NonCanon, OpsTable, Univ, !Rs) :-
	deconstruct__deconstruct(univ_value(Univ), NonCanon, Functor, _Arity, 
		Args),
	( Functor = "[|]", Args = [ListHead, ListTail] ->
		add_revstring(", ", !Rs),
		arg_to_revstrings(NonCanon, OpsTable, ListHead, !Rs),
		univ_list_tail_to_revstrings(NonCanon, OpsTable, ListTail, !Rs)
	; Functor = "[]", Args = [] ->
		true
	;
		add_revstring(" | ", !Rs),
		value_to_revstrings(NonCanon, OpsTable, univ_value(Univ), !Rs)
	).



:- pred term_args_to_revstrings(deconstruct__noncanon_handling,
	ops__table, list(univ), revstrings, revstrings).
:- mode term_args_to_revstrings(in(do_not_allow), in, in, in, out) is det.
:- mode term_args_to_revstrings(in(canonicalize), in, in, in, out) is det.
:- mode term_args_to_revstrings(in(include_details_cc), in, in, in, out)
	is cc_multi.
:- mode term_args_to_revstrings(in, in, in, in, out) is cc_multi.

	% write the remaining arguments
term_args_to_revstrings(_, _, [], !Rs).
term_args_to_revstrings(NonCanon, OpsTable, [X|Xs], !Rs) :-
	add_revstring(", ", !Rs),
	arg_to_revstrings(NonCanon, OpsTable, X, !Rs),
	term_args_to_revstrings(NonCanon, OpsTable, Xs, !Rs).



:- pred arg_to_revstrings(deconstruct__noncanon_handling,
	ops__table, univ, revstrings, revstrings).
:- mode arg_to_revstrings(in(do_not_allow), in, in, in, out) is det.
:- mode arg_to_revstrings(in(canonicalize), in, in, in, out) is det.
:- mode arg_to_revstrings(in(include_details_cc), in, in, in, out) is cc_multi.
:- mode arg_to_revstrings(in, in, in, in, out) is cc_multi.

arg_to_revstrings(NonCanon, OpsTable, X, !Rs) :-
	Priority = comma_priority(OpsTable),
	value_to_revstrings(NonCanon, OpsTable, Priority, univ_value(X), !Rs).



:- func comma_priority(ops__table) = ops__priority.
/*
comma_priority(OpsTable) =
	( if ops__lookup_infix_op(OpTable, ",", Priority, _, _) then
		Priority
	  else
		func_error("arg_priority: can't find the priority of `,'")
	).
*/
% We could implement this as above, but it's more efficient to just
% hard-code it.
comma_priority(_OpTable) = 1000.



:- func c_pointer_to_string(c_pointer) = string.

c_pointer_to_string(_C_Pointer) = "<<c_pointer>>".



:- pred array_to_revstrings(deconstruct__noncanon_handling,
	ops__table, array(T), revstrings, revstrings).
:- mode array_to_revstrings(in(do_not_allow), in, in, in, out) is det.
:- mode array_to_revstrings(in(canonicalize), in, in, in, out) is det.
:- mode array_to_revstrings(in(include_details_cc), in, in, in, out)
	is cc_multi.
:- mode array_to_revstrings(in, in, in, in, out)
	is cc_multi.

array_to_revstrings(NonCanon, OpsTable, Array, !Rs) :-
	add_revstring("array(", !Rs),
	value_to_revstrings(NonCanon, OpsTable,
		array__to_list(Array) `with_type` list(T), !Rs),
	add_revstring(")", !Rs).



:- pred type_desc_to_revstrings(type_desc__type_desc, revstrings, revstrings).
:- mode type_desc_to_revstrings(in, in, out) is det.

type_desc_to_revstrings(TypeDesc, !Rs) :-
	add_revstring(
		term_io__quoted_atom(type_desc__type_name(TypeDesc)),
		!Rs
	).



:- pred type_ctor_desc_to_revstrings(type_desc__type_ctor_desc,
	revstrings, revstrings).
:- mode type_ctor_desc_to_revstrings(in, in, out) is det.

type_ctor_desc_to_revstrings(TypeCtorDesc, !Rs) :-
        type_desc__type_ctor_name_and_arity(TypeCtorDesc,
		ModuleName, Name0, Arity0),
	Name = term_io__quoted_atom(Name0),
	( ModuleName = "builtin", Name = "func" ->
		% The type ctor that we call `builtin:func/N' takes N + 1
		% type parameters: N arguments plus one return value.
		% So we need to subtract one from the arity here.
		Arity = Arity0 - 1
	;
		Arity = Arity0
	),
	( ModuleName = "builtin" ->
		String = string__format("%s/%d", [s(Name), i(Arity)])
	;
		String = string__format("%s.%s/%d",
			[s(ModuleName), s(Name), i(Arity)])
	),
	add_revstring(String, !Rs).



:- pred private_builtin_type_info_to_revstrings(
		private_builtin__type_info(T), revstrings, revstrings).
:- mode private_builtin_type_info_to_revstrings(in, in, out) is det.

private_builtin_type_info_to_revstrings(PrivateBuiltinTypeInfo, !Rs) :-
	TypeDesc = rtti_implementation__unsafe_cast(PrivateBuiltinTypeInfo),
	type_desc_to_revstrings(TypeDesc, !Rs).



:- pred det_dynamic_cast(T1, T2).
:- mode det_dynamic_cast(in, out) is det.

det_dynamic_cast(X, Y) :-
	det_univ_to_type(univ(X), Y).

%-----------------------------------------------------------------------------%

% char_list_remove_suffix/3: We use this instead of the more general
% list__remove_suffix so that (for example) string__format will succeed in
% grade Java, even though unification has not yet been implemented.

:- pred char_list_remove_suffix(list(char)::in, list(char)::in,
	list(char)::out) is semidet.

char_list_remove_suffix(List, Suffix, Prefix) :-
	list__length(List, ListLength),
	list__length(Suffix, SuffixLength),
	PrefixLength = ListLength - SuffixLength,
	list__split_list(PrefixLength, List, Prefix, Rest),
	char_list_equal(Suffix, Rest).

:- pred char_list_equal(list(char)::in, list(char)::in) is semidet.

char_list_equal([], []).
char_list_equal([X | Xs], [X | Ys]) :-
	char_list_equal(Xs, Ys).

%------------------------------------------------------------------------------%

:- end_module string.

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%
