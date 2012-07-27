%-----------------------------------------------------------------------------%
% vim: ft=mercury ts=4 sw=4 et
%-----------------------------------------------------------------------------%
% Copyright (C) 2001-2009, 2011 The University of Melbourne.
% This file may only be copied under the terms of the GNU General
% Public License - see the file COPYING in the Mercury distribution.
%-----------------------------------------------------------------------------%
%
% File: layout.m.
% Author: zs.
%
% Definitions of Mercury types for representing layout structures within
% the compiler. Layout structures are generated by the compiler, and are
% used by the parts of the runtime system that need to look at the stacks
% (and sometimes the registers) and make sense of their contents. The parts
% of the runtime system that need to do this include exception handling,
% the debugger, the deep profiler and (eventually) the accurate garbage
% collector.
%
% When output by layout_out.m, values of most these types will correspond
% to the C types defined in runtime/mercury_stack_layout.h or
% runtime/mercury_deep_profiling.h; the documentation of those types
% can be found there. The names of the C types are listed next to the
% function symbol whose arguments represent their contents.
%
% The code to generate values of these types is in stack_layout.m and
% deep_profiling.m.
%
% This module should be, but as yet isn't, independent of whether we are
% compiling to LLDS or MLDS.
%
%-----------------------------------------------------------------------------%

:- module ll_backend.layout.
:- interface.

:- import_module hlds.hlds_pred.
:- import_module hlds.hlds_rtti.
:- import_module libs.trace_params.
:- import_module ll_backend.llds.
:- import_module mdbcomp.prim_data.
:- import_module parse_tree.prog_data.

:- import_module assoc_list.
:- import_module bool.
:- import_module list.
:- import_module map.
:- import_module maybe.

%-----------------------------------------------------------------------------%
%
% Closure layouts.
%

:- type closure_proc_id_data
    --->    closure_proc_id_data(
                % defines MR_ClosureId
                caller_proc_label       :: proc_label,
                caller_closure_seq_no   :: int,
                closure_proc_label      :: proc_label,
                closure_module_name     :: module_name,
                closure_file_name       :: string,
                closure_line_number     :: int,
                closure_origin          :: pred_origin,
                closure_goal_path       :: string
            ).

%-----------------------------------------------------------------------------%
%
% Proc layouts and their components.
%

:- type user_event_data
    --->    user_event_data(
                user_event_number       :: int,
                user_event_locns        :: rval,
                user_event_var_nums     :: layout_slot_name
            ).

:- type basic_label_layout
    --->    basic_label_layout(
                proc_label              :: proc_label,
                label_num               :: int,
                proc_layout_name        :: layout_name,
                maybe_port              :: maybe(trace_port),
                maybe_is_hidden         :: maybe(bool),
                label_num_in_module     :: int,
                maybe_goal_path         :: maybe(int), % offset
                maybe_user_info         :: maybe(layout_slot_name)
            ).

:- type label_short_var_info
    --->    label_short_var_info(
                % part of MR_LabelLayout
                lsvi_encoded_var_count  :: int, % encodes #Long=0 and #Short
                lsvi_type_params        :: rval,
                lsvi_ptis               :: int, % -1 if none, otherwise slot#
                lsvi_hlds_var_nums      :: int, % -1 if none, otherwise slot#
                lsvi_short_locns        :: int  % -1 if none, otherwise slot#
            ).

:- type label_long_var_info
    --->    label_long_var_info(
                % part of MR_LabelLayout
                llvi_encoded_var_count  :: int, % encodes #Long>0 and #Short
                llvi_type_params        :: rval,
                llvi_ptis               :: int, % -1 if none, otherwise slot#
                llvi_hlds_var_nums      :: int, % -1 if none, otherwise slot#
                llvi_short_locns        :: int, % -1 if none, otherwise slot#
                llvi_long_locns         :: int  % -1 if none, otherwise slot#
            ).

:- type label_layout_no_vars
    --->    label_layout_no_vars(
                % defines MR_LabelLayoutNoVarInfo
                basic_label_layout
            ).

:- type label_layout_short_vars
    --->    label_layout_short_vars(
                % defines MR_LabelLayout
                basic_label_layout,
                label_short_var_info
            ).

:- type label_layout_long_vars
    --->    label_layout_long_vars(
                % defines MR_LabelLayout
                basic_label_layout,
                label_long_var_info
            ).

%-----------------------------------------------------------------------------%
%
% Proc layouts and their components.
%

:- type proc_layout_stack_traversal
    --->    proc_layout_stack_traversal(
                % defines MR_StackTraversal
                % The proc entry label will be `no' if we don't have
                % static code addresses.
                plst_entry_label        :: maybe(label),

                plst_succip_slot        :: maybe(int),
                plst_stack_slot_count   :: int,
                plst_detism             :: determinism
            ).

    % The deep_slot_info gives the stack slot numbers that hold
    % the values returned by the call port code, which are needed to let
    % exception.throw perform the work we need to do at the excp port.
    % The old_outermost slot is needed only with the save/restore approach;
    % the old_outermost field contain -1 otherwise. All fields will contain
    % -1 if the variables are never saved on the stack because the
    % predicate makes no calls (in which case it cannot throw exceptions,
    % because to do that it would need to call exception.throw, directly or
    % indirectly.)
:- type deep_excp_slots
    --->    deep_excp_slots(
                top_csd                 :: int,
                middle_csd              :: int,
                old_outermost           :: int
            ).

:- type proc_layout_proc_static
    --->    proc_layout_proc_static(
                plps_file_name          :: string,
                plps_line_number        :: int,
                plps_is_in_interface    :: bool,
                plps_excp_slots         :: deep_excp_slots,
                plps_call_site_statics  :: maybe({int, int}),
                plps_coverage_points    :: maybe({int, int})
            ).

:- type table_io_decl_data
    --->    table_io_decl_data(
                % defines MR_TableIoDecl
                tid_proc_ptr            :: layout_name,
                tid_num_ptis            :: int,

                % pseudo-typeinfos for headvars
                tid_ptis                :: rval,

                tid_type_params         :: rval
            ).

:- type data_or_slot_id
    --->    data_or_slot_is_data(data_id)
    ;       data_or_slot_is_slot(layout_slot_name).

:- type proc_layout_exec_trace
    --->    proc_layout_exec_trace(
                % defines MR_ExecTrace
                plet_maybe_call_label_slot  :: maybe(layout_slot_name),

                % The label layouts of the events in the predicate.
                plet_proc_event_layouts     :: layout_slot_name,
                plet_num_proc_event_layouts :: int,

                plet_maybe_table_info       :: maybe(data_or_slot_id),

                % The variable numbers of the head variables, including the
                % ones added by the compiler, in order. The length of the list
                % must be the same as the procedure's arity. The maybe will be
                % `no' if the procedure has no head variables.
                plet_head_var_nums          :: maybe(layout_slot_name),
                plet_num_head_var_nums      :: int,

                % Each variable name is an offset into the module's
                % string table. The maybe will be `no' if the procedure
                % has no variables.
                plet_var_names              :: maybe(layout_slot_name),

                plet_max_var_num            :: int,
                plet_max_reg_r_num          :: int,
                plet_max_reg_f_num          :: int,
                plet_maybe_from_full_slot   :: maybe(int),
                plet_maybe_io_seq_slot      :: maybe(int),
                plet_maybe_trail_slot       :: maybe(int),
                plet_maybe_maxfr_slot       :: maybe(int),
                plet_eval_method            :: eval_method,
                plet_maybe_call_table_slot  :: maybe(int),
                plet_maybe_tail_rec_slot    :: maybe(int),
                plet_eff_trace_level        :: trace_level,
                plet_exec_trace_flags       :: int
            ).

:- type maybe_proc_id_and_more
    --->    no_proc_id_and_more
    ;       proc_id_and_more(
                maybe_proc_static       :: maybe(layout_slot_name),
                maybe_exec_trace        :: maybe(layout_slot_name),

                % The procedure body represented as a list of bytecodes.
                proc_body_bytes         :: maybe(layout_slot_name),

                % The name of the module_common_layout structure.
                proc_module_common      :: layout_name
            ).

:- type proc_layout_data
    --->    proc_layout_data(
                % defines MR_ProcLayout
                proc_layout_label       :: rtti_proc_label,
                proc_layout_trav        :: proc_layout_stack_traversal,
                proc_layout_more        :: maybe_proc_id_and_more
            ).

%-----------------------------------------------------------------------------%
%
% Module layouts and their components.
%

    % This type is for strings which may contain embedded null characters.
    % When a string_with_0s is written, a null character will be written
    % in between each string in the list.
    %
:- type string_with_0s
    --->    string_with_0s(list(string)).

:- type event_set_layout_data
    --->    event_set_layout_data(
                event_set_data,

                % Maps each event number to an rval that gives the vector
                % of typeinfos for the arguments of that event.
                map(int, rval)
            ).

:- type file_layout_data
    --->    file_layout_data(
                file_name               :: string,
                line_no_label_list      :: assoc_list(int, layout_slot_name)
            ).

:- type module_layout_data
    --->    module_layout_common_data(
                % defines MR_ModuleCommonLayout
                mlcd_module_common_name     :: module_name,
                mlcd_string_table_size      :: int,
                mlcd_string_table           :: string_with_0s
            )
    ;       module_layout_data(
                % defines MR_ModuleLayout
                mld_module_name             :: module_name,
                mld_module_common           :: layout_name,
                mld_proc_layout_names       :: list(layout_name),
                mld_file_layouts            :: list(file_layout_data),
                mld_trace_level             :: trace_level,
                mld_suppressed_events       :: int,
                mld_num_label_exec_count    :: int,
                mld_maybe_event_specs       :: maybe(event_set_layout_data)
            ).

%-----------------------------------------------------------------------------%
%
% Allocation site information
%

:- type alloc_site_info
    --->    alloc_site_info(
                % define MR_AllocSiteInfo
                as_proc_label       :: proc_label,
                as_context          :: prog_context,
                as_type             :: string,
                as_size             :: int
            ).

%-----------------------------------------------------------------------------%
%
% Global variables that hold arrays of layout structures.
%

:- type label_vars
    --->    label_has_no_var_info
    ;       label_has_short_var_info
    ;       label_has_long_var_info.

:- type layout_slot_name
    --->    layout_slot(layout_array_name, int).

:- type layout_array_name
    --->    pseudo_type_info_array
    ;       hlds_var_nums_array
    ;       short_locns_array
    ;       long_locns_array
    ;       user_event_layout_array
    ;       user_event_var_nums_array
    ;       label_layout_array(label_vars)

    ;       proc_static_call_sites_array
    ;       proc_static_cp_static_array
    ;       proc_static_cp_dynamic_array
    ;       proc_static_array
    ;       proc_head_var_nums_array
            % A vector of variable numbers, containing the numbers of the
            % procedure's head variables, including the ones generated by
            % the compiler.
    ;       proc_var_names_array
            % A vector of variable names (represented as offsets into
            % the string table) for a procedure layout structure.
    ;       proc_body_bytecodes_array
    ;       proc_table_io_decl_array
    ;       proc_event_layouts_array
    ;       proc_exec_trace_array
    ;       threadscope_string_table_array
    ;       alloc_site_array.

%-----------------------------------------------------------------------------%
%
% Global variables that hold individual layout structures.
%

:- type proc_layout_kind
    --->    proc_layout_traversal
    ;       proc_layout_proc_id(proc_layout_user_or_uci).

:- type proc_layout_user_or_uci
    --->    user
    ;       uci.

    % Each layout_name identifies a global variable holding one layout
    % structure. We prefer to put layout structures into arrays, because
    % one array holding all N layout structures of a given kind require
    % less space in the symbol table and relocation information sections
    % of object files than N separate global variables, and the reduction
    % in the number of symbols should also improve link times. In some arrays,
    % it is also possible to use an element or sequence of elements two or more
    % times, giving an element of compression.
    %
    % The layout structures we still put into global variables individually are
    %
    % - procedure layouts, which have to have a name derivable from the name of
    %   the procedure they represent, since in deep profiling grades call site
    %   static structures contain pointers to the proc layout structures of the
    %   callee procedures;
    % - layouts for closures, which are relatively few in number,
    %   so arrays would do little good; and
    % - module layouts and their components, of which each module will have
    %   just one, so arrays would do absolutely *no* good.
    %
:- type layout_name
    --->    proc_layout(rtti_proc_label, proc_layout_kind)
    ;       closure_proc_id(proc_label, int, proc_label)
    ;       file_layout(module_name, int)
    ;       file_layout_line_number_vector(module_name, int)
    ;       file_layout_label_layout_vector(module_name, int)
    ;       module_layout_string_table(module_name)
    ;       module_layout_file_vector(module_name)
    ;       module_layout_proc_vector(module_name)
    ;       module_layout_label_exec_count(module_name, int)
    ;       module_layout_event_set_desc(module_name)
    ;       module_layout_event_arg_names(module_name, int)
    ;       module_layout_event_synth_attrs(module_name, int)
    ;       module_layout_event_synth_attr_args(module_name, int, int)
    ;       module_layout_event_synth_attr_order(module_name, int, int)
    ;       module_layout_event_synth_order(module_name, int)
    ;       module_layout_event_specs(module_name)
    ;       module_common_layout(module_name)
    ;       module_layout(module_name).

%-----------------------------------------------------------------------------%
:- end_module layout.
%-----------------------------------------------------------------------------%