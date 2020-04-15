%---------------------------------------------------------------------------%
% vim: ft=mercury ts=4 sw=4 et
%---------------------------------------------------------------------------%
% Copyright (C) 2000-2012 The University of Melbourne.
% Copyright (C) 2013-2018, 2020 The Mercury team.
% This file may only be copied under the terms of the GNU General
% Public License - see the file COPYING in the Mercury distribution.
%---------------------------------------------------------------------------%
%
% Output class declarations and definitions in Java.
%
%---------------------------------------------------------------------------%

:- module ml_backend.mlds_to_java_class.
:- interface.

:- import_module ml_backend.mlds.
:- import_module ml_backend.mlds_to_java_util.
:- import_module ml_backend.mlds_to_target_util.

:- import_module io.
:- import_module map.

%---------------------------------------------------------------------------%

:- pred output_class_defn_for_java(java_out_info::in, indent::in,
    mlds_class_defn::in, io::di, io::uo) is det.

%---------------------------------------------------------------------------%

    % Rename class names which are too long. Each class results in a separate
    % `.class' file, so a long class name may exceed filesystem limits.
    % The long names tend to be automatically generated by the compiler.
    %
:- pred maybe_shorten_long_class_name(
    mlds_class_defn::in, mlds_class_defn::out,
    map(mlds_class_name, mlds_class_name)::in,
    map(mlds_class_name, mlds_class_name)::out) is det.

%---------------------------------------------------------------------------%

    % Succeeds iff a given string matches the unqualified interface name
    % of a interface in Mercury's Java runtime system.
    %
:- pred interface_is_special_for_java(string::in) is semidet.

%---------------------------------------------------------------------------%
%---------------------------------------------------------------------------%

:- implementation.

:- import_module backend_libs.
:- import_module backend_libs.c_util.
:- import_module hlds.
:- import_module hlds.hlds_module.
:- import_module mdbcomp.
:- import_module mdbcomp.sym_name.
:- import_module ml_backend.ml_code_util.
:- import_module ml_backend.mlds_to_java_data.
:- import_module ml_backend.mlds_to_java_func.
:- import_module ml_backend.mlds_to_java_name.
:- import_module ml_backend.mlds_to_java_type.
:- import_module parse_tree.
:- import_module parse_tree.java_names.
:- import_module parse_tree.prog_data.
:- import_module parse_tree.prog_foreign.

:- import_module bool.
:- import_module char.
:- import_module int.
:- import_module list.
:- import_module require.
:- import_module string.
:- import_module term.

%---------------------------------------------------------------------------%
%
% Code to output classes.
%

output_class_defn_for_java(!.Info, Indent, ClassDefn, !IO) :-
    ClassDefn = mlds_class_defn(ClassName, ClassArity, Context, Flags, Kind,
        _Imports, Inherits, Implements, TypeParams,
        MemberFields, MemberClasses, MemberMethods, Ctors),
    indent_line_after_context(!.Info ^ joi_line_numbers, marker_comment,
        Context, Indent, !IO),
    output_class_decl_flags_for_java(!.Info, Flags, !IO),

    !Info ^ joi_univ_tvars := TypeParams,

    % Use generics in the output if this class represents a Mercury type.
    ( if list.member(ml_java_mercury_type_interface, Implements) then
        !Info ^ joi_output_generics := do_output_generics
    else
        true
    ),

    output_class_kind_for_java(Kind, !IO),
    output_unqual_class_name_for_java(ClassName, ClassArity, !IO),
    OutputGenerics = !.Info ^ joi_output_generics,
    (
        OutputGenerics = do_output_generics,
        output_generic_tvars(TypeParams, !IO)
    ;
        OutputGenerics = do_not_output_generics
    ),
    io.nl(!IO),

    output_inherits_list(!.Info, Indent + 1, Inherits, !IO),
    output_implements_list(Indent + 1, Implements, !IO),
    output_n_indents(Indent, !IO),
    io.write_string("{\n", !IO),
    (
        ( Kind = mlds_class
        ; Kind = mlds_interface
        ),
        list.foldl(output_field_var_defn_for_java(!.Info, Indent + 1, oa_none),
            MemberFields, !IO),
        list.foldl(output_class_defn_for_java(!.Info, Indent + 1),
            MemberClasses, !IO),
        list.foldl(output_function_defn_for_java(!.Info, Indent + 1, oa_none),
            MemberMethods, !IO)
    ;
        Kind = mlds_struct,
        unexpected($pred, "structs not supported in Java")
    ;
        Kind = mlds_enum,
        list.filter(field_var_defn_is_enum_const,
            MemberFields, EnumConstFields),
        % XXX Why +2?
        output_enum_constants_for_java(!.Info, Indent + 2,
            ClassName, ClassArity, EnumConstFields, !IO),
        io.nl(!IO),
        % XXX Why +2?
        output_enum_ctor_for_java(Indent + 2, ClassName, ClassArity, !IO)
    ),
    io.nl(!IO),
    list.foldl(
        output_function_defn_for_java(!.Info, Indent + 1,
            oa_cname(ClassName, ClassArity)),
        Ctors, !IO),
    output_n_indents(Indent, !IO),
    io.write_string("}\n\n", !IO).

:- pred output_class_kind_for_java(mlds_class_kind::in, io::di, io::uo) is det.

output_class_kind_for_java(Kind, !IO) :-
    (
        Kind = mlds_interface,
        io.write_string("interface ", !IO)
    ;
        ( Kind = mlds_class
        ; Kind = mlds_enum
        ; Kind = mlds_struct
        ),
        io.write_string("class ", !IO)
    ).

    % Output superclass that this class extends. Java does not support
    % multiple inheritance, so more than one superclass is an error.
    %
:- pred output_inherits_list(java_out_info::in, indent::in,
    mlds_class_inherits::in, io::di, io::uo) is det.

output_inherits_list(Info, Indent, Inherits, !IO) :-
    (
        Inherits = inherits_nothing
    ;
        (
            Inherits = inherits_class(BaseClassId),
            BaseType = mlds_class_type(BaseClassId)
        ;
            Inherits = inherits_generic_env_ptr_type,
            BaseType = mlds_generic_env_ptr_type
        ),
        output_n_indents(Indent, !IO),
        io.write_string("extends ", !IO),
        output_type_for_java(Info, BaseType, !IO),
        io.nl(!IO)
    ).

    % Output list of interfaces that this class implements.
    %
:- pred output_implements_list(indent::in, list(mlds_interface_id)::in,
    io::di, io::uo) is det.

output_implements_list(Indent, InterfaceList, !IO)  :-
    (
        InterfaceList = []
    ;
        InterfaceList = [_ | _],
        output_n_indents(Indent, !IO),
        io.write_string("implements ", !IO),
        io.write_list(InterfaceList, ",", output_interface, !IO),
        io.nl(!IO)
    ).

:- pred output_interface(mlds_interface_id::in, io::di, io::uo) is det.

output_interface(Interface, !IO) :-
    Interface = mlds_interface_id(QualClassName, Arity, _),
    QualClassName = qual_class_name(ModuleQualifier, QualKind, ClassName),
    SymName = mlds_module_name_to_sym_name(ModuleQualifier),
    mangle_sym_name_for_java(SymName, convert_qual_kind(QualKind),
        ".", ModuleNameStr),
    io.format("%s.%s", [s(ModuleNameStr), s(ClassName)], !IO),

    % Check if the interface is one of the ones in the runtime system.
    % If it is, we don't need to output the arity.
    ( if interface_is_special_for_java(ClassName) then
        true
    else
        io.format("%d", [i(Arity)], !IO)
    ).

%---------------------------------------------------------------------------%
%
% Code for generating enumerations.
%
% Enumerations are a bit different from normal classes, because although
% the code generator generates them as classes, it treats them as integers.
% Here we treat them as objects (instantiations of the classes) rather than
% just as integers.

    % Output a (Java) constructor for the class representing the enumeration.
    %
:- pred output_enum_ctor_for_java(indent::in, mlds_class_name::in, arity::in,
    io::di, io::uo) is det.

output_enum_ctor_for_java(Indent, ClassName, ClassArity, !IO) :-
    output_n_indents(Indent, !IO),
    io.write_string("private ", !IO),
    output_class_name_arity_for_java(ClassName, ClassArity, !IO),
    io.write_string("(int val) {\n", !IO),
    output_n_indents(Indent + 1, !IO),
    % Call the MercuryEnum constructor, which will set the MR_value field.
    io.write_string("super(val);\n", !IO),
    output_n_indents(Indent, !IO),
    io.write_string("}\n", !IO).

:- pred output_enum_constants_for_java(java_out_info::in, indent::in,
    mlds_class_name::in, arity::in, list(mlds_field_var_defn)::in,
    io::di, io::uo) is det.

output_enum_constants_for_java(Info, Indent, ClassName, ClassArity,
        EnumConsts, !IO) :-
    io.write_list(EnumConsts, "\n",
        output_enum_constant_for_java(Info, Indent, ClassName, ClassArity),
        !IO),
    io.nl(!IO).

:- pred output_enum_constant_for_java(java_out_info::in, indent::in,
    mlds_class_name::in, arity::in, mlds_field_var_defn::in,
    io::di, io::uo) is det.

output_enum_constant_for_java(_Info, Indent, ClassName, ClassArity,
        FieldVarDefn, !IO) :-
    FieldVarDefn = mlds_field_var_defn(FieldVarName, _Context, _Flags,
        _Type, Initializer, _GCStmt),
    % Make a static instance of the constant. The MLDS doesn't retain enum
    % constructor names (that shouldn't be hard to change now) so it is
    % easier to derive the name of the constant later by naming them after
    % the integer values.
    (
        Initializer = init_obj(Rval),
        ( if Rval = ml_const(mlconst_enum(N, _)) then
            output_n_indents(Indent, !IO),
            io.write_string("public static final ", !IO),
            output_class_name_arity_for_java(ClassName, ClassArity, !IO),
            io.format(" K%d = new ", [i(N)], !IO),
            output_class_name_arity_for_java(ClassName, ClassArity, !IO),
            io.format("(%d); ", [i(N)], !IO),

            io.write_string(" /* ", !IO),
            output_field_var_name_for_java(FieldVarName, !IO),
            io.write_string(" */", !IO)
        else
            unexpected($pred, "not mlconst_enum")
        )
    ;
        ( Initializer = no_initializer
        ; Initializer = init_struct(_, _)
        ; Initializer = init_array(_)
        ),
        unexpected($pred, "not mlconst_enum")
    ).

%---------------------------------------------------------------------------%

:- pred output_field_var_decl_for_java(java_out_info::in,
    mlds_field_var_name::in, mlds_type::in, io::di, io::uo) is det.

output_field_var_decl_for_java(Info, FieldVarName, Type, !IO) :-
    output_type_for_java(Info, Type, !IO),
    io.write_char(' ', !IO),
    output_field_var_name_for_java(FieldVarName, !IO).

:- pred output_field_var_defn_for_java(java_out_info::in, indent::in,
    output_aux::in, mlds_field_var_defn::in, io::di, io::uo) is det.

output_field_var_defn_for_java(Info, Indent, OutputAux, FieldVarDefn, !IO) :-
    FieldVarDefn = mlds_field_var_defn(FieldVarName, Context, Flags, Type,
        Initializer, _),
    indent_line_after_context(Info ^ joi_line_numbers, marker_comment,
        Context, Indent, !IO),
    output_field_var_decl_flags_for_java(Flags, !IO),
    output_field_var_decl_for_java(Info, FieldVarName, Type, !IO),
    output_initializer_for_java(Info, OutputAux, Type, Initializer, !IO),
    io.write_string(";\n", !IO).

%---------------------------------------------------------------------------%
%
% Code to output declaration specifiers.
%

:- pred output_field_var_decl_flags_for_java(mlds_field_var_decl_flags::in,
    io::di, io::uo) is det.

output_field_var_decl_flags_for_java(Flags, !IO) :-
    Flags = mlds_field_var_decl_flags(PerInstance, Constness),
    io.write_string("public ", !IO),
    (
        PerInstance = per_instance
    ;
        PerInstance = one_copy,
        io.write_string("static ", !IO)
    ),
    output_overridability_constness_for_java(overridable, Constness, !IO).

:- pred output_class_decl_flags_for_java(java_out_info::in,
    mlds_class_decl_flags::in, io::di, io::uo) is det.

output_class_decl_flags_for_java(_Info, Flags, !IO) :-
    Flags = mlds_class_decl_flags(Access, Overrability, Constness),
    (
        Access = class_public,
        io.write_string("public ", !IO)
    ;
        Access = class_private,
        io.write_string("private ", !IO)
    ),
    % PerInstance = one_copy,
    io.write_string("static ", !IO),
    output_overridability_constness_for_java(Overrability, Constness, !IO).

:- pred output_overridability_constness_for_java(overridability::in,
    constness::in, io::di, io::uo) is det.

output_overridability_constness_for_java(Overridability, Constness, !IO) :-
    ( if
        ( Overridability = sealed
        ; Constness = const
        )
    then
        io.write_string("final ", !IO)
    else
        true
    ).

%---------------------------------------------------------------------------%
%
% Code to rename long class names.
%

maybe_shorten_long_class_name(!ClassDefn, !Renaming) :-
    !.ClassDefn = mlds_class_defn(ClassName0, _ClassArity, _Context, Flags,
        _ClassKind, _Imports, _Inherits, _Implements, _TypeParams,
        _MemberFields0, _MemberClasses0, _MemberMethods0, _Ctors0),
    Flags = mlds_class_decl_flags(Access, _Overridability, _Constness),
    (
        % We only rename private classes for now.
        Access = class_private,
        ClassName = shorten_class_name(ClassName0),
        ( if ClassName = ClassName0 then
            true
        else
            !ClassDefn ^ mcd_class_name := ClassName,
            map.det_insert(ClassName0, ClassName, !Renaming)
        )
    ;
        Access = class_public
    ).

:- func shorten_class_name(string) = string.

shorten_class_name(ClassName0) = ClassName :-
    MangledClassName0 = name_mangle_no_leading_digit(ClassName0),
    ( if string.length(MangledClassName0) < 100 then
        ClassName = ClassName0
    else
        % The new name must not require name mangling, as then the name may
        % again be too long. We replace all non-alphanumeric or underscore
        % characters by underscores. The s_ prefix avoids having f_ as the
        % prefix which is used to indicate a mangled name.
        Left = string.left(ClassName0, 44),
        Middle = c_util.hex_hash32(ClassName0),
        Right = string.right(ClassName0, 44),
        GenName = string.format("s_%s_%s_%s", [s(Left), s(Middle), s(Right)]),
        GenList = string.to_char_list(GenName),
        FilterList = list.map(replace_non_alphanum_underscore, GenList),
        ClassName = string.from_char_list(FilterList)
    ).

:- func replace_non_alphanum_underscore(char) = char.

replace_non_alphanum_underscore(Char) =
    ( if char.is_alnum_or_underscore(Char) then
        Char
    else
        '_'
    ).

%---------------------------------------------------------------------------%

interface_is_special_for_java("MercuryType").
interface_is_special_for_java("MethodPtr").
interface_is_special_for_java("MethodPtr1").
interface_is_special_for_java("MethodPtr2").
interface_is_special_for_java("MethodPtr3").
interface_is_special_for_java("MethodPtr4").
interface_is_special_for_java("MethodPtr5").
interface_is_special_for_java("MethodPtr6").
interface_is_special_for_java("MethodPtr7").
interface_is_special_for_java("MethodPtr8").
interface_is_special_for_java("MethodPtr9").
interface_is_special_for_java("MethodPtr10").
interface_is_special_for_java("MethodPtr11").
interface_is_special_for_java("MethodPtr12").
interface_is_special_for_java("MethodPtr13").
interface_is_special_for_java("MethodPtr14").
interface_is_special_for_java("MethodPtr15").
interface_is_special_for_java("MethodPtrN").

%---------------------------------------------------------------------------%
:- end_module ml_backend.mlds_to_java_class.
%---------------------------------------------------------------------------%
