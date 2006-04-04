/*
** vim: ts=4 sw=4 expandtab
*/
/*
** Copyright (C) 1998-2006 The University of Melbourne.
** This file may only be copied under the terms of the GNU Library General
** Public License - see the file COPYING.LIB in the Mercury distribution.
*/

/*
** mercury_trace_browse.c
**
** Main author: fjh
**
** This file provides the C interface to browser/browse.m
** and browser/interactive_query.m.
*/

/*
** Some header files refer to files automatically generated by the Mercury
** compiler for modules in the browser and library directories.
**
** XXX figure out how to prevent these names from encroaching on the user's
** name space.
*/

#include "mercury_imp.h"
#include "mercury_deep_copy.h"

#include "mercury_trace_browse.h"
#include "mercury_trace_util.h"
#include "mercury_trace_internal.h"
#include "mercury_trace_external.h"

#include "mdb.browse.mh"
#include "mdb.browser_info.mh"
#include "mdb.browser_term.mh"
#include "mdb.interactive_query.mh"

#include "type_desc.mh"

#include <stdio.h>

static  MR_TypeInfo MR_trace_browser_persistent_state_type;

MR_Word             MR_trace_browser_persistent_state;

MR_Word
MR_type_value_to_browser_term(MR_TypeInfo type_info, MR_Word value)
{
    MR_Word browser_term;

    MR_TRACE_CALL_MERCURY(
        browser_term = ML_BROWSE_plain_term_to_browser_term(
            (MR_Word) type_info, value);
    );
    return browser_term;
}

MR_Word
MR_univ_to_browser_term(MR_Word univ)
{
    MR_Word browser_term;

    MR_TRACE_CALL_MERCURY(
        browser_term = ML_BROWSE_univ_to_browser_term(univ);
    );
    return browser_term;
}

MR_Word
MR_synthetic_to_browser_term(const char *functor, MR_Word arg_list,
    MR_bool is_func)
{
    MR_Word browser_term;

    MR_TRACE_CALL_MERCURY(
        browser_term = ML_BROWSE_synthetic_term_to_browser_term(
            (MR_String) (MR_Integer) functor, arg_list, is_func);
    );
    return browser_term;
}

void
MR_trace_save_term(const char *filename, MR_Word browser_term)
{
    MercuryFile mdb_out;
    MR_String   mercury_filename;
    MR_String   mercury_format;

    MR_trace_browse_ensure_init();

    mercury_filename = (MR_String) (MR_Integer) filename;
    mercury_format = (MR_String) (MR_Integer) "default";
    MR_c_file_to_mercury_file(MR_mdb_out, &mdb_out);
    MR_TRACE_CALL_MERCURY(
        ML_BROWSE_save_term_to_file(mercury_filename, mercury_format,
            browser_term, &mdb_out);
    );
}

void
MR_trace_save_term_xml(const char *filename, MR_Word browser_term)
{
    MercuryFile mdb_out;
    MR_String   mercury_filename;

    mercury_filename = (MR_String) (MR_Integer) filename;

    MR_c_file_to_mercury_file(MR_mdb_out, &mdb_out);
    MR_TRACE_CALL_MERCURY(
        ML_BROWSE_save_term_to_file_xml(mercury_filename, browser_term,
            &mdb_out);
    );
}

void
MR_trace_save_and_invoke_xml_browser(MR_Word browser_term)
{
    MercuryFile mdb_out;
    MercuryFile mdb_err;

    MR_c_file_to_mercury_file(MR_mdb_out, &mdb_out);
    MR_c_file_to_mercury_file(MR_mdb_err, &mdb_err);

    MR_TRACE_CALL_MERCURY(
        ML_BROWSE_browse_term_xml(browser_term, &mdb_out, &mdb_err,
            MR_trace_browser_persistent_state);
    );
}

MR_bool
MR_trace_is_portray_format(const char *str, MR_Browse_Format *format)
{
    *format = MR_BROWSE_DEFAULT_FORMAT;

    if (MR_streq(str, "flat")) {
        *format = MR_BROWSE_FORMAT_FLAT;
        return MR_TRUE;
    } else if (MR_streq(str, "raw_pretty")) {
        *format = MR_BROWSE_FORMAT_RAW_PRETTY;
        return MR_TRUE;
    } else if (MR_streq(str, "verbose")) {
        *format = MR_BROWSE_FORMAT_VERBOSE;
        return MR_TRUE;
    } else if (MR_streq(str, "pretty")) {
        *format = MR_BROWSE_FORMAT_PRETTY;
        return MR_TRUE;
    }

    return MR_FALSE;
}

void
MR_trace_browse(MR_Word type_info, MR_Word value, MR_Browse_Format format)
{
    MercuryFile mdb_in;
    MercuryFile mdb_out;
    MR_Word     maybe_mark;
    MR_Word     browser_term;

    MR_trace_browse_ensure_init();

    MR_c_file_to_mercury_file(MR_mdb_in, &mdb_in);
    MR_c_file_to_mercury_file(MR_mdb_out, &mdb_out);

    browser_term = MR_type_value_to_browser_term((MR_TypeInfo) type_info,
        value);

    if (format != MR_BROWSE_DEFAULT_FORMAT) {
        MR_TRACE_CALL_MERCURY(
            ML_BROWSE_browse_browser_term_format(browser_term,
                &mdb_in, &mdb_out, (MR_Word) format,
                MR_trace_browser_persistent_state,
                &MR_trace_browser_persistent_state);
        );
    } else {
        MR_TRACE_CALL_MERCURY(
            ML_BROWSE_browse_browser_term(browser_term,
                &mdb_in, &mdb_out, &maybe_mark,
                MR_trace_browser_persistent_state,
                &MR_trace_browser_persistent_state);
        );
    }
    MR_trace_browser_persistent_state =
        MR_make_permanent(MR_trace_browser_persistent_state,
            MR_trace_browser_persistent_state_type);
}

void
MR_trace_browse_goal(MR_ConstString name, MR_Word arg_list, MR_Word is_func,
    MR_Browse_Format format)
{
    MercuryFile mdb_in;
    MercuryFile mdb_out;
    MR_Word     maybe_mark;
    MR_Word     browser_term;

    MR_trace_browse_ensure_init();

    MR_c_file_to_mercury_file(MR_mdb_in, &mdb_in);
    MR_c_file_to_mercury_file(MR_mdb_out, &mdb_out);

    browser_term = MR_synthetic_to_browser_term(name, arg_list, is_func);

    if (format != MR_BROWSE_DEFAULT_FORMAT) {
        MR_TRACE_CALL_MERCURY(
            ML_BROWSE_browse_browser_term_format(browser_term,
                &mdb_in, &mdb_out, (MR_Word) format,
                MR_trace_browser_persistent_state,
                &MR_trace_browser_persistent_state);
        );
    } else {
        MR_TRACE_CALL_MERCURY(
            ML_BROWSE_browse_browser_term(browser_term,
                &mdb_in, &mdb_out, &maybe_mark,
                MR_trace_browser_persistent_state,
                &MR_trace_browser_persistent_state);
        );
    }
    MR_trace_browser_persistent_state =
        MR_make_permanent(MR_trace_browser_persistent_state,
            MR_trace_browser_persistent_state_type);
}

/*
** MR_trace_browse_external() is the same as MR_trace_browse() except it
** uses debugger_socket_in and debugger_socket_out to read program-readable
** terms, whereas MR_trace_browse() uses mdb_in and mdb_out to read
** human-readable strings.
*/

#ifdef MR_USE_EXTERNAL_DEBUGGER

void
MR_trace_browse_external(MR_Word type_info, MR_Word value,
        MR_Browse_Caller_Type caller, MR_Browse_Format format)
{
    MR_trace_browse_ensure_init();

    MR_TRACE_CALL_MERCURY(
        ML_BROWSE_browse_external(type_info, value,
            &MR_debugger_socket_in, &MR_debugger_socket_out,
            MR_trace_browser_persistent_state,
            &MR_trace_browser_persistent_state);
    );
    MR_trace_browser_persistent_state =
        MR_make_permanent(MR_trace_browser_persistent_state,
            MR_trace_browser_persistent_state_type);
}

#endif

void
MR_trace_print(MR_Word type_info, MR_Word value, MR_Browse_Caller_Type caller,
    MR_Browse_Format format)
{
    MercuryFile mdb_out;
    MR_Word     browser_term;

    MR_trace_browse_ensure_init();

    MR_c_file_to_mercury_file(MR_mdb_out, &mdb_out);

    browser_term = MR_type_value_to_browser_term((MR_TypeInfo) type_info,
        value);

    if (format != MR_BROWSE_DEFAULT_FORMAT) {
        MR_TRACE_CALL_MERCURY(
            ML_BROWSE_print_browser_term_format(browser_term, &mdb_out, caller,
                (MR_Word) format, MR_trace_browser_persistent_state);
        );
    } else {
        MR_TRACE_CALL_MERCURY(
            ML_BROWSE_print_browser_term(browser_term, &mdb_out,
                (MR_Word) caller, MR_trace_browser_persistent_state);
        );
    }
}

void
MR_trace_print_goal(MR_ConstString name, MR_Word arg_list, MR_Word is_func,
    MR_Browse_Caller_Type caller, MR_Browse_Format format)
{
    MercuryFile mdb_out;
    MR_Word     browser_term;

    MR_trace_browse_ensure_init();

    MR_c_file_to_mercury_file(MR_mdb_out, &mdb_out);

    browser_term = MR_synthetic_to_browser_term(name, arg_list, is_func);

    if (format != MR_BROWSE_DEFAULT_FORMAT) {
        MR_TRACE_CALL_MERCURY(
            ML_BROWSE_print_browser_term_format(browser_term, &mdb_out, caller,
                (MR_Word) format, MR_trace_browser_persistent_state);
        );
    } else {
        MR_TRACE_CALL_MERCURY(
            ML_BROWSE_print_browser_term(browser_term, &mdb_out,
                (MR_Word) caller, MR_trace_browser_persistent_state);
        );
    }
}

void
MR_trace_print_all_browser_params(FILE *fp, MR_bool mdb_command_format)
{
    MR_String   param_string;

    MR_trace_browse_ensure_init();
    MR_TRACE_CALL_MERCURY(
        ML_BROWSE_browser_params_to_string(MR_trace_browser_persistent_state,
            mdb_command_format, &param_string);
    );

    fprintf(fp, param_string);
}

void
MR_trace_browse_ensure_init(void)
{
    static  MR_bool done = MR_FALSE;
    MR_Word         typeinfo_type_word;
    MR_Word         MR_trace_browser_persistent_state_type_word;

    if (! done) {
        MR_TRACE_CALL_MERCURY(
            typeinfo_type_word = ML_get_type_info_for_type_info();
            ML_BROWSE_browser_persistent_state_type(
                &MR_trace_browser_persistent_state_type_word);
            ML_BROWSE_init_persistent_state(
                &MR_trace_browser_persistent_state);
        );

        MR_trace_browser_persistent_state_type =
            (MR_TypeInfo) MR_make_permanent(
                MR_trace_browser_persistent_state_type_word,
                (MR_TypeInfo) typeinfo_type_word);
        MR_trace_browser_persistent_state = MR_make_permanent(
                MR_trace_browser_persistent_state,
                MR_trace_browser_persistent_state_type);
        done = MR_TRUE;
    }
}

void
MR_trace_query(MR_Query_Type type, const char *options, int num_imports,
    char *imports[])
{
    MR_ConstString  options_on_heap;
    MR_Word         imports_list;
    MercuryFile     mdb_in;
    MercuryFile     mdb_out;
    int             i;

    MR_c_file_to_mercury_file(MR_mdb_in, &mdb_in);
    MR_c_file_to_mercury_file(MR_mdb_out, &mdb_out);

    if (options == NULL) {
        options = "";
    }

    MR_TRACE_USE_HP(
        MR_make_aligned_string(options_on_heap, options);

        imports_list = MR_list_empty();
        for (i = num_imports; i > 0; i--) {
            MR_ConstString this_import;
            MR_make_aligned_string(this_import, imports[i - 1]);
            imports_list = MR_string_list_cons((MR_Word) this_import,
                imports_list);
        }
    );

    MR_TRACE_CALL_MERCURY(
        ML_query(type, imports_list, (MR_String) options_on_heap,
            &mdb_in, &mdb_out);
    );
}

#ifdef MR_USE_EXTERNAL_DEBUGGER

void
MR_trace_query_external(MR_Query_Type type, MR_String options, int num_imports,
    MR_Word imports_list)
{
    MR_TRACE_CALL_MERCURY(
        ML_query_external(type, imports_list, options,
            &MR_debugger_socket_in, &MR_debugger_socket_out);
    );
}

#endif
