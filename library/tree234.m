%---------------------------------------------------------------------------%
% Copyright (C) 1995 University of Melbourne.
% This file may only be copied under the terms of the GNU Library General
% Public License - see the file COPYING.LIB in the Mercury distribution.
%---------------------------------------------------------------------------%

% tree234 - implements a map (dictionary) using 2-3-4 trees.
% main author: conway.
% stability: medium.

% See map.m for documentation.

%---------------------------------------------------------------------------%

:- module tree234.

:- interface.

:- import_module list, std_util, assoc_list.

:- type tree234(K, V).

:- pred tree234__init(tree234(K, V)).
:- mode tree234__init(uo) is det.

:- pred tree234__member(tree234(K, V), K, V).
:- mode tree234__member(in, out, out) is nondet.

:- pred tree234__search(tree234(K, V), K, V).
:- mode tree234__search(in, in, out) is semidet.

:- pred tree234__lookup(tree234(K, V), K, V).
:- mode tree234__lookup(in, in, out) is det.

:- pred tree234__insert(tree234(K, V), K, V, tree234(K, V)).
:- mode tree234__insert(in, in, in, out) is semidet.
% :- mode tree234__insert(di_tree234, in, in, uo_tree234) is semidet.
% :- mode tree234__insert(in, in, in, out) is semidet.

:- pred tree234__set(tree234(K, V), K, V, tree234(K, V)).
:- mode tree234__set(di, di, di, uo) is det.
% :- mode tree234__set(di_tree234, in, in, uo_tree234) is det.
:- mode tree234__set(in, in, in, out) is det.

:- pred tree234__delete(tree234(K, V), K, tree234(K, V)).
:- mode tree234__delete(di, in, uo) is det.
% :- mode tree234__delete(di_tree234, in, uo_tree234) is det.
:- mode tree234__delete(in, in, out) is det.

:- pred tree234__remove(tree234(K, V), K, V, tree234(K, V)).
:- mode tree234__remove(di, in, uo, uo) is semidet.
% :- mode tree234__remove(di_tree234, in, out, uo_tree234) is semidet.
:- mode tree234__remove(in, in, out, out) is semidet.

:- pred tree234__remove_smallest(tree234(K, V), K, V, tree234(K, V)).
:- mode tree234__remove_smallest(di, uo, uo, uo) is semidet.
% :- mode tree234__remove_smallest(di_tree234, out, out, uo_tree234) is semidet.
:- mode tree234__remove_smallest(in, out, out, out) is semidet.

:- pred tree234__keys(tree234(K, V), list(K)).
:- mode tree234__keys(in, out) is det.

:- pred tree234__values(tree234(K, V), list(V)).
:- mode tree234__values(in, out) is det.

:- pred tree234__update(tree234(K, V), K, V, tree234(K, V)).
:- mode tree234__update(in, in, in, out) is semidet.
% :- mode tree234__update(di_tree234, in, in, uo_tree234) is det.
% :- mode tree234__update(di, di, di, uo) is semidet.

	% count the number of elements in a tree
:- pred tree234__count(tree234(K, V), int).
:- mode tree234__count(in, out) is det.

:- pred tree234__assoc_list_to_tree234(assoc_list(K, V), tree234(K, V)).
:- mode tree234__assoc_list_to_tree234(in, out) is det.

:- pred tree234__tree234_to_assoc_list(tree234(K, V), assoc_list(K, V)).
:- mode tree234__tree234_to_assoc_list(in, out) is det.

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%

:- implementation.

:- import_module int, require, bool.

:- type tree234(K, V)	--->
		empty
	;	two(K, V, tree234(K, V), tree234(K, V))
	;	three(K, V, K, V, tree234(K, V), tree234(K, V), tree234(K, V))
	;	four(K, V, K, V, K, V, tree234(K, V), tree234(K, V),
			tree234(K, V), tree234(K, V)).

:- interface.

:- inst uniq_tree234(K, V) =
	unique((
		empty
	;	two(K, V, uniq_tree234(K, V), uniq_tree234(K, V))
	;	three(K, V, K, V, uniq_tree234(K, V), uniq_tree234(K, V),
			uniq_tree234(K, V))
	;	four(K, V, K, V, K, V, uniq_tree234(K, V), uniq_tree234(K, V),
			uniq_tree234(K, V), uniq_tree234(K, V))
	)).

:- inst uniq_tree234_gg =
	unique((
		empty
	;	two(ground, ground, uniq_tree234_gg, uniq_tree234_gg)
	;	three(ground, ground, ground, ground,
			uniq_tree234_gg, uniq_tree234_gg, uniq_tree234_gg)
	;	four(ground, ground, ground, ground, ground, ground,
			uniq_tree234_gg, uniq_tree234_gg,
			uniq_tree234_gg, uniq_tree234_gg)
	)).

:- mode di_tree234(K, V) :: uniq_tree234(K, V) -> dead.
:- mode di_tree234       :: uniq_tree234(ground, ground) -> dead.
:- mode uo_tree234(K, V) :: free -> uniq_tree234(K, V).
:- mode uo_tree234       :: free -> uniq_tree234(ground, ground).

:- implementation.

%------------------------------------------------------------------------------%

tree234__init(empty).

%------------------------------------------------------------------------------%

tree234__member(empty, _K, _V) :- fail.
tree234__member(two(K0, V0, T0, T1), K, V) :-
	(
		K = K0,
		V = V0
	;
		tree234__member(T0, K, V)
	;
		tree234__member(T1, K, V)
	).
tree234__member(three(K0, V0, K1, V1, T0, T1, T2), K, V) :-
	(
		K = K0,
		V = V0
	;
		K = K1,
		V = V1
	;
		tree234__member(T0, K, V)
	;
		tree234__member(T1, K, V)
	;
		tree234__member(T2, K, V)
	).
tree234__member(four(K0, V0, K1, V1, K2, V2, T0, T1, T2, T3), K, V) :-
	(
		K = K0,
		V = V0
	;
		K = K1,
		V = V1
	;
		K = K2,
		V = V2
	;
		tree234__member(T0, K, V)
	;
		tree234__member(T1, K, V)
	;
		tree234__member(T2, K, V)
	;
		tree234__member(T3, K, V)
	).

%------------------------------------------------------------------------------%

tree234__search(T, K, V) :-
	(
		T = empty,
		fail
	;
		T = two(K0, _, _, _),
		compare(Result, K, K0),
		(
			Result = (<),
			T = two(_, _, T0, _),
			tree234__search(T0, K, V)
		;
			Result = (=),
			T = two(_, V0, _, _),
			V = V0
		;
			Result = (>),
			T = two(_, _, _, T1),
			tree234__search(T1, K, V)
		)
	;
		T = three(K0, _, _, _, _, _, _),
		compare(Result0, K, K0),
		(
			Result0 = (<),
			T = three(_, _, _, _, T0, _, _),
			tree234__search(T0, K, V)
		;
			Result0 = (=),
			T = three(_, V0, _, _, _, _, _),
			V = V0
		;
			Result0 = (>),
			T = three(_, _, K1, _, _, _, _),
			compare(Result1, K, K1),
			(
				Result1 = (<),
				T = three(_, _, _, _, _, T1, _),
				tree234__search(T1, K, V)
			;
				Result1 = (=),
				T = three(_, _, _, V1, _, _, _),
				V = V1
			;
				Result1 = (>),
				T = three(_, _, _, _, _, _, T2),
				tree234__search(T2, K, V)
			)
		)
	;
		T = four(_, _, K1, _, _, _, _, _, _, _),
		compare(Result1, K, K1),
		(
			Result1 = (<),
			T = four(K0, _, _, _, _, _, _, _, _, _),
			compare(Result0, K, K0),
			(
				Result0 = (<),
				T = four(_, _, _, _, _, _, T0, _, _, _),
				tree234__search(T0, K, V)
			;
				Result0 = (=),
				T = four(_, V0, _, _, _, _, _, _, _, _),
				V = V0
			;
				Result0 = (>),
				T = four(_, _, _, _, _, _, _, T1, _, _),
				tree234__search(T1, K, V)
			)
		;
			Result1 = (=),
			T = four(_, _, _, V1, _, _, _, _, _, _),
			V = V1
		;
			Result1 = (>),
			T = four(_, _, _, _, K2, _, _, _, _, _),
			compare(Result2, K, K2),
			(
				Result2 = (<),
				T = four(_, _, _, _, _, _, _, _, T2, _),
				tree234__search(T2, K, V)
			;
				Result2 = (=),
				T = four(_, _, _, _, _, V2, _, _, _, _),
				V = V2
			;
				Result2 = (>),
				T = four(_, _, _, _, _, _, _, _, _, T3),
				tree234__search(T3, K, V)
			)
		)
	).

%------------------------------------------------------------------------------%

tree234__update(Tin, K, V, Tout) :-
	(
		Tin = empty,
		fail
	;
		Tin = two(K0, _, _, _),
		compare(Result, K, K0),
		(
			Result = (<),
			Tin = two(_, _, T0, _),
			tree234__update(T0, K, V, NewT0),
			Tin = two(_, V0, _, T1),
			Tout = two(K0, V0, NewT0, T1)
		;
			Result = (=),
			Tin = two(_, _, T0, T1),
			Tout = two(K0, V, T0, T1)
		;
			Result = (>),
			Tin = two(_, _, _, T1),
			tree234__update(T1, K, V, NewT1),
			Tin = two(_, V0, T0, _),
			Tout = two(K0, V0, T0, NewT1)
		)
	;
		Tin = three(K0, _, _, _, _, _, _),
		compare(Result0, K, K0),
		(
			Result0 = (<),
			Tin = three(_, _, _, _, T0, _, _),
			tree234__update(T0, K, V, NewT0),
			Tin = three(_, V0, K1, V1, _, T1, T2),
			Tout = three(K0, V0, K1, V1, NewT0, T1, T2)
		;
			Result0 = (=),
			Tin = three(_, _, K1, V1, T0, T1, T2),
			Tout = three(K0, V, K1, V1, T0, T1, T2)
		;
			Result0 = (>),
			Tin = three(_, _, K1, _, _, _, _),
			compare(Result1, K, K1),
			(
				Result1 = (<),
				Tin = three(_, _, _, _, _, T1, _),
				tree234__update(T1, K, V, NewT1),
				Tin = three(_, V0, _, V1, T0, _, T2),
				Tout = three(K0, V0, K1, V1, T0, NewT1, T2)
			;
				Result1 = (=),
				Tin = three(_, V0, _, _, T0, T1, T2),
				Tout = three(K0, V0, K1, V, T0, T1, T2)
			;
				Result1 = (>),
				Tin = three(_, _, _, _, _, _, T2),
				tree234__update(T2, K, V, NewT2),
				Tin = three(_, V0, _, V1, T0, T1, _),
				Tout = three(K0, V0, K1, V1, T0, T1, NewT2)
			)
		)
	;
		Tin = four(_, _, K1, _, _, _, _, _, _, _),
		compare(Result1, K, K1),
		(
			Result1 = (<),
			Tin = four(K0, _, _, _, _, _, _, _, _, _),
			compare(Result0, K, K0),
			(
				Result0 = (<),
				Tin = four(_, _, _, _, _, _, T0, _, _, _),
				tree234__update(T0, K, V, NewT0),
				Tin = four(_, V0, _, V1, K2, V2, _, T1, T2, T3),
				Tout = four(K0, V0, K1, V1, K2, V2,
					NewT0, T1, T2, T3)
			;
				Result0 = (=),
				Tin = four(_, _, _, V1, K2, V2, T0, T1, T2, T3),
				Tout = four(K0, V, K1, V1, K2, V2,
					T0, T1, T2, T3)
			;
				Result0 = (>),
				Tin = four(_, _, _, _, _, _, _, T1, _, _),
				tree234__update(T1, K, V, NewT1),
				Tin = four(_, V0, _, V1, K2, V2, T0, _, T2, T3),
				Tout = four(K0, V0, K1, V1, K2, V2,
					T0, NewT1, T2, T3)
			)
		;
			Result1 = (=),
			Tin = four(K0, V0, _, _, K2, V2, T0, T1, T2, T3),
			Tout = four(K0, V0, K1, V, K2, V2, T0, T1, T2, T3)
		;
			Result1 = (>),
			Tin = four(_, _, _, _, K2, _, _, _, _, _),
			compare(Result2, K, K2),
			(
				Result2 = (<),
				Tin = four(_, _, _, _, _, _, _, _, T2, _),
				tree234__update(T2, K, V, NewT2),
				Tin = four(K0, V0, _, V1, _, V2, T0, T1, _, T3),
				Tout = four(K0, V0, K1, V1, K2, V2,
					T0, T1, NewT2, T3)
			;
				Result2 = (=),
				Tin = four(K0, V0, _, V1, _, _, T0, T1, T2, T3),
				Tout = four(K0, V0, K1, V1, K2, V,
					T0, T1, T2, T3)
			;
				Result2 = (>),
				Tin = four(_, _, _, _, _, _, _, _, _, T3),
				tree234__update(T3, K, V, NewT3),
				Tin = four(K0, V0, _, V1, _, V2, T0, T1, T2, _),
				Tout = four(K0, V0, K1, V1, K2, V2,
					T0, T1, T2, NewT3)
			)
		)
	).

%------------------------------------------------------------------------------%

tree234__lookup(T, K, V) :-
	(
		tree234__search(T, K, V0)
	->
		V = V0
	;
		error("tree234__lookup: key not found.")
	).

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%

:- inst two(K, V, T) =
	bound(
		two(K, V, T, T)
	).

:- inst uniq_two(K, V, T) =
	unique(
		two(K, V, T, T)
	).

:- inst three(K, V, T) =
	bound(
		three(K, V, K, V, T, T, T)
	).

:- inst uniq_three(K, V, T) =
	unique(
		three(K, V, K, V, T, T, T)
	).

:- inst four(K, V, T) =
	bound(
		four(K, V, K, V, K, V, T, T, T, T)
	).

:- inst uniq_four(K, V, T) =
	unique(
		four(K, V, K, V, K, V, T, T, T, T)
	).

:- mode uo_two :: out(uniq_two(unique, unique, unique)).
:- mode suo_two :: out(uniq_two(ground, ground, uniq_tree234_gg)).
:- mode out_two :: out(two(ground, ground, ground)).

:- mode di_two :: di(uniq_two(unique, unique, unique)).
:- mode sdi_two :: di(uniq_two(ground, ground, uniq_tree234_gg)).
:- mode in_two :: in(two(ground, ground, ground)).

:- mode di_three :: di(uniq_three(unique, unique, unique)).
:- mode sdi_three :: di(uniq_three(ground, ground, uniq_tree234_gg)).
:- mode in_three :: in(three(ground, ground, ground)).

:- mode di_four :: di(uniq_four(unique, unique, unique)).
:- mode sdi_four :: di(uniq_four(ground, ground, uniq_tree234_gg)).
:- mode in_four :: in(four(ground, ground, ground)).

%------------------------------------------------------------------------------%

:- pred tree234__split_four(tree234(K, V), K, V, tree234(K, V), tree234(K, V)).
:- mode tree234__split_four(di_four, uo, uo, uo_two, uo_two) is det.
% :- mode tree234__split_four(sdi_four, out, out, suo_two, suo_two) is det.
:- mode tree234__split_four(in_four, out, out, out_two, out_two) is det.

tree234__split_four(Tin, MidK, MidV, Sub0, Sub1) :-
	Tin = four(K0, V0, K1, V1, K2, V2, T0, T1, T2, T3),
	Sub0 = two(K0, V0, T0, T1),
	MidK = K1,
	MidV = V1,
	Sub1 = two(K2, V2, T2, T3).

%------------------------------------------------------------------------------%

% tree234__insert is implemented using the simple top-down
% approach described in eg Sedgwick which splits 4 nodes into
% two 2 nodes on the downward traversal of the tree as we
% search for the right place to insert the new key-value pair.
% We know we have the right place if the subtrees of the node
% are empty (in which case we expand the node - which will always
% work because we already split 4 nodes into 2 nodes), or if the
% tree itself is empty.
% This algorithm is O(lgN).

tree234__insert(Tin, K, V, Tout) :-
	(
		Tin = empty,
		Tout = two(K, V, empty, empty)
	;
		Tin = two(_, _, _, _),
		tree234__insert2(Tin, K, V, Tout)
	;
		Tin = three(_, _, _, _, _, _, _),
		tree234__insert3(Tin, K, V, Tout)
	;
		Tin = four(_, _, _, _, _, _, _, _, _, _),
		tree234__split_four(Tin, MidK, MidV, Sub0, Sub1),
		compare(Result1, K, MidK),
		(
			Result1 = (<),
			tree234__insert2(Sub0, K, V, NewSub0),
			Tout = two(MidK, MidV, NewSub0, Sub1)
		;
			Result1 = (=),
			fail
		;
			Result1 = (>),
			tree234__insert2(Sub1, K, V, NewSub1),
			Tout = two(MidK, MidV, Sub0, NewSub1)
		)
	).

:- pred tree234__insert2(tree234(K, V), K, V, tree234(K, V)).
:- mode tree234__insert2(di_two, di, di, uo) is semidet.
% :- mode tree234__insert2(sdi_two, in, in, uo_tree234) is semidet.
:- mode tree234__insert2(in_two, in, in, out) is semidet.

tree234__insert2(two(K0, V0, T0, T1), K, V, Tout) :-
	(
		T0 = empty,
		T1 = empty
	->
		compare(Result, K, K0),
		(
			Result = (<),
			Tout = three(K, V, K0, V0, empty, empty, empty)
		;
			Result = (=),
			fail
		;
			Result = (>),
			Tout = three(K0, V0, K, V, empty, empty, empty)
		)
	;
		compare(Result, K, K0),
		(
			Result = (<),
			(
				T0 = four(_, _, _, _, _, _, _, _, _, _),
				tree234__split_four(T0, MT0K, MT0V, T00, T01),
				compare(Result1, K, MT0K),
				(
					Result1 = (<),
					tree234__insert2(T00, K, V, NewT00),
					Tout = three(MT0K, MT0V, K0, V0,
						NewT00, T01, T1)
				;
					Result1 = (=),
					fail
				;
					Result1 = (>),
					tree234__insert2(T01, K, V, NewT01),
					Tout = three(MT0K, MT0V, K0, V0,
						T00, NewT01, T1)
				)
			;
				T0 = three(_, _, _, _, _, _, _),
				tree234__insert3(T0, K, V, NewT0),
				Tout = two(K0, V0, NewT0, T1)
			;
				T0 = two(_, _, _, _),
				tree234__insert2(T0, K, V, NewT0),
				Tout = two(K0, V0, NewT0, T1)
			;
				T0 = empty,
				NewT0 = two(K, V, empty, empty),
				Tout = two(K0, V0, NewT0, T1)
			)
		;
			Result = (=),
			fail
		;
			Result = (>),
			(
				T1 = four(_, _, _, _, _, _, _, _, _, _),
				tree234__split_four(T1, MT1K, MT1V, T10, T11),
				compare(Result1, K, MT1K),
				(
					Result1 = (<),
					tree234__insert2(T10, K, V, NewT10),
					Tout = three(K0, V0, MT1K, MT1V,
						T0, NewT10, T11)
				;
					Result1 = (=),
					fail
				;
					Result1 = (>),
					tree234__insert2(T11, K, V, NewT11),
					Tout = three(K0, V0, MT1K, MT1V,
						T0, T10, NewT11)
				)
			;
				T1 = three(_, _, _, _, _, _, _),
				tree234__insert3(T1, K, V, NewT1),
				Tout = two(K0, V0, T0, NewT1)
			;
				T1 = two(_, _, _, _),
				tree234__insert2(T1, K, V, NewT1),
				Tout = two(K0, V0, T0, NewT1)
			;
				T1 = empty,
				NewT1 = two(K, V, empty, empty),
				Tout = two(K0, V0, T0, NewT1)
			)
		)
	).

:- pred tree234__insert3(tree234(K, V), K, V, tree234(K, V)).
:- mode tree234__insert3(di_three, di, di, uo) is semidet.
% :- mode tree234__insert3(sdi_three, in, in, uo_tree234) is semidet.
:- mode tree234__insert3(in_three, in, in, out) is semidet.

tree234__insert3(three(K0, V0, K1, V1, T0, T1, T2), K, V, Tout) :-
	(
		T0 = empty,
		T1 = empty,
		T2 = empty
	->
		compare(Result0, K, K0),
		(
			Result0 = (<),
			Tout = four(K, V, K0, V0, K1, V1,
				empty, empty, empty, empty)
		;
			Result0 = (=),
			fail
		;
			Result0 = (>),
			compare(Result1, K, K1),
			(
				Result1 = (<),
				Tout = four(K0, V0, K, V, K1, V1,
					empty, empty, empty, empty)
			;
				Result1 = (=),
				fail
			;
				Result1 = (>),
				Tout = four(K0, V0, K1, V1, K, V,
					empty, empty, empty, empty)
			)
		)
	;
		compare(Result0, K, K0),
		(
			Result0 = (<),
			(
				T0 = four(_, _, _, _, _, _, _, _, _, _),
				tree234__split_four(T0, MT0K, MT0V, T00, T01),
				compare(ResultM, K, MT0K),
				(
					ResultM = (<),
					tree234__insert2(T00, K, V, NewT00),
					Tout = four(MT0K, MT0V, K0, V0, K1, V1,
						NewT00, T01, T1, T2)
				;
					ResultM = (=),
					fail
				;
					ResultM = (>),
					tree234__insert2(T01, K, V, NewT01),
					Tout = four(MT0K, MT0V, K0, V0, K1, V1,
						T00, NewT01, T1, T2)
				)
			;
				T0 = three(_, _, _, _, _, _, _),
				tree234__insert3(T0, K, V, NewT0),
				Tout = three(K0, V0, K1, V1, NewT0, T1, T2)
			;
				T0 = two(_, _, _, _),
				tree234__insert2(T0, K, V, NewT0),
				Tout = three(K0, V0, K1, V1, NewT0, T1, T2)
			;
				T0 = empty,
				NewT0 = two(K, V, empty, empty),
				Tout = three(K0, V0, K1, V1, NewT0, T1, T2)
			)
		;
			Result0 = (=),
			fail
		;
			Result0 = (>),
			compare(Result1, K, K1),
			(
				Result1 = (<),
				(
					T1 = four(_, _, _, _, _, _, _, _, _, _),
					tree234__split_four(T1, MT1K, MT1V,
						T10, T11),
					compare(ResultM, K, MT1K),
					(
						ResultM = (<),
						tree234__insert2(T10, K, V,
							NewT10),
						Tout = four(K0, V0, MT1K, MT1V,
							K1, V1,
							T0, NewT10, T11, T2)
					;
						ResultM = (=),
						fail
					;
						ResultM = (>),
						tree234__insert2(T11, K, V,
							NewT11),
						Tout = four(K0, V0, MT1K, MT1V,
							K1, V1,
							T0, T10, NewT11, T2)
					)
				;
					T1 = three(_, _, _, _, _, _, _),
					tree234__insert3(T1, K, V, NewT1),
					Tout = three(K0, V0, K1, V1,
						T0, NewT1, T2)
				;
					T1 = two(_, _, _, _),
					tree234__insert2(T1, K, V, NewT1),
					Tout = three(K0, V0, K1, V1,
						T0, NewT1, T2)
				;
					T1 = empty,
					NewT1 = two(K, V, empty, empty),
					Tout = three(K0, V0, K1, V1,
						T0, NewT1, T2)
				)
			;
				Result1 = (=),
				fail
			;
				Result1 = (>),
				(
					T2 = four(_, _, _, _, _, _, _, _, _, _),
					tree234__split_four(T2, MT2K, MT2V,
						T20, T21),
					compare(ResultM, K, MT2K),
					(
						ResultM = (<),
						tree234__insert2(T20, K, V,
							NewT20),
						Tout = four(K0, V0, K1, V1,
							MT2K, MT2V,
							T0, T1, NewT20, T21)
					;
						ResultM = (=),
						fail
					;
						ResultM = (>),
						tree234__insert2(T21, K, V,
							NewT21),
						Tout = four(K0, V0, K1, V1,
							MT2K, MT2V,
							T0, T1, T20, NewT21)
					)
				;
					T2 = three(_, _, _, _, _, _, _),
					tree234__insert3(T2, K, V, NewT2),
					Tout = three(K0, V0, K1, V1,
						T0, T1, NewT2)
				;
					T2 = two(_, _, _, _),
					tree234__insert2(T2, K, V, NewT2),
					Tout = three(K0, V0, K1, V1,
						T0, T1, NewT2)
				;
					T2 = empty,
					NewT2 = two(K, V, empty, empty),
					Tout = three(K0, V0, K1, V1,
						T0, T1, NewT2)
				)
			)
		)
	).

%------------------------------------------------------------------------------%

% tree234__set uses the same algorithm as used for tree234__insert,
% except that instead of failing for equal keys, we replace the value.

tree234__set(Tin, K, V, Tout) :-
	(
		Tin = empty,
		Tout = two(K, V, empty, empty)
	;
		Tin = two(_, _, _, _),
		tree234__set2(Tin, K, V, Tout)
	;
		Tin = three(_, _, _, _, _, _, _),
		tree234__set3(Tin, K, V, Tout)
	;
		Tin = four(K0, V0, K1, V1, K2, V2, T0, T1, T2, T3),
		compare(Result1, K, K1),
		(
			Result1 = (<),
			Sub0 = two(K0, V0, T0, T1),
			Sub1 = two(K2, V2, T2, T3),
			tree234__set2(Sub0, K, V, NewSub0),
			Tout = two(K1, V1, NewSub0, Sub1)
		;
			Result1 = (=),
			Tout = four(K0, V0, K1, V, K2, V2, T0, T1, T2, T3)
		;
			Result1 = (>),
			Sub0 = two(K0, V0, T0, T1),
			Sub1 = two(K2, V2, T2, T3),
			tree234__set2(Sub1, K, V, NewSub1),
			Tout = two(K1, V1, Sub0, NewSub1)
		)
	).

:- pred tree234__set2(tree234(K, V), K, V, tree234(K, V)).
:- mode tree234__set2(di_two, di, di, uo) is det.
% :- mode tree234__set2(sdi_two, in, in, uo_tree234) is det.
:- mode tree234__set2(in_two, in, in, out) is det.

tree234__set2(two(K0, V0, T0, T1), K, V, Tout) :-
	(
		T0 = empty,
		T1 = empty
	->
		compare(Result, K, K0),
		(
			Result = (<),
			Tout = three(K, V, K0, V0, empty, empty, empty)
		;
			Result = (=),
			Tout = two(K, V, T0, T1)
		;
			Result = (>),
			Tout = three(K0, V0, K, V, empty, empty, empty)
		)
	;
		compare(Result, K, K0),
		(
			Result = (<),
			(
				T0 = four(_, _, _, _, _, _, _, _, _, _),
				tree234__split_four(T0, MT0K, MT0V, T00, T01),
				compare(Result1, K, MT0K),
				(
					Result1 = (<),
					tree234__set2(T00, K, V, NewT00),
					Tout = three(MT0K, MT0V, K0, V0,
						NewT00, T01, T1)
				;
					Result1 = (=),
					Tout = three(MT0K, V, K0, V0,
						T00, T01, T1)
				;
					Result1 = (>),
					tree234__set2(T01, K, V, NewT01),
					Tout = three(MT0K, MT0V, K0, V0,
						T00, NewT01, T1)
				)
			;
				T0 = three(_, _, _, _, _, _, _),
				tree234__set3(T0, K, V, NewT0),
				Tout = two(K0, V0, NewT0, T1)
			;
				T0 = two(_, _, _, _),
				tree234__set2(T0, K, V, NewT0),
				Tout = two(K0, V0, NewT0, T1)
			;
				T0 = empty,
				NewT0 = two(K, V, empty, empty),
				Tout = two(K0, V0, NewT0, T1)
			)
		;
			Result = (=),
			Tout = two(K, V, T0, T1)
		;
			Result = (>),
			(
				T1 = four(_, _, _, _, _, _, _, _, _, _),
				tree234__split_four(T1, MT1K, MT1V, T10, T11),
				compare(Result1, K, MT1K),
				(
					Result1 = (<),
					tree234__set2(T10, K, V, NewT10),
					Tout = three(K0, V0, MT1K, MT1V,
						T0, NewT10, T11)
				;
					Result1 = (=),
					Tout = three(K0, V0, MT1K, V,
						T0, T10, T11)
				;
					Result1 = (>),
					tree234__set2(T11, K, V, NewT11),
					Tout = three(K0, V0, MT1K, MT1V,
						T0, T10, NewT11)
				)
			;
				T1 = three(_, _, _, _, _, _, _),
				tree234__set3(T1, K, V, NewT1),
				Tout = two(K0, V0, T0, NewT1)
			;
				T1 = two(_, _, _, _),
				tree234__set2(T1, K, V, NewT1),
				Tout = two(K0, V0, T0, NewT1)
			;
				T1 = empty,
				NewT1 = two(K, V, empty, empty),
				Tout = two(K0, V0, T0, NewT1)
			)
		)
	).

:- pred tree234__set3(tree234(K, V), K, V, tree234(K, V)).
:- mode tree234__set3(di_three, di, di, uo) is det.
% :- mode tree234__set3(sdi_three, in, in, uo_tree234) is det.
:- mode tree234__set3(in_three, in, in, out) is det.

tree234__set3(three(K0, V0, K1, V1, T0, T1, T2), K, V, Tout) :-
	(
		T0 = empty,
		T1 = empty,
		T2 = empty
	->
		compare(Result0, K, K0),
		(
			Result0 = (<),
			Tout = four(K, V, K0, V0, K1, V1,
				empty, empty, empty, empty)
		;
			Result0 = (=),
			Tout = three(K0, V, K1, V1,
				empty, empty, empty)
		;
			Result0 = (>),
			compare(Result1, K, K1),
			(
				Result1 = (<),
				Tout = four(K0, V0, K, V, K1, V1,
					empty, empty, empty, empty)
			;
				Result1 = (=),
				Tout = three(K0, V0, K1, V,
					empty, empty, empty)
			;
				Result1 = (>),
				Tout = four(K0, V0, K1, V1, K, V,
					empty, empty, empty, empty)
			)
		)
	;
		compare(Result0, K, K0),
		(
			Result0 = (<),
			(
				T0 = four(_, _, _, _, _, _, _, _, _, _),
				tree234__split_four(T0, MT0K, MT0V, T00, T01),
				compare(ResultM, K, MT0K),
				(
					ResultM = (<),
					tree234__set2(T00, K, V, NewT00),
					Tout = four(MT0K, MT0V, K0, V0, K1, V1,
						NewT00, T01, T1, T2)
				;
					ResultM = (=),
					Tout = four(MT0K, V, K0, V0, K1, V1,
						T00, T01, T1, T2)
				;
					ResultM = (>),
					tree234__set2(T01, K, V, NewT01),
					Tout = four(MT0K, MT0V, K0, V0, K1, V1,
						T00, NewT01, T1, T2)
				)
			;
				T0 = three(_, _, _, _, _, _, _),
				tree234__set3(T0, K, V, NewT0),
				Tout = three(K0, V0, K1, V1, NewT0, T1, T2)
			;
				T0 = two(_, _, _, _),
				tree234__set2(T0, K, V, NewT0),
				Tout = three(K0, V0, K1, V1, NewT0, T1, T2)
			;
				T0 = empty,
				NewT0 = two(K, V, empty, empty),
				Tout = three(K0, V0, K1, V1, NewT0, T1, T2)
			)
		;
			Result0 = (=),
			Tout = three(K0, V, K1, V1, T0, T1, T2)
		;
			Result0 = (>),
			compare(Result1, K, K1),
			(
				Result1 = (<),
				(
					T1 = four(_, _, _, _, _, _, _, _, _, _),
					tree234__split_four(T1, MT1K, MT1V,
						T10, T11),
					compare(ResultM, K, MT1K),
					(
						ResultM = (<),
						tree234__set2(T10, K, V,
							NewT10),
						Tout = four(K0, V0, MT1K, MT1V,
							K1, V1,
							T0, NewT10, T11, T2)
					;
						ResultM = (=),
						Tout = four(K0, V0, MT1K, V,
							K1, V1,
							T0, T10, T11, T2)
					;
						ResultM = (>),
						tree234__set2(T11, K, V,
							NewT11),
						Tout = four(K0, V0, MT1K, MT1V,
							K1, V1,
							T0, T10, NewT11, T2)
					)
				;
					T1 = three(_, _, _, _, _, _, _),
					tree234__set3(T1, K, V, NewT1),
					Tout = three(K0, V0, K1, V1,
						T0, NewT1, T2)
				;
					T1 = two(_, _, _, _),
					tree234__set2(T1, K, V, NewT1),
					Tout = three(K0, V0, K1, V1,
						T0, NewT1, T2)
				;
					T1 = empty,
					NewT1 = two(K, V, empty, empty),
					Tout = three(K0, V0, K1, V1,
						T0, NewT1, T2)
				)
			;
				Result1 = (=),
				Tout = three(K0, V0, K, V, T0, T1, T2)
			;
				Result1 = (>),
				(
					T2 = four(_, _, _, _, _, _, _, _, _, _),
					tree234__split_four(T2, MT2K, MT2V,
						T20, T21),
					compare(ResultM, K, MT2K),
					(
						ResultM = (<),
						tree234__set2(T20, K, V,
							NewT20),
						Tout = four(K0, V0, K1, V1,
							MT2K, MT2V,
							T0, T1, NewT20, T21)
					;
						ResultM = (=),
						Tout = four(K0, V0, K1, V1,
							MT2K, V,
							T0, T1, T20, T21)
					;
						ResultM = (>),
						tree234__set2(T21, K, V,
							NewT21),
						Tout = four(K0, V0, K1, V1,
							MT2K, MT2V,
							T0, T1, T20, NewT21)
					)
				;
					T2 = three(_, _, _, _, _, _, _),
					tree234__set3(T2, K, V, NewT2),
					Tout = three(K0, V0, K1, V1,
						T0, T1, NewT2)
				;
					T2 = two(_, _, _, _),
					tree234__set2(T2, K, V, NewT2),
					Tout = three(K0, V0, K1, V1,
						T0, T1, NewT2)
				;
					T2 = empty,
					NewT2 = two(K, V, empty, empty),
					Tout = three(K0, V0, K1, V1,
						T0, T1, NewT2)
				)
			)
		)
	).

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%

tree234__delete(Tin, K, Tout) :-
	tree234__delete_2(Tin, K, Tout, _).

	% When deleting an item from a tree, the height of the tree may be
	% reduced by one. The last argument says whether this has occurred.

:- pred tree234__delete_2(tree234(K, V), K, tree234(K, V), bool).
:- mode tree234__delete_2(di, in, uo, out) is det.
:- mode tree234__delete_2(in, in, out, out) is det.

tree234__delete_2(Tin, K, Tout, RH) :-
	(
		Tin = empty,
		Tout = empty,
		RH = no
	;
		Tin = two(K0, V0, T0, T1),
		compare(Result0, K, K0),
		(
			Result0 = (<),
			tree234__delete_2(T0, K, NewT0, RHT0),
			( RHT0 = yes ->
				fix_2node_t0(K0, V0, NewT0, T1, Tout, RH)
			;
				Tout = two(K0, V0, NewT0, T1),
				RH = no
			)
		;
			Result0 = (=),
			(
				tree234__remove_smallest_2(T1, ST1K, ST1V,
					NewT1, RHT1)
			->
				( RHT1 = yes ->
					fix_2node_t1(ST1K, ST1V, T0, NewT1,
						Tout, RH)
				;
					Tout = two(ST1K, ST1V, T0, NewT1),
					RH = no
				)
			;
				% T1 must be empty
				Tout = T0,
				RH = yes
			)
		;
			Result0 = (>),
			tree234__delete_2(T1, K, NewT1, RHT1),
			( RHT1 = yes ->
				fix_2node_t1(K0, V0, T0, NewT1, Tout, RH)
			;
				Tout = two(K0, V0, T0, NewT1),
				RH = no
			)
		)
	;
		Tin = three(K0, V0, K1, V1, T0, T1, T2),
		compare(Result0, K, K0),
		(
			Result0 = (<),
			tree234__delete_2(T0, K, NewT0, RHT0),
			( RHT0 = yes ->
				fix_3node_t0(K0, V0, K1, V1, NewT0, T1, T2,
					Tout, RH)
			;
				Tout = three(K0, V0, K1, V1, NewT0, T1, T2),
				RH = no
			)
		;
			Result0 = (=),
			(
				tree234__remove_smallest_2(T1, ST1K, ST1V,
					NewT1, RHT1)
			->
				( RHT1 = yes ->
					fix_3node_t1(ST1K, ST1V, K1, V1,
						T0, NewT1, T2, Tout, RH)
				;
					Tout = three(ST1K, ST1V, K1, V1,
						T0, NewT1, T2),
					RH = no
				)
			;
				% T1 must be empty
				Tout = two(K1, V1, T0, T2),
				RH = no
			)
		;
			Result0 = (>),
			compare(Result1, K, K1),
			(
				Result1 = (<),
				tree234__delete_2(T1, K, NewT1, RHT1),
				( RHT1 = yes ->
					fix_3node_t1(K0, V0, K1, V1,
						T0, NewT1, T2, Tout, RH)
				;
					Tout = three(K0, V0, K1, V1,
						T0, NewT1, T2),
					RH = no
				)
			;
				Result1 = (=),
				(
					tree234__remove_smallest_2(T2,
						ST2K, ST2V, NewT2, RHT2)
				->
					( RHT2 = yes ->
						fix_3node_t2(K0, V0, ST2K, ST2V,
							T0, T1, NewT2, Tout, RH)
					;
						Tout = three(K0, V0, ST2K, ST2V,
							T0, T1, NewT2),
						RH = no
					)
				;
					% T2 must be empty
					Tout = two(K0, V0, T0, T1),
					RH = no
				)
			;
				Result1 = (>),
				tree234__delete_2(T2, K, NewT2, RHT2),
				( RHT2 = yes ->
					fix_3node_t2(K0, V0, K1, V1,
						T0, T1, NewT2, Tout, RH)
				;
					Tout = three(K0, V0, K1, V1,
						T0, T1, NewT2),
					RH = no
				)
			)
		)
	;
		Tin = four(K0, V0, K1, V1, K2, V2, T0, T1, T2, T3),
		compare(Result1, K, K1),
		(
			Result1 = (<),
			compare(Result0, K, K0),
			(
				Result0 = (<),
				tree234__delete_2(T0, K, NewT0, RHT0),
				( RHT0 = yes ->
					fix_4node_t0(K0, V0, K1, V1, K2, V2,
						NewT0, T1, T2, T3, Tout, RH)
				;
					Tout = four(K0, V0, K1, V1, K2, V2,
						NewT0, T1, T2, T3),
					RH = no
				)
			;
				Result0 = (=),
				(
					tree234__remove_smallest_2(T1,
						ST1K, ST1V, NewT1, RHT1)
				->
					( RHT1 = yes ->
						fix_4node_t1(ST1K, ST1V, K1, V1,
							K2, V2,
							T0, NewT1, T2, T3,
							Tout, RH)
					;
						Tout = four(ST1K, ST1V, K1, V1,
							K2, V2,
							T0, NewT1, T2, T3),
						RH = no
					)
				;
					% T1 must be empty
					Tout = three(K1, V1, K2, V2,
						T0, T2, T3),
					RH = no
				)
			;
				Result0 = (>),
				tree234__delete_2(T1, K, NewT1, RHT1),
				( RHT1 = yes ->
					fix_4node_t1(K0, V0, K1, V1, K2, V2,
						T0, NewT1, T2, T3, Tout, RH)
				;
					Tout = four(K0, V0, K1, V1, K2, V2,
						T0, NewT1, T2, T3),
					RH = no
				)
			)
		;
			Result1 = (=),
			(
				tree234__remove_smallest_2(T2, ST2K, ST2V,
					NewT2, RHT2)
			->
				( RHT2 = yes ->
					fix_4node_t2(K0, V0, ST2K, ST2V, K2, V2,
						T0, T1, NewT2, T3, Tout, RH)
				;
					Tout = four(K0, V0, ST2K, ST2V, K2, V2,
						T0, T1, NewT2, T3),
					RH = no
				)
			;
				% T2 must be empty
				Tout = three(K0, V0, K2, V2, T0, T1, T3),
				RH = no
			)
		;
			Result1 = (>),
			compare(Result2, K, K2),
			(
				Result2 = (<),
				tree234__delete_2(T2, K, NewT2, RHT2),
				( RHT2 = yes ->
					fix_4node_t2(K0, V0, K1, V1, K2, V2,
						T0, T1, NewT2, T3, Tout, RH)
				;
					Tout = four(K0, V0, K1, V1, K2, V2,
						T0, T1, NewT2, T3),
					RH = no
				)
			;
				Result2 = (=),
				(
					tree234__remove_smallest_2(T3,
						ST3K, ST3V, NewT3, RHT3)
				->
					( RHT3 = yes ->
						fix_4node_t3(K0, V0, K1, V1,
							ST3K, ST3V,
							T0, T1, T2, NewT3,
							Tout, RH)
					;
						Tout = four(K0, V0, K1, V1,
							ST3K, ST3V,
							T0, T1, T2, NewT3),
						RH = no
					)
				;
					% T3 must be empty
					Tout = three(K0, V0, K1, V1,
						T0, T1, T2),
					RH = no
				)
			;
				Result2 = (>),
				tree234__delete_2(T3, K, NewT3, RHT3),
				( RHT3 = yes ->
					fix_4node_t3(K0, V0, K1, V1, K2, V2,
						T0, T1, T2, NewT3, Tout, RH)
				;
					Tout = four(K0, V0, K1, V1, K2, V2,
						T0, T1, T2, NewT3),
					RH = no
				)
			)
		)
	).

%------------------------------------------------------------------------------%

	% We use the same algorithm as tree234__delete.

tree234__remove(Tin, K, V, Tout) :-
	tree234__remove_2(Tin, K, V, Tout, _).

:- pred tree234__remove_2(tree234(K, V), K, V, tree234(K, V), bool).
:- mode tree234__remove_2(di, in, uo, uo, out) is semidet.
:- mode tree234__remove_2(in, in, out, out, out) is semidet.

tree234__remove_2(Tin, K, V, Tout, RH) :-
	(
		Tin = empty,
		fail
	;
		Tin = two(K0, V0, T0, T1),
		compare(Result0, K, K0),
		(
			Result0 = (<),
			tree234__remove_2(T0, K, V, NewT0, RHT0),
			( RHT0 = yes ->
				fix_2node_t0(K0, V0, NewT0, T1, Tout, RH)
			;
				Tout = two(K0, V0, NewT0, T1),
				RH = no
			)
		;
			Result0 = (=),
			(
				tree234__remove_smallest_2(T1, ST1K, ST1V,
					NewT1, RHT1)
			->
				( RHT1 = yes ->
					fix_2node_t1(ST1K, ST1V, T0, NewT1,
						Tout, RH)
				;
					Tout = two(ST1K, ST1V, T0, NewT1),
					RH = no
				)
			;
				% T1 must be empty
				Tout = T0,
				RH = yes
			),
			V = V0
		;
			Result0 = (>),
			tree234__remove_2(T1, K, V, NewT1, RHT1),
			( RHT1 = yes ->
				fix_2node_t1(K0, V0, T0, NewT1, Tout, RH)
			;
				Tout = two(K0, V0, T0, NewT1),
				RH = no
			)
		)
	;
		Tin = three(K0, V0, K1, V1, T0, T1, T2),
		compare(Result0, K, K0),
		(
			Result0 = (<),
			tree234__remove_2(T0, K, V, NewT0, RHT0),
			( RHT0 = yes ->
				fix_3node_t0(K0, V0, K1, V1, NewT0, T1, T2,
					Tout, RH)
			;
				Tout = three(K0, V0, K1, V1, NewT0, T1, T2),
				RH = no
			)
		;
			Result0 = (=),
			(
				tree234__remove_smallest_2(T1, ST1K, ST1V,
					NewT1, RHT1)
			->
				( RHT1 = yes ->
					fix_3node_t1(ST1K, ST1V, K1, V1,
						T0, NewT1, T2, Tout, RH)
				;
					Tout = three(ST1K, ST1V, K1, V1,
						T0, NewT1, T2),
					RH = no
				)
			;
				% T1 must be empty
				Tout = two(K1, V1, T0, T2),
				RH = no
			),
			V = V0
		;
			Result0 = (>),
			compare(Result1, K, K1),
			(
				Result1 = (<),
				tree234__remove_2(T1, K, V, NewT1, RHT1),
				( RHT1 = yes ->
					fix_3node_t1(K0, V0, K1, V1,
						T0, NewT1, T2, Tout, RH)
				;
					Tout = three(K0, V0, K1, V1,
						T0, NewT1, T2),
					RH = no
				)
			;
				Result1 = (=),
				(
					tree234__remove_smallest_2(T2,
						ST2K, ST2V, NewT2, RHT2)
				->
					( RHT2 = yes ->
						fix_3node_t2(K0, V0, ST2K, ST2V,
							T0, T1, NewT2, Tout, RH)
					;
						Tout = three(K0, V0, ST2K, ST2V,
							T0, T1, NewT2),
						RH = no
					)
				;
					% T2 must be empty
					Tout = two(K0, V0, T0, T1),
					RH = no
				),
				V = V1
			;
				Result1 = (>),
				tree234__remove_2(T2, K, V, NewT2, RHT2),
				( RHT2 = yes ->
					fix_3node_t2(K0, V0, K1, V1,
						T0, T1, NewT2, Tout, RH)
				;
					Tout = three(K0, V0, K1, V1,
						T0, T1, NewT2),
					RH = no
				)
			)
		)
	;
		Tin = four(K0, V0, K1, V1, K2, V2, T0, T1, T2, T3),
		compare(Result1, K, K1),
		(
			Result1 = (<),
			compare(Result0, K, K0),
			(
				Result0 = (<),
				tree234__remove_2(T0, K, V, NewT0, RHT0),
				( RHT0 = yes ->
					fix_4node_t0(K0, V0, K1, V1, K2, V2,
						NewT0, T1, T2, T3, Tout, RH)
				;
					Tout = four(K0, V0, K1, V1, K2, V2,
						NewT0, T1, T2, T3),
					RH = no
				)
			;
				Result0 = (=),
				(
					tree234__remove_smallest_2(T1,
						ST1K, ST1V, NewT1, RHT1)
				->
					( RHT1 = yes ->
						fix_4node_t1(ST1K, ST1V, K1, V1,
							K2, V2,
							T0, NewT1, T2, T3,
							Tout, RH)
					;
						Tout = four(ST1K, ST1V, K1, V1,
							K2, V2,
							T0, NewT1, T2, T3),
						RH = no
					)
				;
					% T1 must be empty
					Tout = three(K1, V1, K2, V2,
						T0, T2, T3),
					RH = no
				),
				V = V0
			;
				Result0 = (>),
				tree234__remove_2(T1, K, V, NewT1, RHT1),
				( RHT1 = yes ->
					fix_4node_t1(K0, V0, K1, V1, K2, V2,
						T0, NewT1, T2, T3, Tout, RH)
				;
					Tout = four(K0, V0, K1, V1, K2, V2,
						T0, NewT1, T2, T3),
					RH = no
				)
			)
		;
			Result1 = (=),
			(
				tree234__remove_smallest_2(T2, ST2K, ST2V,
					NewT2, RHT2)
			->
				( RHT2 = yes ->
					fix_4node_t2(K0, V0, ST2K, ST2V, K2, V2,
						T0, T1, NewT2, T3, Tout, RH)
				;
					Tout = four(K0, V0, ST2K, ST2V, K2, V2,
						T0, T1, NewT2, T3),
					RH = no
				)
			;
				% T2 must be empty
				Tout = three(K0, V0, K2, V2, T0, T1, T3),
				RH = no
			),
			V = V1
		;
			Result1 = (>),
			compare(Result2, K, K2),
			(
				Result2 = (<),
				tree234__remove_2(T2, K, V, NewT2, RHT2),
				( RHT2 = yes ->
					fix_4node_t2(K0, V0, K1, V1, K2, V2,
						T0, T1, NewT2, T3, Tout, RH)
				;
					Tout = four(K0, V0, K1, V1, K2, V2,
						T0, T1, NewT2, T3),
					RH = no
				)
			;
				Result2 = (=),
				(
					tree234__remove_smallest_2(T3,
						ST3K, ST3V, NewT3, RHT3)
				->
					( RHT3 = yes ->
						fix_4node_t3(K0, V0, K1, V1,
							ST3K, ST3V,
							T0, T1, T2, NewT3,
							Tout, RH)
					;
						Tout = four(K0, V0, K1, V1,
							ST3K, ST3V,
							T0, T1, T2, NewT3),
						RH = no
					)
				;
					% T3 must be empty
					Tout = three(K0, V0, K1, V1,
						T0, T1, T2),
					RH = no
				),
				V = V2
			;
				Result2 = (>),
				tree234__remove_2(T3, K, V, NewT3, RHT3),
				( RHT3 = yes ->
					fix_4node_t3(K0, V0, K1, V1, K2, V2,
						T0, T1, T2, NewT3, Tout, RH)
				;
					Tout = four(K0, V0, K1, V1, K2, V2,
						T0, T1, T2, NewT3),
					RH = no
				)
			)
		)
	).

%------------------------------------------------------------------------------%

	% The algorithm we use similar to tree234__delete, except that we
	% always go down the left subtree.

tree234__remove_smallest(Tin, K, V, Tout) :-
	tree234__remove_smallest_2(Tin, K, V, Tout, _).

:- pred tree234__remove_smallest_2(tree234(K, V), K, V, tree234(K, V), bool).
:- mode tree234__remove_smallest_2(di, uo, uo, uo, out) is semidet.
:- mode tree234__remove_smallest_2(in, out, out, out, out) is semidet.

tree234__remove_smallest_2(Tin, K, V, Tout, RH) :-
	(
		Tin = empty,
		fail
	;
		Tin = two(K0, V0, T0, T1),
		(
			T0 = empty
		->
			K = K0,
			V = V0,
			Tout = T1,
			RH = yes
		;
			tree234__remove_smallest_2(T0, K, V, NewT0, RHT0),
			( RHT0 = yes ->
				fix_2node_t0(K0, V0, NewT0, T1, Tout, RH)
			;
				Tout = two(K0, V0, NewT0, T1),
				RH = no
			)
		)
	;
		Tin = three(K0, V0, K1, V1, T0, T1, T2),
		(
			T0 = empty
		->
			K = K0,
			V = V0,
			Tout = two(K1, V1, T1, T2),
			RH = no
		;
			tree234__remove_smallest_2(T0, K, V, NewT0, RHT0),
			( RHT0 = yes ->
				fix_3node_t0(K0, V0, K1, V1, NewT0, T1, T2,
					Tout, RH)
			;
				Tout = three(K0, V0, K1, V1, NewT0, T1, T2),
				RH = no
			)
		)
	;
		Tin = four(K0, V0, K1, V1, K2, V2, T0, T1, T2, T3),
		(
			T0 = empty
		->
			K = K0,
			V = V0,
			Tout = three(K1, V1, K2, V2, T1, T2, T3),
			RH = no
		;
			tree234__remove_smallest_2(T0, K, V, NewT0, RHT0),
			( RHT0 = yes ->
				fix_4node_t0(K0, V0, K1, V1, K2, V2,
					NewT0, T1, T2, T3, Tout, RH)
			;
				Tout = four(K0, V0, K1, V1, K2, V2,
					NewT0, T1, T2, T3),
				RH = no
			)
		)
	).

%------------------------------------------------------------------------------%

	% The input to the following group of predicates are the components
	% of a two-, three- or four-node in which the height of the indicated
	% subtree is one less that it should be. If it is possible to increase
	% the height of that subtree by moving into it elements from its
	% neighboring subtrees, do so, and return the resulting tree with RH
	% set to no. Otherwise, return a balanced tree whose height is reduced
	% by one, with RH set to yes to indicate the reduced height.

:- pred fix_2node_t0(K, V, tree234(K, V), tree234(K, V), tree234(K, V), bool).
:- mode fix_2node_t0(di, di, di, di, uo, out) is det.
:- mode fix_2node_t0(in, in, in, in, out, out) is det.

fix_2node_t0(K0, V0, T0, T1, Tout, RH) :-
	(
		% steal T1's leftmost subtree and combine it with T0
		T1 = four(K10, V10, K11, V11, K12, V12, T10, T11, T12, T13),
		NewT1 = three(K11, V11, K12, V12, T11, T12, T13),
		Node = two(K0, V0, T0, T10),
		Tout = two(K10, V10, Node, NewT1),
		RH = no
	;
		% steal T1's leftmost subtree and combine it with T0
		T1 = three(K10, V10, K11, V11, T10, T11, T12),
		NewT1 = two(K11, V11, T11, T12),
		Node = two(K0, V0, T0, T10),
		Tout = two(K10, V10, Node, NewT1),
		RH = no
	;
		% move T0 one level down and combine it with the subtrees of T1
		% this reduces the depth of the tree
		T1 = two(K10, V10, T10, T11),
		Tout = three(K0, V0, K10, V10, T0, T10, T11),
		RH = yes
	;
		T1 = empty,
		error("unbalanced 234 tree")
		% Tout = two(K0, V0, T0, T1),
		% RH = yes
	).

:- pred fix_2node_t1(K, V, tree234(K, V), tree234(K, V), tree234(K, V), bool).
:- mode fix_2node_t1(di, di, di, di, uo, out) is det.
:- mode fix_2node_t1(in, in, in, in, out, out) is det.

fix_2node_t1(K0, V0, T0, T1, Tout, RH) :-
	(
		% steal T0's leftmost subtree and combine it with T1
		T0 = four(K00, V00, K01, V01, K02, V02, T00, T01, T02, T03),
		NewT0 = three(K00, V00, K01, V01, T00, T01, T02),
		Node = two(K0, V0, T03, T1),
		Tout = two(K02, V02, NewT0, Node),
		RH = no
	;
		% steal T0's leftmost subtree and combine it with T1
		T0 = three(K00, V00, K01, V01, T00, T01, T02),
		NewT0 = two(K00, V00, T00, T01),
		Node = two(K0, V0, T02, T1),
		Tout = two(K01, V01, NewT0, Node),
		RH = no
	;
		% move T1 one level down and combine it with the subtrees of T0
		% this reduces the depth of the tree
		T0 = two(K00, V00, T00, T01),
		Tout = three(K00, V00, K0, V0, T00, T01, T1),
		RH = yes
	;
		T0 = empty,
		error("unbalanced 234 tree")
		% Tout = two(K0, V0, T0, T1),
		% RH = yes
	).

:- pred fix_3node_t0(K, V, K, V, tree234(K, V), tree234(K, V), tree234(K, V),
	tree234(K, V), bool).
:- mode fix_3node_t0(di, di, di, di, di, di, di, uo, out) is det.
:- mode fix_3node_t0(in, in, in, in, in, in, in, out, out) is det.

fix_3node_t0(K0, V0, K1, V1, T0, T1, T2, Tout, RH) :-
	(
		% steal T1's leftmost subtree and combine it with T0
		T1 = four(K10, V10, K11, V11, K12, V12, T10, T11, T12, T13),
		NewT1 = three(K11, V11, K12, V12, T11, T12, T13),
		Node = two(K0, V0, T0, T10),
		Tout = three(K10, V10, K1, V1, Node, NewT1, T2),
		RH = no
	;
		% steal T1's leftmost subtree and combine it with T0
		T1 = three(K10, V10, K11, V11, T10, T11, T12),
		NewT1 = two(K11, V11, T11, T12),
		Node = two(K0, V0, T0, T10),
		Tout = three(K10, V10, K1, V1, Node, NewT1, T2),
		RH = no
	;
		% move T0 one level down to become the leftmost subtree of T1
		T1 = two(K10, V10, T10, T11),
		NewT1 = three(K0, V0, K10, V10, T0, T10, T11),
		Tout = two(K1, V1, NewT1, T2),
		RH = no
	;
		T1 = empty,
		error("unbalanced 234 tree")
		% Tout = three(K0, V0, K1, V1, T0, T1, T2),
		% The heights of T1 and T2 are unchanged
		% RH = no
	).

:- pred fix_3node_t1(K, V, K, V, tree234(K, V), tree234(K, V), tree234(K, V),
	tree234(K, V), bool).
:- mode fix_3node_t1(di, di, di, di, di, di, di, uo, out) is det.
:- mode fix_3node_t1(in, in, in, in, in, in, in, out, out) is det.

fix_3node_t1(K0, V0, K1, V1, T0, T1, T2, Tout, RH) :-
	(
		% steal T0's rightmost subtree and combine it with T1
		T0 = four(K00, V00, K01, V01, K02, V02, T00, T01, T02, T03),
		NewT0 = three(K00, V00, K01, V01, T00, T01, T02),
		Node = two(K0, V0, T03, T1),
		Tout = three(K02, V02, K1, V1, NewT0, Node, T2),
		RH = no
	;
		% steal T0's rightmost subtree and combine it with T1
		T0 = three(K00, V00, K01, V01, T00, T01, T02),
		NewT0 = two(K00, V00, T00, T01),
		Node = two(K0, V0, T02, T1),
		Tout = three(K01, V01, K1, V1, NewT0, Node, T2),
		RH = no
	;
		% move T1 one level down to become the rightmost subtree of T0
		T0 = two(K00, V00, T00, T01),
		NewT0 = three(K00, V00, K0, V0, T00, T01, T1),
		Tout = two(K1, V1, NewT0, T2),
		RH = no
	;
		T0 = empty,
		error("unbalanced 234 tree")
		% Tout = three(K0, V0, K1, V1, T0, T1, T2),
		% The heights of T0 and T2 are unchanged
		% RH = no
	).

:- pred fix_3node_t2(K, V, K, V, tree234(K, V), tree234(K, V), tree234(K, V),
	tree234(K, V), bool).
:- mode fix_3node_t2(di, di, di, di, di, di, di, uo, out) is det.
:- mode fix_3node_t2(in, in, in, in, in, in, in, out, out) is det.

fix_3node_t2(K0, V0, K1, V1, T0, T1, T2, Tout, RH) :-
	(
		% steal T1's rightmost subtree and combine it with T2
		T1 = four(K10, V10, K11, V11, K12, V12, T10, T11, T12, T13),
		NewT1 = three(K10, V10, K11, V11, T10, T11, T12),
		Node = two(K1, V1, T13, T2),
		Tout = three(K0, V0, K12, V12, T0, NewT1, Node),
		RH = no
	;
		% steal T1's rightmost subtree and combine it with T2
		T1 = three(K10, V10, K11, V11, T10, T11, T12),
		NewT1 = two(K10, V10, T10, T11),
		Node = two(K1, V1, T12, T2),
		Tout = three(K0, V0, K11, V11, T0, NewT1, Node),
		RH = no
	;
		% move T2 one level down to become the rightmost subtree of T1
		T1 = two(K10, V10, T10, T11),
		NewT1 = three(K10, V10, K1, V1, T10, T11, T2),
		Tout = two(K0, V0, T0, NewT1),
		RH = no
	;
		T1 = empty,
		error("unbalanced 234 tree")
		% Tout = three(K0, V0, K1, V1, T0, T1, T2),
		% The heights of T0 and T1 are unchanged
		% RH = no
	).

:- pred fix_4node_t0(K, V, K, V, K, V,
	tree234(K, V), tree234(K, V), tree234(K, V), tree234(K, V),
	tree234(K, V), bool).
:- mode fix_4node_t0(di, di, di, di, di, di, di, di, di, di, uo, out) is det.
:- mode fix_4node_t0(in, in, in, in, in, in, in, in, in, in, out, out) is det.

fix_4node_t0(K0, V0, K1, V1, K2, V2, T0, T1, T2, T3, Tout, RH) :-
	(
		% steal T1's leftmost subtree and combine it with T0
		T1 = four(K10, V10, K11, V11, K12, V12, T10, T11, T12, T13),
		NewT1 = three(K11, V11, K12, V12, T11, T12, T13),
		Node = two(K0, V0, T0, T10),
		Tout = four(K10, V10, K1, V1, K2, V2, Node, NewT1, T2, T3),
		RH = no
	;
		% steal T1's leftmost subtree and combine it with T0
		T1 = three(K10, V10, K11, V11, T10, T11, T12),
		NewT1 = two(K11, V11, T11, T12),
		Node = two(K0, V0, T0, T10),
		Tout = four(K10, V10, K1, V1, K2, V2, Node, NewT1, T2, T3),
		RH = no
	;
		% move T0 one level down to become the leftmost subtree of T1
		T1 = two(K10, V10, T10, T11),
		NewT1 = three(K0, V0, K10, V10, T0, T10, T11),
		Tout = three(K1, V1, K2, V2, NewT1, T2, T3),
		RH = no
	;
		T1 = empty,
		error("unbalanced 234 tree")
		% Tout = four(K0, V0, K1, V1, K2, V2, T0, T1, T2, T3),
		% The heights of T1, T2 and T3 are unchanged
		% RH = no
	).

:- pred fix_4node_t1(K, V, K, V, K, V,
	tree234(K, V), tree234(K, V), tree234(K, V), tree234(K, V),
	tree234(K, V), bool).
:- mode fix_4node_t1(di, di, di, di, di, di, di, di, di, di, uo, out) is det.
:- mode fix_4node_t1(in, in, in, in, in, in, in, in, in, in, out, out) is det.

fix_4node_t1(K0, V0, K1, V1, K2, V2, T0, T1, T2, T3, Tout, RH) :-
	(
		% steal T2's leftmost subtree and combine it with T1
		T2 = four(K20, V20, K21, V21, K22, V22, T20, T21, T22, T23),
		NewT2 = three(K21, V21, K22, V22, T21, T22, T23),
		Node = two(K1, V1, T1, T20),
		Tout = four(K0, V0, K20, V20, K2, V2, T0, Node, NewT2, T3),
		RH = no
	;
		% steal T2's leftmost subtree and combine it with T1
		T2 = three(K20, V20, K21, V21, T20, T21, T22),
		NewT2 = two(K21, V21, T21, T22),
		Node = two(K1, V1, T1, T20),
		Tout = four(K0, V0, K20, V20, K2, V2, T0, Node, NewT2, T3),
		RH = no
	;
		% move T1 one level down to become the leftmost subtree of T2
		T2 = two(K20, V20, T20, T21),
		NewT2 = three(K1, V1, K20, V20, T1, T20, T21),
		Tout = three(K0, V0, K2, V2, T0, NewT2, T3),
		RH = no
	;
		T2 = empty,
		error("unbalanced 234 tree")
		% Tout = four(K0, V0, K1, V1, K2, V2, T0, T1, T2, T3),
		% The heights of T0, T2 and T3 are unchanged
		% RH = no
	).

:- pred fix_4node_t2(K, V, K, V, K, V,
	tree234(K, V), tree234(K, V), tree234(K, V), tree234(K, V),
	tree234(K, V), bool).
:- mode fix_4node_t2(di, di, di, di, di, di, di, di, di, di, uo, out) is det.
:- mode fix_4node_t2(in, in, in, in, in, in, in, in, in, in, out, out) is det.

fix_4node_t2(K0, V0, K1, V1, K2, V2, T0, T1, T2, T3, Tout, RH) :-
	(
		% steal T3's leftmost subtree and combine it with T2
		T3 = four(K30, V30, K31, V31, K32, V32, T30, T31, T32, T33),
		NewT3 = three(K31, V31, K32, V32, T31, T32, T33),
		Node = two(K2, V2, T2, T30),
		Tout = four(K0, V0, K1, V1, K30, V30, T0, T1, Node, NewT3),
		RH = no
	;
		% steal T3's leftmost subtree and combine it with T2
		T3 = three(K30, V30, K31, V31, T30, T31, T32),
		NewT3 = two(K31, V31, T31, T32),
		Node = two(K2, V2, T2, T30),
		Tout = four(K0, V0, K1, V1, K30, V30, T0, T1, Node, NewT3),
		RH = no
	;
		% move T2 one level down to become the leftmost subtree of T3
		T3 = two(K30, V30, T30, T31),
		NewT3 = three(K2, V2, K30, V30, T2, T30, T31),
		Tout = three(K0, V0, K1, V1, T0, T1, NewT3),
		RH = no
	;
		T3 = empty,
		error("unbalanced 234 tree")
		% Tout = four(K0, V0, K1, V1, K2, V2, T0, T1, T2, T3),
		% The heights of T0, T1 and T3 are unchanged
		% RH = no
	).

:- pred fix_4node_t3(K, V, K, V, K, V,
	tree234(K, V), tree234(K, V), tree234(K, V), tree234(K, V),
	tree234(K, V), bool).
:- mode fix_4node_t3(di, di, di, di, di, di, di, di, di, di, uo, out) is det.
:- mode fix_4node_t3(in, in, in, in, in, in, in, in, in, in, out, out) is det.

fix_4node_t3(K0, V0, K1, V1, K2, V2, T0, T1, T2, T3, Tout, RH) :-
	(
		% steal T2's rightmost subtree and combine it with T3
		T2 = four(K20, V20, K21, V21, K22, V22, T20, T21, T22, T23),
		NewT2 = three(K20, V20, K21, V21, T20, T21, T22),
		Node = two(K2, V2, T23, T3),
		Tout = four(K0, V0, K1, V1, K22, V22, T0, T1, NewT2, Node),
		RH = no
	;
		% steal T2's rightmost subtree and combine it with T3
		T2 = three(K20, V20, K21, V21, T20, T21, T22),
		NewT2 = two(K20, V20, T20, T21),
		Node = two(K2, V2, T22, T3),
		Tout = four(K0, V0, K1, V1, K21, V21, T0, T1, NewT2, Node),
		RH = no
	;
		% move T3 one level down to become the rightmost subtree of T2
		T2 = two(K20, V20, T20, T21),
		NewT2 = three(K20, V20, K2, V2, T20, T21, T3),
		Tout = three(K0, V0, K1, V1, T0, T1, NewT2),
		RH = no
	;
		T2 = empty,
		error("unbalanced 234 tree")
		% Tout = four(K0, V0, K1, V1, K2, V2, T0, T1, T2, T3),
		% The heights of T0, T1 and T2 are unchanged
		% RH = no
	).

%------------------------------------------------------------------------------%

tree234__keys(Tree, Keys) :-
	tree234__keys_2(Tree, [], Keys).

:- pred tree234__keys_2(tree234(K, V), list(K), list(K)).
:- mode tree234__keys_2(in, in, out) is det.

tree234__keys_2(empty, List, List).
tree234__keys_2(two(K0, _V0, T0, T1), L0, L) :-
	tree234__keys_2(T1, L0, L1),
	tree234__keys_2(T0, [K0 | L1], L).
tree234__keys_2(three(K0, _V0, K1, _V1, T0, T1, T2), L0, L) :-
	tree234__keys_2(T2, L0, L1),
	tree234__keys_2(T1, [K1 | L1], L2),
	tree234__keys_2(T0, [K0 | L2], L).
tree234__keys_2(four(K0, _V0, K1, _V1, K2, _V2, T0, T1, T2, T3), L0, L) :-
	tree234__keys_2(T3, L0, L1),
	tree234__keys_2(T2, [K2 | L1], L2),
	tree234__keys_2(T1, [K1 | L2], L3),
	tree234__keys_2(T0, [K0 | L3], L).

%------------------------------------------------------------------------------%

tree234__values(Tree, Values) :-
	tree234__values_2(Tree, [], Values).

:- pred tree234__values_2(tree234(K, V), list(V), list(V)).
:- mode tree234__values_2(in, in, out) is det.

tree234__values_2(empty, List, List).
tree234__values_2(two(_K0, V0, T0, T1), L0, L) :-
	tree234__values_2(T1, L0, L1),
	tree234__values_2(T0, [V0 | L1], L).
tree234__values_2(three(_K0, V0, _K1, V1, T0, T1, T2), L0, L) :-
	tree234__values_2(T2, L0, L1),
	tree234__values_2(T1, [V1 | L1], L2),
	tree234__values_2(T0, [V0 | L2], L).
tree234__values_2(four(_K0, V0, _K1, V1, _K2, V2, T0, T1, T2, T3), L0, L) :-
	tree234__values_2(T3, L0, L1),
	tree234__values_2(T2, [V2 | L1], L2),
	tree234__values_2(T1, [V1 | L2], L3),
	tree234__values_2(T0, [V0 | L3], L).

%------------------------------------------------------------------------------%

tree234__assoc_list_to_tree234(AssocList, Tree) :-
	tree234__assoc_list_to_tree234_2(AssocList, empty, Tree).

:- pred tree234__assoc_list_to_tree234_2(assoc_list(K, V), tree234(K, V),
					tree234(K, V)).
:- mode tree234__assoc_list_to_tree234_2(in, in, out) is det.

tree234__assoc_list_to_tree234_2([], Tree, Tree).
tree234__assoc_list_to_tree234_2([K - V | Rest], Tree0, Tree) :-
	tree234__set(Tree0, K, V, Tree1),
	tree234__assoc_list_to_tree234_2(Rest, Tree1, Tree).

%------------------------------------------------------------------------------%

tree234__tree234_to_assoc_list(Tree, AssocList) :-
	tree234__tree234_to_assoc_list_2(Tree, [], AssocList).

:- pred tree234__tree234_to_assoc_list_2(tree234(K, V), assoc_list(K, V),
						assoc_list(K, V)).
:- mode tree234__tree234_to_assoc_list_2(in, in, out) is det.

tree234__tree234_to_assoc_list_2(empty, List, List).
tree234__tree234_to_assoc_list_2(two(K0, V0, T0, T1), L0, L) :-
	tree234__tree234_to_assoc_list_2(T1, L0, L1),
	tree234__tree234_to_assoc_list_2(T0, [K0 - V0 | L1], L).
tree234__tree234_to_assoc_list_2(three(K0, V0, K1, V1, T0, T1, T2), L0, L) :-
	tree234__tree234_to_assoc_list_2(T2, L0, L1),
	tree234__tree234_to_assoc_list_2(T1, [K1 - V1 | L1], L2),
	tree234__tree234_to_assoc_list_2(T0, [K0 - V0 | L2], L).
tree234__tree234_to_assoc_list_2(four(K0, V0, K1, V1, K2, V2, T0, T1, T2, T3),
					L0, L) :-
	tree234__tree234_to_assoc_list_2(T3, L0, L1),
	tree234__tree234_to_assoc_list_2(T2, [K2 - V2 | L1], L2),
	tree234__tree234_to_assoc_list_2(T1, [K1 - V1 | L2], L3),
	tree234__tree234_to_assoc_list_2(T0, [K0 - V0 | L3], L).

%------------------------------------------------------------------------------%

	% count the number of elements in a tree
tree234__count(empty, 0).
tree234__count(two(_, _, T0, T1), N) :-
	tree234__count(T0, N0),
	tree234__count(T1, N1),
	N is 1 + N0 + N1.
tree234__count(three(_, _, _, _, T0, T1, T2), N) :-
	tree234__count(T0, N0),
	tree234__count(T1, N1),
	tree234__count(T2, N2),
	N is 2 + N0 + N1 + N2.
tree234__count(four(_, _, _, _, _, _, T0, T1, T2, T3), N) :-
	tree234__count(T0, N0),
	tree234__count(T1, N1),
	tree234__count(T2, N2),
	tree234__count(T3, N3),
	N is 3 + N0 + N1 + N2 + N3.

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%
