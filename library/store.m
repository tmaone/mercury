%-----------------------------------------------------------------------------%
% Copyright (C) 1994-1997 The University of Melbourne.
% This file may only be copied under the terms of the GNU Library General
% Public License - see the file COPYING.LIB in the Mercury distribution.
%-----------------------------------------------------------------------------%
%
% File: store.m. 
% Main author: fjh.
% Stability: low.
%
% This file provides facilities for manipulating mutable stores.
% A store can be consider a mapping from abstract keys to their values.
% A store holds a set of nodes, each of which may contain a value of any
% type.
%
% Stores may be used to implement cyclic data structures such as
% circular linked lists, etc.
%
% Stores can have two different sorts of keys:
% mutable variables (mutvars) and references (refs).
% The difference between mutvars and refs is that
% mutvars can only be updated atomically,
% whereas it is possible to update individual fields of a reference
% one at a time (presuming the reference refers to a structured term).
%
%-----------------------------------------------------------------------------%
%-----------------------------------------------------------------------------%

:- module store.
:- interface.

% Stores and keys are indexed by a type S that is used to distinguish
% between different stores.  The idea is to use an existential type
% declaration for store__init:
%	:- some [S] pred store__init(store(S)).
% That way, we could use the type system to ensure at compile time
% that you never attempt to use a key from one store to access a
% different store.
% However, Mercury doesn't yet support existential types :-(
% For the moment we just use a type `some_store_type'
% instead of `some [S] ... S'. 
% So currently this check is not done --
% if you attempt to use a key from one store to access a
% different store, the behaviour is undefined.
% This will hopefully be rectified in some future version when
% Mercury does support existential types.

:- type store(S).

:- type some_store_type.

	% initialize a store
:- pred store__init(store(some_store_type)).
:- mode store__init(uo) is det.

%-----------------------------------------------------------------------------%
%
% mutvars
%

	% mutvar(T, S):
	% a mutable variable holding a value of type T in store S
:- type mutvar(T, S).

	% create a new mutable variable,
	% initialized with the specified value
:- pred store__new_mutvar(T, mutvar(T, S), store(S), store(S)).
:- mode store__new_mutvar(in, out, di, uo) is det.

	% lookup the value stored in a given mutable variable
:- pred store__get_mutvar(mutvar(T, S), T, store(S), store(S)).
:- mode store__get_mutvar(in, out, di, uo) is det.

	% replace the value stored in a given mutable variable
:- pred store__set_mutvar(mutvar(T, S), T, store(S), store(S)).
:- mode store__set_mutvar(in, in, di, uo) is det.

/* 
The syntax might be nicer if we used some new operators

	:- op(.., xfx, ('<-')).
	:- op(.., fy, ('!')).
	:- op(.., xfx, (':=')).

Then we could do something like this:

	Ptr <- new(Val)	  -->	new_mutvar(Val, Ptr).
	Val <- !Ptr 	  -->	get_mutvar(Ptr, Val).
	!Ptr := Val	  -->	set_mutvar(Ptr, Val).

I wonder whether it is worth it?
*/

%-----------------------------------------------------------------------------%
%
% references
%

	% mutvar(T, S):
	% a reference to value of type T in store S
:- type ref(T, S).

	% new_ref(Val, Ref):	
	%	/* In C: Ref = malloc(...); *Ref = Val; */
	% Given a value of any type `T', insert a copy of the term
	% into the store and return a new reference to that term.
	% (This does not actually perform a copy, it just returns a view
	% of the representation of that value.
	% It does however allocate one cell to hold the reference;
	% you can use new_arg_ref to avoid that.)
:- pred store__new_ref(T, ref(T, S), store(S), store(S)).
:- mode store__new_ref(di, out, di, uo) is det.

	% ref_functor(Ref, Functor, Arity):
	% Given a reference to a term, return the functor and arity
	% of that term.
:- pred store__ref_functor(ref(T, S), string, int, store(S), store(S)).
:- mode store__ref_functor(in, out, out, di, uo) is det.

	% arg_ref(Ref, ArgNum, ArgRef):	     
	%	/* Psuedo-C code: ArgRef = &Ref[ArgNum]; */
	% Given a reference to a term, return a reference to
	% the specified argument (field) of that term
	% (argument numbers start from zero).
	% It is an error if the argument number is out of range,
	% or if the argument reference has the wrong type.
:- pred store__arg_ref(ref(T, S), int, ref(ArgT, S), store(S), store(S)).
:- mode store__arg_ref(in, in, out, di, uo) is det.

	% new_arg_ref(Val, ArgNum, ArgRef):
	%	/* Psuedo-C code: ArgRef = &Val[ArgNum]; */
	% Equivalent to `new_ref(Val, Ref), arg_ref(Ref, ArgNum, ArgRef)',
	% except that it is more efficient.
	% It is an error if the argument number is out of range,
	% or if the argument reference has the wrong type.
:- pred store__new_arg_ref(T, int, ref(ArgT, S), store(S), store(S)).
:- mode store__new_arg_ref(di, in, out, di, uo) is det.

	% set_ref(Ref, ValueRef):
	%	/* Pseudo-C code: *Ref = *ValueRef; */
	% Given a reference to a term (Ref), 
	% a reference to another term (ValueRef),
	% update the store so that the term referred to by Ref
	% is replaced with the term referenced by ValueRef.
:- pred store__set_ref(ref(T, S), ref(T, S), store(S), store(S)).
:- mode store__set_ref(in, in, di, uo) is det.

	% set_ref_value(Ref, Value):
	%	/* Pseudo-C code: *Ref = Value; */
	% Given a reference to a term (Ref), and a value (Value),
	% update the store so that the term referred to by Ref
	% is replaced with Value.
	% (Argument numbers start from zero).
:- pred store__set_ref_value(ref(T, S), ArgT, store(S), store(S)).
:- mode store__set_ref_value(in, di, di, uo) is det.

	% Given a reference to a term, return that term.
	% Note that this requires making a copy, so this pred may
	% be inefficient if used to return large terms; it
	% is most efficient with atomic terms.
:- pred store__copy_ref_value(ref(T, S), T, store(S), store(S)).
:- mode store__copy_ref_value(in, uo, di, uo) is det.

	% Same as above, but without making a copy.
	% Destroys the store.
:- pred store__extract_ref_value(store(S), ref(T, S), T).
:- mode store__extract_ref_value(di, in, out) is det.

%-----------------------------------------------------------------------------%
%
% Nasty performance hacks
%
% WARNING: use of these procedures is dangerous!
% Use them only only as a last resort, only if performance
% is critical, and only if profiling shows that using the
% safe versions is a bottleneck.
%
% These procedures may vanish in some future version of Mercury.

	% `unsafe_arg_ref' is the same as `arg_ref',
	% and `unsafe_new_arg_ref' is the same as `new_arg_ref'
	% except that they doesn't check for errors,
	% and they don't work for `no_tag' types (types with
	% exactly one functor which has exactly one argument),
	% and they don't work for types with >4 functors.
	% If the argument number is out of range,
	% or if the argument reference has the wrong type,
	% or if the argument is a `no_tag' type,
	% then the behaviour is undefined, and probably harmful.

:- pred store__unsafe_arg_ref(ref(T, S), int, ref(ArgT, S), store(S), store(S)).
:- mode store__unsafe_arg_ref(in, in, out, di, uo) is det.

:- pred store__unsafe_new_arg_ref(T, int, ref(ArgT, S), store(S), store(S)).
:- mode store__unsafe_new_arg_ref(di, in, out, di, uo) is det.

%-----------------------------------------------------------------------------%
%-----------------------------------------------------------------------------%

:- implementation.
:- import_module std_util.

:- type mutvar(T, S).

:- type store(S).

:- pragma c_code(init(_S0::uo), will_not_call_mercury, "").

:- pragma c_code(new_mutvar(Val::in, Mutvar::out, S0::di, S::uo),
		will_not_call_mercury,
"
	incr_hp(Mutvar, 1);
	*(Word *)Mutvar = Val;
	S = S0;
").

:- pragma c_code(get_mutvar(Mutvar::in, Val::out, S0::di, S::uo),
		will_not_call_mercury,
"
	Val = *(Word *)Mutvar;
	S = S0;
").

:- pragma c_code(set_mutvar(Mutvar::in, Val::in, S0::di, S::uo),
		will_not_call_mercury,
"
	*(Word *)Mutvar = Val;
	S = S0;
").

%-----------------------------------------------------------------------------%

:- pragma c_code(new_ref(Val::di, Ref::out, S0::di, S::uo),
		will_not_call_mercury,
"
	incr_hp(Ref, 1);
	*(Word *)Ref = Val;
	S = S0;
").

copy_ref_value(Ref, Val) -->
	/* XXX need to deep-copy non-atomic types */
	unsafe_ref_value(Ref, Val).

	% unsafe_ref_value extracts the value that a reference
	% refers to, without making a copy; it is unsafe because
	% the store could later be modified, changing the returned
	% value.
:- pred store__unsafe_ref_value(ref(T, S), T, store(S), store(S)).
:- mode store__unsafe_ref_value(in, uo, di, uo) is det.
:- pragma c_code(unsafe_ref_value(Ref::in, Val::uo, S0::di, S::uo),
		will_not_call_mercury,
"
	Val = *(Word *)Ref;
	S = S0;
").

ref_functor(Ref, Functor, Arity) -->
	unsafe_ref_value(Ref, Val),
	{ functor(Val, Functor, Arity) }.

:- pragma c_header_code("
	/* ML_arg() is defined in std_util.m */
	bool ML_arg(Word term_type_info, Word *term, Word argument_index,
			Word *arg_type_info, Word **argument_ptr);
").

:- pragma c_code(arg_ref(Ref::in, ArgNum::in, ArgRef::out, S0::di, S::uo),
		will_not_call_mercury,
"{
	Word arg_type_info;
	Word* arg_ref;

	save_transient_registers();

	if (!ML_arg(TypeInfo_for_T, (Word *) Ref, ArgNum,
			&arg_type_info, &arg_ref))
	{
		fatal_error(""store__arg_ref: argument number out of range"");
	}

	if (ML_compare_type_info(arg_type_info, TypeInfo_for_ArgT) !=
		COMPARE_EQUAL)
	{
		fatal_error(""store__arg_ref: argument has wrong type"");
	}

	restore_transient_registers();

	ArgRef = (Word) arg_ref;
	S = S0;
}").

:- pragma c_code(new_arg_ref(Val::di, ArgNum::in, ArgRef::out, S0::di, S::uo),
		will_not_call_mercury,
"{
	Word arg_type_info;
	Word* arg_ref;

	save_transient_registers();

	if (!ML_arg(TypeInfo_for_T, (Word *) &Val, ArgNum,
			&arg_type_info, &arg_ref))
	{
	      fatal_error(""store__new_arg_ref: argument number out of range"");
	}

	if (ML_compare_type_info(arg_type_info, TypeInfo_for_ArgT) !=
		COMPARE_EQUAL)
	{
	      fatal_error(""store__new_arg_ref: argument has wrong type"");
	}

	restore_transient_registers();

	/*
	** For no_tag types, the argument may have the same address as the
	** term.  Since the term (Val) is currently on the C stack, we can't
	** return a pointer to it; so if that is the case, then we need
	** to copy it to the heap before returning.
	*/
	if (arg_ref == &Val) {
		incr_hp(ArgRef, 1);
		*(Word *)ArgRef = Val;
	} else {
		ArgRef = (Word) arg_ref;
	}
	S = S0;
}").

:- pragma c_code(set_ref(Ref::in, ValRef::in, S0::di, S::uo),
		will_not_call_mercury,
"
	*(Word *)Ref = *(Word *)ValRef;
	S = S0;
").

:- pragma c_code(set_ref_value(Ref::in, Val::di, S0::di, S::uo),
		will_not_call_mercury,
"
	*(Word *)Ref = Val;
	S = S0;
").

:- pragma c_code(extract_ref_value(_S::di, Ref::in, Val::out),
		will_not_call_mercury,
"
	Val = *(Word *)Ref;
").

%-----------------------------------------------------------------------------%

:- pragma c_code(unsafe_arg_ref(Ref::in, Arg::in, ArgRef::out, S0::di, S::uo),
		will_not_call_mercury,
"{
	/* unsafe - does not check type & arity, won't handle no_tag types */
	Word *Ptr = (Word *) strip_tag(Ref);
	ArgRef = (Word) &Ptr[Arg];
	S = S0;
}").

:- pragma c_code(unsafe_new_arg_ref(Val::di, Arg::in, ArgRef::out,
				S0::di, S::uo), will_not_call_mercury,
"{
	/* unsafe - does not check type & arity, won't handle no_tag types */
	Word *Ptr = (Word *) strip_tag(Val);
	ArgRef = (Word) &Ptr[Arg];
	S = S0;
}").

%-----------------------------------------------------------------------------%
