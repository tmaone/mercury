%---------------------------------------------------------------------------%
% vim: ft=mercury ts=4 sw=4 et
%---------------------------------------------------------------------------%
% Copyright (C) 1996-1997,1999-2002, 2004-2006, 2008-2011 The University of Melbourne.
% This file may only be copied under the terms of the GNU Library General
% Public License - see the file COPYING.LIB in the Mercury distribution.
%---------------------------------------------------------------------------%
%
% File: set_ordlist.m.
% Main authors: conway, fjh.
% Stability: medium.
%
% This file contains a `set' ADT.
% Sets are implemented here as sorted lists without duplicates.
%
%--------------------------------------------------------------------------%
%--------------------------------------------------------------------------%

:- module set_ordlist.
:- interface.

:- import_module bool.
:- import_module list.

%--------------------------------------------------------------------------%

:- type set_ordlist(_T).

    % `set_ordlist.init(Set)' is true iff `Set' is an empty set.
    %
:- pred set_ordlist.init(set_ordlist(_T)::uo) is det.
:- func set_ordlist.init = set_ordlist(T).

    % `set_ordlist.list_to_set(List, Set)' is true iff `Set' is the set
    % containing only the members of `List'.
    %
:- pred set_ordlist.list_to_set(list(T)::in, set_ordlist(T)::out) is det.
:- func set_ordlist.list_to_set(list(T)) = set_ordlist(T).

    % A synonym for set_ordlist.list_to_set/1.
    %
:- func set_ordlist.from_list(list(T)) = set_ordlist(T).

    % `set_ordlist.sorted_list_to_set(List, Set)' is true iff `Set' is
    % the set containing only the members of `List'.  `List' must be sorted.
    %
:- pred set_ordlist.sorted_list_to_set(list(T)::in, set_ordlist(T)::out)
    is det.
:- func set_ordlist.sorted_list_to_set(list(T)) = set_ordlist(T).

    % A synonym for set_ordlist.sorted_list_to_set/1.
    %
:- func set_ordlist.from_sorted_list(list(T)) = set_ordlist(T).

    % `set_ordlist.to_sorted_list(Set, List)' is true iff `List' is the
    % list of all the members of `Set', in sorted order.
    %
:- pred set_ordlist.to_sorted_list(set_ordlist(T)::in, list(T)::out) is det.
:- func set_ordlist.to_sorted_list(set_ordlist(T)) = list(T).

    % `set_ordlist.singleton_set(Set, Elem)' is true iff `Set' is the set
    % containing just the single element `Elem'.
    %
:- pred set_ordlist.singleton_set(set_ordlist(T), T).
:- mode set_ordlist.singleton_set(in, out) is semidet.
:- mode set_ordlist.singleton_set(out, in) is det.

:- func set_ordlist.make_singleton_set(T) = set_ordlist(T).

    % `set_ordlist.equal(SetA, SetB)' is true iff
    % `SetA' and `SetB' contain the same elements.
    %
:- pred set_ordlist.equal(set_ordlist(T)::in, set_ordlist(T)::in) is semidet.

    % `set_ordlist.empty(Set)' is true iff `Set' is an empty set.
    %
:- pred set_ordlist.empty(set_ordlist(_T)::in) is semidet.

:- pred set_ordlist.non_empty(set_ordlist(T)::in) is semidet.

:- pred set_ordlist.is_empty(set_ordlist(T)::in) is semidet.

    % `set_ordlist.subset(SetA, SetB)' is true iff `SetA' is a subset of
    % `SetB'.
    %
:- pred set_ordlist.subset(set_ordlist(T)::in, set_ordlist(T)::in) is semidet.

    % `set_ordlist.superset(SetA, SetB)' is true iff `SetA' is a
    % superset of `SetB'.
    %
:- pred set_ordlist.superset(set_ordlist(T)::in, set_ordlist(T)::in)
    is semidet.

    % `set_ordlist.member(X, Set)' is true iff `X' is a member of `Set'.
    %
:- pred set_ordlist.member(T, set_ordlist(T)).
:- mode set_ordlist.member(in, in) is semidet.
:- mode set_ordlist.member(out, in) is nondet.

    % `set_ordlist.is_member(X, Set, Result)' returns
    % `Result = yes' iff `X' is a member of `Set'.
    %
:- pred set_ordlist.is_member(T::in, set_ordlist(T)::in, bool::out) is det.

    % `set_ordlist.contains(Set, X)' is true iff `X' is a member of `Set'.
    %
:- pred set_ordlist.contains(set_ordlist(T)::in, T::in) is semidet.

    % `set_ordlist.insert(X, Set0, Set)' is true iff `Set' is the union
    % of `Set0' and the set containing only `X'.
    %
:- pred set_ordlist.insert(T::in, set_ordlist(T)::in, set_ordlist(T)::out)
    is det.

:- func set_ordlist.insert(set_ordlist(T), T) = set_ordlist(T).

    % `set_ordlist.insert_list(Xs, Set0, Set)' is true iff `Set' is the
    % union of `Set0' and the set containing only the members of `Xs'.
    %
:- pred set_ordlist.insert_list(list(T)::in,
    set_ordlist(T)::in, set_ordlist(T)::out) is det.
:- func set_ordlist.insert_list(set_ordlist(T), list(T)) = set_ordlist(T).

    % `set_ordlist.delete(Set0, X, Set)' is true iff `Set' is the
    % relative complement of `Set0' and the set containing only `X', i.e.
    % if `Set' is the set which contains all the elements of `Set0'
    % except `X'.
    %
:- pred set_ordlist.delete(T::in, set_ordlist(T)::in, set_ordlist(T)::out)
    is det.
:- func set_ordlist.delete(set_ordlist(T), T) = set_ordlist(T).

    % `set_ordlist.delete_list(Xs, Set0, Set)' is true iff `Set' is the
    % relative complement of `Set0' and the set containing only the members
    % of `Xs'.
    %
:- pred set_ordlist.delete_list(list(T)::in,
    set_ordlist(T)::in, set_ordlist(T)::out) is det.
:- func set_ordlist.delete_list(set_ordlist(T), list(T)) = set_ordlist(T).

    % `set_ordlist.remove(X, Set0, Set)' is true iff `Set0' contains `X',
    % and `Set' is the relative complement of `Set0' and the set
    % containing only `X', i.e.  if `Set' is the set which contains
    % all the elements of `Set0' except `X'.
    %
:- pred set_ordlist.remove(T::in, set_ordlist(T)::in, set_ordlist(T)::out)
    is semidet.

    % `set_ordlist.remove_list(Xs, Set0, Set)' is true iff Xs does not
    % contain any duplicates, `Set0' contains every member of `Xs',
    % and `Set' is the relative complement of `Set0' and the set
    % containing only the members of `Xs'.
    %
:- pred set_ordlist.remove_list(list(T)::in,
    set_ordlist(T)::in, set_ordlist(T)::out) is semidet.

    % `set_ordlist.remove_least(X, Set0, Set)' is true iff `X' is the
    % least element in `Set0', and `Set' is the set which contains all the
    % elements of `Set0' except `X'.

:- pred set_ordlist.remove_least(T::out,
    set_ordlist(T)::in, set_ordlist(T)::out) is semidet.

    % `set_ordlist.union(SetA, SetB, Set)' is true iff `Set' is the union
    % of `SetA' and `SetB'. The efficiency of the union operation is
    % O(card(SetA)+card(SetB)) and is not sensitive to the argument
    % ordering.
    %
:- pred set_ordlist.union(set_ordlist(T)::in, set_ordlist(T)::in,
    set_ordlist(T)::out) is det.

:- func set_ordlist.union(set_ordlist(T), set_ordlist(T)) = set_ordlist(T).

    % `set_ordlist.union_list(A, B)' is true iff `B' is the union of
    % all the sets in `A'
    %
:- func set_ordlist.union_list(list(set_ordlist(T))) = set_ordlist(T).

    % `set_ordlist.power_union(A, B)' is true iff `B' is the union of
    % all the sets in `A'
    %
:- pred set_ordlist.power_union(set_ordlist(set_ordlist(T))::in,
    set_ordlist(T)::out) is det.

:- func set_ordlist.power_union(set_ordlist(set_ordlist(T))) = set_ordlist(T).

    % `set_ordlist.intersect(SetA, SetB, Set)' is true iff `Set' is the
    % intersection of `SetA' and `SetB'. The efficiency of the intersection
    % operation is not influenced by the argument order.
    %
:- pred set_ordlist.intersect(set_ordlist(T), set_ordlist(T), set_ordlist(T)).
:- mode set_ordlist.intersect(in, in, out) is det.
:- mode set_ordlist.intersect(in, in, in) is semidet.

:- func set_ordlist.intersect(set_ordlist(T), set_ordlist(T))
    = set_ordlist(T).

    % `set_ordlist.power_intersect(A, B)' is true iff `B' is the
    % intersection of all the sets in `A'.
    %
:- pred set_ordlist.power_intersect(set_ordlist(set_ordlist(T))::in,
    set_ordlist(T)::out) is det.
:- func set_ordlist.power_intersect(set_ordlist(set_ordlist(T)))
    = set_ordlist(T).

    % `set_ordlist.intersect_list(A) = B' is true iff `B' is the
    % intersection of all the sets in `A'.
    %
:- func set_ordlist.intersect_list(list(set_ordlist(T))) = set_ordlist(T).

    % `set_ordlist.difference(SetA, SetB, Set)' is true iff `Set' is the
    % set containing all the elements of `SetA' except those that
    % occur in `SetB'.
    %
:- pred set_ordlist.difference(set_ordlist(T)::in, set_ordlist(T)::in,
    set_ordlist(T)::out) is det.
:- func set_ordlist.difference(set_ordlist(T), set_ordlist(T))
    = set_ordlist(T).

    % `set_ordlist.count(Set, Count)' is true iff `Set' has
    % `Count' elements.
    %
:- pred set_ordlist.count(set_ordlist(T)::in, int::out) is det.
:- func set_ordlist.count(set_ordlist(T)) = int.

    % Return the set of items for which the given predicate succeeds.
    %
:- func set_ordlist.filter(pred(T1), set_ordlist(T1)) = set_ordlist(T1).
:- mode set_ordlist.filter(pred(in) is semidet, in) = out is det.

    % Return the set of items for which the given predicate succeeds,
    % and the set of items for which it fails.
    %
:- pred set_ordlist.filter(pred(T1), set_ordlist(T1),
    set_ordlist(T1), set_ordlist(T1)).
:- mode set_ordlist.filter(pred(in) is semidet, in, out, out) is det.

:- func set_ordlist.map(func(T1) = T2, set_ordlist(T1)) = set_ordlist(T2).

:- func set_ordlist.filter_map(func(T1) = T2, set_ordlist(T1))
    = set_ordlist(T2).
:- mode set_ordlist.filter_map(func(in) = out is semidet, in) = out is det.

:- pred set_ordlist.filter_map(pred(T1, T2), set_ordlist(T1),
    set_ordlist(T2)).
:- mode set_ordlist.filter_map(pred(in, out) is semidet, in, out) is det.

:- func set_ordlist.fold(func(T1, T2) = T2, set_ordlist(T1), T2) = T2.
:- pred set_ordlist.fold(pred(T1, T2, T2), set_ordlist(T1), T2, T2).
:- mode set_ordlist.fold(pred(in, in, out) is det, in, in, out) is det.
:- mode set_ordlist.fold(pred(in, mdi, muo) is det, in, mdi, muo) is det.
:- mode set_ordlist.fold(pred(in, di, uo) is det, in, di, uo) is det.
:- mode set_ordlist.fold(pred(in, in, out) is semidet, in, in, out)
    is semidet.
:- mode set_ordlist.fold(pred(in, mdi, muo) is semidet, in, mdi, muo)
    is semidet.
:- mode set_ordlist.fold(pred(in, di, uo) is semidet, in, di, uo)
    is semidet.

:- pred set_ordlist.fold2(pred(T1, T2, T2, T3, T3), set_ordlist(T1),
    T2, T2, T3, T3).
:- mode set_ordlist.fold2(pred(in, in, out, in, out) is det, in,
    in, out, in, out) is det.
:- mode set_ordlist.fold2(pred(in, in, out, mdi, muo) is det, in,
    in, out, mdi, muo) is det.
:- mode set_ordlist.fold2(pred(in, in, out, di, uo) is det, in,
    in, out, di, uo) is det.
:- mode set_ordlist.fold2(pred(in, in, out, in, out) is semidet, in,
    in, out, in, out) is semidet.
:- mode set_ordlist.fold2(pred(in, in, out, mdi, muo) is semidet, in,
    in, out, mdi, muo) is semidet.
:- mode set_ordlist.fold2(pred(in, in, out, di, uo) is semidet, in,
    in, out, di, uo) is semidet.

:- pred set_ordlist.fold3(pred(T1, T2, T2, T3, T3, T4, T4),
    set_ordlist(T1), T2, T2, T3, T3, T4, T4).
:- mode set_ordlist.fold3(pred(in, in, out, in, out, in, out) is det, in,
    in, out, in, out, in, out) is det.
:- mode set_ordlist.fold3(pred(in, in, out, in, out, mdi, muo) is det, in,
    in, out, in, out, mdi, muo) is det.
:- mode set_ordlist.fold3(pred(in, in, out, in, out, di, uo) is det, in,
    in, out, in, out, di, uo) is det.
:- mode set_ordlist.fold3(pred(in, in, out, in, out, in, out) is semidet, in,
    in, out, in, out, in, out) is semidet.
:- mode set_ordlist.fold3(pred(in, in, out, in, out, mdi, muo) is semidet, in,
    in, out, in, out, mdi, muo) is semidet.
:- mode set_ordlist.fold3(pred(in, in, out, in, out, di, uo) is semidet, in,
    in, out, in, out, di, uo) is semidet.

:- pred set_ordlist.fold4(pred(T1, T2, T2, T3, T3, T4, T4, T5, T5),
    set_ordlist(T1), T2, T2, T3, T3, T4, T4, T5, T5).
:- mode set_ordlist.fold4(
    pred(in, in, out, in, out, in, out, in, out) is det, in,
    in, out, in, out, in, out, in, out) is det.
:- mode set_ordlist.fold4(
    pred(in, in, out, in, out, in, out, mdi, muo) is det, in,
    in, out, in, out, in, out, mdi, muo) is det.
:- mode set_ordlist.fold4(
    pred(in, in, out, in, out, in, out, di, uo) is det, in,
    in, out, in, out, in, out, di, uo) is det.
:- mode set_ordlist.fold4(
    pred(in, in, out, in, out, in, out, in, out) is semidet, in,
    in, out, in, out, in, out, in, out) is semidet.
:- mode set_ordlist.fold4(
    pred(in, in, out, in, out, in, out, mdi, muo) is semidet, in,
    in, out, in, out, in, out, mdi, muo) is semidet.
:- mode set_ordlist.fold4(
    pred(in, in, out, in, out, in, out, di, uo) is semidet, in,
    in, out, in, out, in, out, di, uo) is semidet.

:- pred set_ordlist.fold5(
    pred(T1, T2, T2, T3, T3, T4, T4, T5, T5, T6, T6),
    set_ordlist(T1), T2, T2, T3, T3, T4, T4, T5, T5, T6, T6).
:- mode set_ordlist.fold5(
    pred(in, in, out, in, out, in, out, in, out, in, out) is det, in,
    in, out, in, out, in, out, in, out, in, out) is det.
:- mode set_ordlist.fold5(
    pred(in, in, out, in, out, in, out, in, out, mdi, muo) is det, in,
    in, out, in, out, in, out, in, out, mdi, muo) is det.
:- mode set_ordlist.fold5(
    pred(in, in, out, in, out, in, out, in, out, di, uo) is det, in,
    in, out, in, out, in, out, in, out, di, uo) is det.
:- mode set_ordlist.fold5(
    pred(in, in, out, in, out, in, out, in, out, in, out) is semidet, in,
    in, out, in, out, in, out, in, out, in, out) is semidet.
:- mode set_ordlist.fold5(
    pred(in, in, out, in, out, in, out, in, out, mdi, muo) is semidet, in,
    in, out, in, out, in, out, in, out, mdi, muo) is semidet.
:- mode set_ordlist.fold5(
    pred(in, in, out, in, out, in, out, in, out, di, uo) is semidet, in,
    in, out, in, out, in, out, in, out, di, uo) is semidet.

:- pred set_ordlist.fold6(pred(T, A, A, B, B, C, C, D, D, E, E, F, F),
    set_ordlist(T), A, A, B, B, C, C, D, D, E, E, F, F).
:- mode set_ordlist.fold6(
    pred(in, in, out, in, out, in, out, in, out, in, out, in, out) is det,
    in, in, out, in, out, in, out, in, out, in, out, in, out) is det.
:- mode set_ordlist.fold6(
    pred(in, in, out, in, out, in, out, in, out, in, out, mdi, muo) is det,
    in, in, out, in, out, in, out, in, out, in, out, mdi, muo) is det.
:- mode set_ordlist.fold6(
    pred(in, in, out, in, out, in, out, in, out, in, out, di, uo) is det,
    in, in, out, in, out, in, out, in, out, in, out, di, uo) is det.
:- mode set_ordlist.fold6(
    pred(in, in, out, in, out, in, out, in, out, in, out, in, out) is semidet,
    in, in, out, in, out, in, out, in, out, in, out, in, out) is semidet.
:- mode set_ordlist.fold6(
    pred(in, in, out, in, out, in, out, in, out, in, out, mdi, muo) is semidet,
    in, in, out, in, out, in, out, in, out, in, out, mdi, muo) is semidet.
:- mode set_ordlist.fold6(
    pred(in, in, out, in, out, in, out, in, out, in, out, di, uo) is semidet,
    in, in, out, in, out, in, out, in, out, in, out, di, uo) is semidet.

    % set_ordlist.divide(Pred, Set, TruePart, FalsePart):
    % TruePart consists of those elements of Set for which Pred succeeds;
    % FalsePart consists of those elements of Set for which Pred fails.
    %
:- pred set_ordlist.divide(pred(T)::in(pred(in) is semidet),
    set_ordlist(T)::in, set_ordlist(T)::out, set_ordlist(T)::out) is det.

    % set_ordlist.divide_by_set(DivideBySet, Set, InPart, OutPart):
    % InPart consists of those elements of Set which are also in DivideBySet;
    % OutPart consists of those elements of Set which are not in DivideBySet.
    %
:- pred set_ordlist.divide_by_set(set_ordlist(T)::in, set_ordlist(T)::in,
    set_ordlist(T)::out, set_ordlist(T)::out) is det.

%--------------------------------------------------------------------------%
%--------------------------------------------------------------------------%

:- implementation.

% Everything below here is not intended to be part of the public interface,
% and will not be included in the Mercury library reference manual.

:- interface.

:- import_module term.  % for var/1.

:- pragma type_spec(set_ordlist.list_to_set/2, T = var(_)).

:- pragma type_spec(set_ordlist.member(in, in), T = var(_)).

:- pragma type_spec(set_ordlist.contains(in, in), T = var(_)).

:- pragma type_spec(set_ordlist.insert/3, T = var(_)).

:- pragma type_spec(set_ordlist.insert_list/3, T = var(_)).

:- pragma type_spec(set_ordlist.union/3, T = var(_)).

:- pragma type_spec(set_ordlist.intersect/3, T = var(_)).

:- pragma type_spec(set_ordlist.difference/3, T = var(_)).

%-----------------------------------------------------------------------------%

:- implementation.

%-----------------------------------------------------------------------------%

    % We use a d.u. type to work around spurious type ambiguity errors when a
    % program makes calls unqualified procedures which could be confused with
    % `list' procedures if the type of `set_ordlist(T) == list(T)' is exposed
    % for intermodule optimisation.
    %
:- type set_ordlist(T)
    --->    sol(list(T)).

%-----------------------------------------------------------------------------%

set_ordlist.init = S :-
    set_ordlist.init(S).

set_ordlist.init(sol([])).

set_ordlist.make_singleton_set(T) = S :-
    set_ordlist.singleton_set(S, T).

set_ordlist.singleton_set(sol([X]), X).

set_ordlist.equal(Set, Set).

set_ordlist.empty(sol([])).

set_ordlist.non_empty(sol([_ | _])).

set_ordlist.is_empty(sol([])).

set_ordlist.list_to_set(Xs) = S :-
    set_ordlist.list_to_set(Xs, S).

set_ordlist.list_to_set(List0, sol(List)) :-
    list.sort_and_remove_dups(List0, List).

set_ordlist.from_list(List) = Set :-
    set_ordlist.list_to_set(List, Set).

set_ordlist.sorted_list_to_set(Xs) = S :-
    set_ordlist.sorted_list_to_set(Xs, S).

set_ordlist.sorted_list_to_set(List0, sol(List)) :-
    list.remove_adjacent_dups(List0, List).

set_ordlist.from_sorted_list(List) = Set :-
    set_ordlist.sorted_list_to_set(List, Set).

set_ordlist.to_sorted_list(S) = Xs :-
    set_ordlist.to_sorted_list(S, Xs).

set_ordlist.to_sorted_list(sol(List), List).

%-----------------------------------------------------------------------------%

set_ordlist.insert(!.S, T) = !:S :-
    set_ordlist.insert(T, !S).

set_ordlist.insert(E, sol(List0), sol(List)) :-
    set_ordlist.insert_2(List0, E, List).

:- pred set_ordlist.insert_2(list(T)::in, T::in, list(T)::out)
    is det.

set_ordlist.insert_2([], E, [E]).
set_ordlist.insert_2([I | Is], E, Js) :-
    compare(R, I, E),
    (
        R = (<),
        set_ordlist.insert_2(Is, E, Ks),
        Js = [I | Ks]
    ;
        R = (=),
        Js = [I | Is]
    ;
        R = (>),
        Js = [E, I | Is]
    ).

set_ordlist.insert_list(!.S, Xs) = !:S :-
    set_ordlist.insert_list(Xs, !S).

set_ordlist.insert_list(List0, !Set) :-
    list.sort_and_remove_dups(List0, List),
    set_ordlist.union(sol(List), !Set).

%-----------------------------------------------------------------------------%

set_ordlist.delete(!.S, T) = !:S :-
    set_ordlist.delete(T, !S).

set_ordlist.delete(Elem, !Set) :-
    set_ordlist.difference(!.Set, sol([Elem]), !:Set).

set_ordlist.delete_list(!.S, Xs) = !:S :-
    set_ordlist.delete_list(Xs, !S).

set_ordlist.delete_list(D, !Set) :-
    list.sort_and_remove_dups(D, DS),
    set_ordlist.difference(!.Set, sol(DS), !:Set).

%-----------------------------------------------------------------------------%

set_ordlist.remove_list(Elems, !Set) :-
    set_ordlist.sort_no_dups(Elems, ElemSet),
    set_ordlist.subset(ElemSet, !.Set),
    set_ordlist.difference(!.Set, ElemSet, !:Set).

    % set_ordlist.sort_no_dups(List, Set) is true iff
    % List is a list with the same elements as Set and
    % List contains no duplicates.
    %
:- pred set_ordlist.sort_no_dups(list(T)::in, set_ordlist(T)::out) is semidet.

set_ordlist.sort_no_dups(List, sol(Set)) :-
    list.sort(List, Set),
    (
        Set = []
    ;
        Set = [Elem | Elems],
        set_ordlist.no_dups(Elem, Elems)
    ).

    % set_ordlist.no_dups(Elem, Set) is true iff Set does not contain Elem,
    % and Set does not contains duplicates.
    %
:- pred set_ordlist.no_dups(T::in, list(T)::in) is semidet.

set_ordlist.no_dups(_, []).
set_ordlist.no_dups(Elem, [Elem0 | Elems]) :-
    Elem \= Elem0,
    set_ordlist.no_dups(Elem0, Elems).

set_ordlist.remove(Elem, sol(Set0), sol(Set)) :-
    list.delete_first(Set0, Elem, Set).

set_ordlist.remove_least(Elem, sol([Elem | Set]), sol(Set)).

%-----------------------------------------------------------------------------%

:- pragma promise_equivalent_clauses(set_ordlist.member/2).

set_ordlist.member(E::out, sol(S)::in) :-
    list.member(E, S).
set_ordlist.member(E::in, S::in) :-
    set_ordlist.is_member(E, S, yes).

set_ordlist.is_member(E, sol(L), R) :-
    set_ordlist.is_member_2(E, L, R).

:- pred set_ordlist.is_member_2(T::in, list(T)::in, bool::out) is det.

set_ordlist.is_member_2(_E, [], no).
set_ordlist.is_member_2(E, [H | T], R) :-
    compare(Res, H, E),
    (
        Res = (<),
        set_ordlist.is_member_2(E, T, R)
    ;
        Res = (=),
        R = yes
    ;
        Res = (>),
        R = no
    ).

set_ordlist.contains(S, E) :-
    set_ordlist.member(E, S).

%-----------------------------------------------------------------------------%

set_ordlist.subset(Subset, Set) :-
    set_ordlist.intersect(Set, Subset, Subset).

set_ordlist.superset(Superset, Set) :-
    set_ordlist.subset(Set, Superset).

set_ordlist.union(S1, S2) = S3 :-
    set_ordlist.union(S1, S2, S3).

set_ordlist.union(sol(Set0), sol(Set1), sol(Set)) :-
    list.merge_and_remove_dups(Set0, Set1, Set).

set_ordlist.union_list(ListofSets) = Set :-
    set_ordlist.init(Set0),
    set_ordlist.power_union_2(ListofSets, Set0, Set).

set_ordlist.power_union(SS) = S :-
    set_ordlist.power_union(SS, S).

set_ordlist.power_union(sol(ListofSets), Set) :-
    Set = set_ordlist.union_list(ListofSets).

:- pred set_ordlist.power_union_2(list(set_ordlist(T))::in, set_ordlist(T)::in,
    set_ordlist(T)::out) is det.

set_ordlist.power_union_2([], Set, Set).
set_ordlist.power_union_2([NextSet | SetofSets], Set0, Set) :-
    set_ordlist.union(Set0, NextSet, Set1),
    set_ordlist.power_union_2(SetofSets, Set1, Set).

%--------------------------------------------------------------------------%

set_ordlist.intersect(S1, S2) = S3 :-
    set_ordlist.intersect(S1, S2, S3).

set_ordlist.intersect(sol(Xs), sol(Ys), sol(Set)) :-
    set_ordlist.intersect_2(Xs, Ys, Set).

:- pred set_ordlist.intersect_2(list(T), list(T), list(T)).
:- mode set_ordlist.intersect_2(in, in, out) is det.
:- mode set_ordlist.intersect_2(in, in, in) is semidet.

set_ordlist.intersect_2([], _, []).
set_ordlist.intersect_2([_ | _], [], []).
set_ordlist.intersect_2([X | Xs], [Y | Ys], Set) :-
    compare(R, X, Y),
    (
        R = (<),
        set_ordlist.intersect_2(Xs, [Y | Ys], Set)
    ;
        R = (=),
        set_ordlist.intersect_2(Xs, Ys, Set0),
        Set = [X | Set0]
    ;
        R = (>),
        set_ordlist.intersect_2([X | Xs], Ys, Set)
    ).

set_ordlist.power_intersect(SS) = S :-
    set_ordlist.power_intersect(SS, S).

set_ordlist.power_intersect(sol(S0), S) :-
    set_ordlist.intersect_list(S0) = S.

set_ordlist.intersect_list([]) = sol([]).
set_ordlist.intersect_list([S0 | Ss]) = S :-
    (
        Ss = [],
        S = S0
    ;
        Ss = [_ | _],
        S1 = set_ordlist.intersect_list(Ss),
        set_ordlist.intersect(S1, S0, S)
    ).

%--------------------------------------------------------------------------%

set_ordlist.difference(S1, S2) = S3 :-
    set_ordlist.difference(S1, S2, S3).

set_ordlist.difference(sol(Xs), sol(Ys), sol(Set)) :-
    set_ordlist.difference_2(Xs, Ys, Set).

:- pred set_ordlist.difference_2(list(T)::in, list(T)::in, list(T)::out)
    is det.

set_ordlist.difference_2([], _, []).
set_ordlist.difference_2([X | Xs], [], [X | Xs]).
set_ordlist.difference_2([X | Xs], [Y | Ys], Set) :-
    compare(R, X, Y),
    (
        R = (<),
        set_ordlist.difference_2(Xs, [Y | Ys], Set0),
        Set = [X | Set0]
    ;
        R = (=),
        set_ordlist.difference_2(Xs, Ys, Set)
    ;
        R = (>),
        set_ordlist.difference_2([X | Xs], Ys, Set)
    ).

%--------------------------------------------------------------------------%

set_ordlist.count(S) = N :-
    set_ordlist.count(S, N).

set_ordlist.count(sol(Set), Count) :-
    list.length(Set, Count).

%-----------------------------------------------------------------------------%

set_ordlist.fold(F, S, A) = B :-
    B = list.foldl(F, set_ordlist.to_sorted_list(S), A).

set_ordlist.fold(P, S, !A) :-
    list.foldl(P, set_ordlist.to_sorted_list(S), !A).

set_ordlist.fold2(P, S, !A, !B) :-
    list.foldl2(P, set_ordlist.to_sorted_list(S), !A, !B).

set_ordlist.fold3(P, S, !A, !B, !C) :-
    list.foldl3(P, set_ordlist.to_sorted_list(S), !A, !B, !C).

set_ordlist.fold4(P, S, !A, !B, !C, !D) :-
    list.foldl4(P, set_ordlist.to_sorted_list(S), !A, !B, !C, !D).

set_ordlist.fold5(P, S, !A, !B, !C, !D, !E) :-
    list.foldl5(P, set_ordlist.to_sorted_list(S), !A, !B, !C, !D, !E).

set_ordlist.fold6(P, S, !A, !B, !C, !D, !E, !F) :-
    list.foldl6(P, set_ordlist.to_sorted_list(S), !A, !B, !C, !D, !E, !F).

%-----------------------------------------------------------------------------%

set_ordlist.filter(P, Set) = TrueSet :-
    List = set_ordlist.to_sorted_list(Set),
    list.filter(P, List, TrueList),
    set_ordlist.sorted_list_to_set(TrueList, TrueSet).

set_ordlist.filter(P, Set, TrueSet, FalseSet) :-
    List = set_ordlist.to_sorted_list(Set),
    list.filter(P, List, TrueList, FalseList),
    set_ordlist.sorted_list_to_set(TrueList, TrueSet),
    set_ordlist.sorted_list_to_set(FalseList, FalseSet).

%-----------------------------------------------------------------------------%

set_ordlist.map(F, Set) = TransformedSet :-
    List = set_ordlist.to_sorted_list(Set),
    TransformedList = list.map(F, List),
    set_ordlist.list_to_set(TransformedList, TransformedSet).

set_ordlist.filter_map(PF, Set) = TransformedTrueSet :-
    set_ordlist.to_sorted_list(Set, List),
    TransformedTrueList = list.filter_map(PF, List),
    set_ordlist.list_to_set(TransformedTrueList, TransformedTrueSet).

set_ordlist.filter_map(PF, Set, TransformedTrueSet) :-
    set_ordlist.to_sorted_list(Set, List),
    list.filter_map(PF, List, TransformedTrueList),
    set_ordlist.list_to_set(TransformedTrueList, TransformedTrueSet).

%-----------------------------------------------------------------------------%

set_ordlist.divide(Pred, sol(Set), sol(TruePart), sol(FalsePart)) :-
    % The calls to reverse allow us to make divide_2 tail recursive.
    % This costs us a higher constant factor, but allows divide to work
    % in constant stack space.
    set_ordlist.divide_2(Pred, Set, [], RevTruePart, [], RevFalsePart),
    list.reverse(RevTruePart, TruePart),
    list.reverse(RevFalsePart, FalsePart).

:- pred set_ordlist.divide_2(pred(T)::in(pred(in) is semidet), list(T)::in,
    list(T)::in, list(T)::out, list(T)::in, list(T)::out) is det.

set_ordlist.divide_2(_Pred, [], RevTrue, RevTrue, RevFalse, RevFalse).
set_ordlist.divide_2(Pred, [H | T], RevTrue0, RevTrue, RevFalse0, RevFalse) :-
    ( Pred(H) ->
        RevTrue1 = [H | RevTrue0],
        RevFalse1 = RevFalse0
    ;
        RevTrue1 = RevTrue0,
        RevFalse1 = [H | RevFalse0]
    ),
    set_ordlist.divide_2(Pred, T, RevTrue1, RevTrue, RevFalse1, RevFalse).

set_ordlist.divide_by_set(sol(DivideBySet), sol(Set),
        sol(TruePart), sol(FalsePart)) :-
    set_ordlist.divide_by_set_2(DivideBySet, Set,
        [], RevTruePart, [], RevFalsePart),
    list.reverse(RevTruePart, TruePart),
    list.reverse(RevFalsePart, FalsePart).

:- pred set_ordlist.divide_by_set_2(list(T1)::in, list(T1)::in,
    list(T1)::in, list(T1)::out,
    list(T1)::in, list(T1)::out) is det.

set_ordlist.divide_by_set_2([], [], !RevTrue, !RevFalse).
set_ordlist.divide_by_set_2([], [H | T], !RevTrue, !RevFalse) :-
    list.append(list.reverse([H | T]), !RevFalse).
set_ordlist.divide_by_set_2([_ | _], [], !RevTrue, !RevFalse).
set_ordlist.divide_by_set_2([Div | Divs], [H | T], !RevTrue, !RevFalse) :-
    compare(R, Div, H),
    (
        R = (=),
        !:RevTrue = [H | !.RevTrue],
        set_ordlist.divide_by_set_2(Divs, T, !RevTrue, !RevFalse)
    ;
        R = (<),
        set_ordlist.divide_by_set_2(Divs, [H | T], !RevTrue, !RevFalse)
    ;
        R = (>),
        !:RevFalse = [H | !.RevFalse],
        set_ordlist.divide_by_set_2([Div | Divs], T, !RevTrue, !RevFalse)
    ).

%-----------------------------------------------------------------------------%
:- end_module set_ordlist.
%-----------------------------------------------------------------------------%
