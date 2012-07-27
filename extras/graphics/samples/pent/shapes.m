%------------------------------------------------------------------------------%
% file: shapes.m
% author: Tyson Dowd, August 1997
%
% Stores that shapes. 
%
% This source file is hereby placed in the public domain. -Tyson Dowd
% (the author).
%
%------------------------------------------------------------------------------%

:- module shapes.

:- interface.

:- import_module place_pent.

:- pred get_piece(piece, piece_descriptor).
:- mode get_piece(in, out) is multidet.

:- implementation.

:- import_module require, list, std_util.

%     L         N     T       F         Z       U
%     |         |     |       |         |       |
% []  [][]      []  [][][]  [][]      [][]    [][][]
% []  []    []  []    []      [][]      []    []  []
% []  []    []  [][]  []  []  []    []  [][]           []
% []  []  [][]    []      []      [][]        [][]   [][][]
% []        []        [][][]    [][]        [][][]     []
% |         |           |         |           |        |
% I         Y           V         W           P        X

get_piece(i, [0, 1, 2, 3, 4]).
get_piece(i, [0, 65536, 131072, 196608, 262144]).
get_piece(l, [0, 1, 2, 3, 65536]).
get_piece(l, [0, 1, 2, 3, 65539]).
get_piece(l, [0, 1, 65536, 131072, 196608]).
get_piece(l, [0, 1, 65537, 131073, 196609]).
get_piece(l, [0, 65536, 65537, 65538, 65539]).
get_piece(l, [0, 65536, 131072, 196608, 196609]).
get_piece(l, [1, 65537, 131073, 196608, 196609]).
get_piece(l, [3, 65536, 65537, 65538, 65539]).
get_piece(y, [0, 1, 2, 3, 65537]).
get_piece(y, [0, 1, 2, 3, 65538]).
get_piece(y, [0, 65536, 65537, 131072, 196608]).
get_piece(y, [0, 65536, 131072, 131073, 196608]).
get_piece(y, [1, 65536, 65537, 65538, 65539]).
get_piece(y, [1, 65536, 65537, 131073, 196609]).
get_piece(y, [1, 65537, 131072, 131073, 196609]).
get_piece(y, [2, 65536, 65537, 65538, 65539]).
get_piece(n, [0, 1, 2, 65538, 65539]).
get_piece(n, [0, 1, 65537, 65538, 65539]).
get_piece(n, [0, 65536, 65537, 131073, 196609]).
get_piece(n, [0, 65536, 131072, 131073, 196609]).
get_piece(n, [1, 2, 3, 65536, 65537]).
get_piece(n, [1, 65536, 65537, 131072, 196608]).
get_piece(n, [1, 65537, 131072, 131073, 196608]).
get_piece(n, [2, 3, 65536, 65537, 65538]).
get_piece(t, [0, 1, 2, 65537, 131073]).
get_piece(t, [0, 65536, 65537, 65538, 131072]).
get_piece(t, [1, 65537, 131072, 131073, 131074]).
get_piece(t, [2, 65536, 65537, 65538, 131074]).
get_piece(v, [0, 1, 2, 65536, 131072]).
get_piece(v, [0, 1, 2, 65538, 131074]).
get_piece(v, [0, 65536, 131072, 131073, 131074]).
get_piece(v, [2, 65538, 131072, 131073, 131074]).
get_piece(f, [0, 65536, 65537, 65538, 131073]).
get_piece(f, [1, 65537, 65538, 131072, 131073]).
get_piece(w, [0, 1, 65537, 65538, 131074]).
get_piece(w, [0, 65536, 65537, 131073, 131074]).
get_piece(w, [1, 2, 65536, 65537, 131072]).
get_piece(w, [2, 65537, 65538, 131072, 131073]).
get_piece(z, [0, 1, 65537, 131073, 131074]).
get_piece(z, [0, 65536, 65537, 65538, 131074]).
get_piece(z, [1, 2, 65537, 131072, 131073]).
get_piece(z, [2, 65536, 65537, 65538, 131072]).
get_piece(p, [0, 1, 2, 65536, 65537]).
get_piece(p, [0, 1, 2, 65537, 65538]).
get_piece(p, [0, 1, 65536, 65537, 65538]).
get_piece(p, [0, 1, 65536, 65537, 131072]).
get_piece(p, [0, 1, 65536, 65537, 131073]).
get_piece(p, [0, 65536, 65537, 131072, 131073]).
get_piece(p, [1, 2, 65536, 65537, 65538]).
get_piece(p, [1, 65536, 65537, 131072, 131073]).
get_piece(u, [0, 1, 2, 65536, 65538]).
get_piece(u, [0, 1, 65536, 131072, 131073]).
get_piece(u, [0, 1, 65537, 131072, 131073]).
get_piece(u, [0, 2, 65536, 65537, 65538]).
get_piece(x, [1, 65536, 65537, 65538, 131073]).
get_piece(e, _) :-
	error("tried to lookup piece 'e'").
