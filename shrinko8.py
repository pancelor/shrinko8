#!/usr/bin/env python3
from utils import *
from pico_process import PicoContext, process_code, CartSource, CustomPreprocessor, ErrorFormat
from pico_compress import write_code_size, write_compressed_size, CompressionTracer
from pico_cart import CartFormat, read_cart, write_cart, read_cart_package, get_bbs_cart_url
from pico_tokenize import k_hint_split_re
import argparse, importlib.util

def SplitBySeps(val):
    return k_hint_split_re.split(val)

def EnumFromStr(enum_type):
    def cvt(name):
        return enum_type(name.replace("-", "_").replace(" ", "_"))
    cvt.__name__ = enum_type.__name__
    return cvt

def EnumList(list):
    return ", ".join(str.replace("_", "-") for str in list)

def ParsableCountHandler(prefix, name, size, limit):
    print("count:%s:%s:%d:%d" % (prefix, name, size, limit))

extend_arg = "extend" if sys.version_info >= (3,8) else None

parser = argparse.ArgumentParser()
parser.add_argument("input", help="input file, can be in any format. ('-' for stdin)")
parser.add_argument("output", help="output file. ('-' for stdout)", nargs='?')
parser.add_argument("-f", "--format", type=EnumFromStr(CartFormat), help="output cart format {%s}" % EnumList(CartFormat._output_names))
parser.add_argument("-F", "--input-format", type=EnumFromStr(CartFormat), help="input cart format {%s}" % EnumList(CartFormat._input_names))
parser.add_argument("-u", "--unicode-caps", action="store_true", help="write capitals as italicized unicode characters (better for copy/paste)")

pgroup = parser.add_argument_group("minify options")
pgroup.add_argument("-m", "--minify", action="store_true", help="enable minification of the cart")
pgroup.add_argument("-M", "--minify-safe-only", action="store_true", help="only do minifaction that's always safe to do")
pgroup.add_argument("-oc", "--focus-chars", action="store_true", help="when minifying, focus on lowering the code's number of chars (uncompressed size)")
pgroup.add_argument("-ob", "--focus-compressed", action="store_true", help="when minifying, focus on lowering the code's compressed size (number of bytes)")
pgroup.add_argument("--no-minify-rename", action="store_true", help="disable variable renaming in minification")
pgroup.add_argument("--no-minify-spaces", action="store_true", help="disable space removal in minification")
pgroup.add_argument("--no-minify-lines", action="store_true", help="disable line removal in minification")
pgroup.add_argument("--no-minify-comments", action="store_true", help="disable comment removal in minification (requires --no-minify-spaces)")
pgroup.add_argument("--no-minify-tokens", action="store_true", help="disable token removal in minification")
pgroup.add_argument("-p", "--preserve", type=SplitBySeps, action=extend_arg, help='preserve specific identifiers in minification, e.g. "global1, global2, *.member2, table3.*"')
pgroup.add_argument("--no-preserve", type=SplitBySeps, action=extend_arg, help='do not preserve specific built-in identifiers in minification, e.g. "circfill, rectfill"')
pgroup.add_argument("--rename-members-as-globals", action="store_true", help='rename globals and members the same way (same as --preserve "*=*.*")')
pgroup.add_argument("--rename-map", help="log renaming of identifiers (from minify step) to this file")

pgroup = parser.add_argument_group("lint options")
pgroup.add_argument("-l", "--lint", action="store_true", help="enable checking the cart for common issues")
pgroup.add_argument("--no-lint-unused", action="store_true", help="don't print lint warnings on unused variables")
pgroup.add_argument("--no-lint-duplicate", action="store_true", help="don't print lint warnings on duplicate variables")
pgroup.add_argument("--no-lint-undefined", action="store_true", help="don't print lint warnings on undefined variables")
pgroup.add_argument("--no-lint-fail", action="store_true", help="create output cart even if there were lint warnings")
pgroup.add_argument("--lint-global", type=SplitBySeps, action=extend_arg, help="don't print lint warnings for these globals (same as '--lint:' comment)")
pgroup.add_argument("--error-format", type=EnumFromStr(ErrorFormat), help="how to format lint warnings & compilation errors {%s}" % EnumList(ErrorFormat._values))

pgroup = parser.add_argument_group("count options")
pgroup.add_argument("-c", "--count", action="store_true", help="enable printing token count, character count & compressed size")
pgroup.add_argument("--input-count", action="store_true", help="enable printing input token count, character count & compressed size")
pgroup.add_argument("--parsable-count", action="store_true", help="output counts in a stable, parsable format")
pgroup.add_argument("--no-count-compress", action="store_true", help="do not compress the cart just to print the compressed size")
pgroup.add_argument("--no-count-tokenize", action="store_true", help="do not tokenize the cart just to print the token count")

pgroup = parser.add_argument_group("unminify options")
pgroup.add_argument("--unminify", action="store_true", help="enable unminification of the cart")
pgroup.add_argument("--unminify-indent", type=int, help="indentation size when unminifying", default=2)

pgroup = parser.add_argument_group("misc. options")
pgroup.add_argument("-s", "--script", help="manipulate the cart via a custom python script - see README for api details")
pgroup.add_argument("--script-args", nargs=argparse.REMAINDER, help="send arguments directly to --script", default=())
pgroup.add_argument("--list", action="store_true", help="list all cart names inside a cart package (%s)" % EnumList(CartFormat._pack_names))
pgroup.add_argument("--cart", help="name of cart to extract from cart package (%s)" % EnumList(CartFormat._pack_names))
pgroup.add_argument("--label", help="path to image to use as the label when creating png carts (default: taken from __label__ like pico8 does)")
pgroup.add_argument("--title", help="title to use when creating png carts (default: taken from first two comments like pico8 does)")
pgroup.add_argument("--extra-output", nargs='+', action="append", metavar=("OUTPUT", "FORMAT"), help="Additional output file to produce (and optionally, the format to use)")

pgroup = parser.add_argument_group("compression options (semi-undocumented)")
pgroup.add_argument("--keep-compression", action="store_true", help="keep existing compression, instead of re-compressing")
pgroup.add_argument("--fast-compression", action="store_true", help="force fast but poor compression (when creating png carts)")
pgroup.add_argument("--best-compression", action="store_true", help="pancelor best compression")
pgroup.add_argument("--force-compression", action="store_true", help="force code compression even if code fits (when creating png carts)")
pgroup.add_argument("--old-compression", action="store_true", help="compress with the old pre-v0.2.0 compression scheme")
pgroup.add_argument("--trace-compression", help="trace the compressed symbols and their cost into this file")
pgroup.add_argument("--trace-input-compression", help="trace the input's compressed symbols and their cost into this file")

pgroup = parser.add_argument_group("other semi-undocumented options")
pgroup.add_argument("--builtin", type=SplitBySeps, action=extend_arg, help="treat identifier(s) as a pico-8 builtin (for minify, lint, etc.)")
pgroup.add_argument("--not-builtin", type=SplitBySeps, action=extend_arg, help="do not treat identifier(s) as a pico-8 builtin (for minify, lint, etc.)")
pgroup.add_argument("--global-builtins-only", action="store_true", help="assume all builtins are global, equivalent to pico8's -global_api option")
pgroup.add_argument("--version", action="store_true", help="print version of cart")
pgroup.add_argument("--bbs", action="store_true", help="interpret input as a bbs cart id, e.g. '#...' and download it from the bbs")
pgroup.add_argument("--url", action="store_true", help="interpret input as a URL, and download it from the internet")
pgroup.add_argument("--custom-preprocessor", action="store_true", help="enable a custom preprocessor (#define X 123, #ifdef X, #[X], #[X[[print('X enabled')]]])")

def default_output_format(output):
    ext = path_extension(output)[1:].lower()
    if ext in CartFormat._ext_names:
        return CartFormat(ext)
    else:
        return CartFormat.p8

def main_inner(raw_args):
    if not raw_args: # help is better than usage
        parser.print_help(sys.stderr)
        return 1

    args = parser.parse_args(raw_args)

    if args.input == "-":
        args.input = StdPath("-")
    if args.output == "-":
        args.output = StdPath("-")

    if args.url:
        args.input = URLPath(args.input)
    elif args.bbs:
        args.input = URLPath(get_bbs_cart_url(args.input))
        args.input_format = CartFormat.png

    if not args.lint and not args.count and not args.output and not args.input_count and not args.version and not args.list:
        throw("No operation (--lint/--count) or output file specified")
    if args.format and not args.output:
        throw("Output should be specified under --format")
    if args.minify and not args.output and not args.count:
        throw("Output (or --count) should be specified under --minify")
    if args.minify and args.keep_compression:
        throw("Can't modify code and keep compression")
    if args.list and (args.output or args.lint or args.count):
        throw("--list can't be combined with most other options")
        
    if not args.format and args.output:
        args.format = default_output_format(args.output)

    if not args.input_format and args.input:
        ext = path_extension(args.input)[1:].lower()
        if ext in CartFormat._ext_names:
            args.input_format = CartFormat(ext)

    if args.lint:
        args.lint = {
            "unused": not args.no_lint_unused,
            "duplicate": not args.no_lint_duplicate,
            "undefined": not args.no_lint_undefined,
            "globals": args.lint_global,
        }

    if args.minify or args.minify_safe_only:
        args.minify = {
            "lines": not args.no_minify_lines,
            "wspace": not args.no_minify_spaces,
            "comments": not args.no_minify_comments,
            "tokens": not args.no_minify_tokens,
            "focus": "chars" if args.focus_chars else "compressed" if args.focus_compressed else "none",
        }

    args.rename = bool(args.minify) and not args.no_minify_rename
    if args.rename:
        if args.no_preserve:
            args.preserve = (args.preserve or []) + ["!%s" % item for item in args.no_preserve]
        if args.rename_members_as_globals:
            args.preserve = (args.preserve or []) + ["*=*.*"]
        args.rename = {
            "safe-only": args.minify_safe_only,
            "focus": args.minify.get("focus"),
            "rules": args.preserve,
        }

    if args.unminify:
        args.unminify = {
            "indent": args.unminify_indent
        }

    preproc_cb, postproc_cb, sublang_cb = None, None, None
    if args.script:
        script_spec = importlib.util.spec_from_file_location(path_basename_no_extension(args.script), args.script)
        script_mod = importlib.util.module_from_spec(script_spec)
        script_spec.loader.exec_module(script_mod)
        preproc_cb = getattr(script_mod, "preprocess_main", None)
        postproc_cb = getattr(script_mod, "postprocess_main", None)
        sublang_cb = getattr(script_mod, "sublanguage_main", None)

    base_count_handler = ParsableCountHandler if args.parsable_count else True
    if args.input_count:
        args.input_count = base_count_handler
    if args.count:
        args.count = base_count_handler

    if args.trace_input_compression:
        args.trace_input_compression = CompressionTracer(args.trace_input_compression)
    if args.trace_compression:
        args.trace_compression = CompressionTracer(args.trace_compression)

    try:
        if args.list:
            for entry in read_cart_package(args.input, args.input_format).list():
                print(entry)
            return 0

        preprocessor = CustomPreprocessor() if args.custom_preprocessor else None
        cart = read_cart(args.input, args.input_format, size_handler=args.input_count, 
                         debug_handler=args.trace_input_compression, cart_name=args.cart,
                         keep_compression=args.keep_compression, preprocessor=preprocessor)
        src = CartSource(cart)
    except OSError as e:
        throw("cannot read cart: %s" % e)

    if args.input_count:
        write_code_size(cart, handler=args.input_count, input=True)
        
    ctxt = PicoContext(extra_builtins=args.builtin, not_builtins=args.not_builtin, 
                       local_builtins=not args.global_builtins_only,
                       srcmap=args.rename_map, sublang_getter=sublang_cb, version=cart.version_id)
    if preproc_cb:
        preproc_cb(cart=cart, src=src, ctxt=ctxt, args=args)

    ok, errors = process_code(ctxt, src, input_count=args.input_count, count=args.count,
                              lint=args.lint, minify=args.minify, rename=args.rename,
                              unminify=args.unminify, stop_on_lint=not args.no_lint_fail,
                              fail=False, want_count=not args.no_count_tokenize)
    if errors:
        print("Lint warnings:" if ok else "Compilation errors:")
        for error in sorted(errors):
            print(error.format(args.error_format))
        if not ok or not args.no_lint_fail:
            return 2 if ok else 1

    if args.rename_map:
        file_write_text(args.rename_map, "\n".join(ctxt.srcmap))
        
    if postproc_cb:
        postproc_cb(cart=cart, args=args)

    if args.count:
        write_code_size(cart, handler=args.count)
        if not (args.output and str(args.format) not in CartFormat._src_names) and not args.no_count_compress: # else, will be done in write_cart
            write_compressed_size(cart, handler=args.count, best_compress=args.best_compression,fast_compress=args.fast_compression)

    if args.output:
        all_outputs = [(args.output, args.format)]
        if args.extra_output:
            for extra_output in args.extra_output:
                if len(extra_output) == 1:
                    all_outputs.append((extra_output[0], default_output_format(extra_output[0])))
                elif len(extra_output) == 2:
                    all_outputs.append((extra_output[0], CartFormat(extra_output[1])))
                else:
                    throw("too many arguments to --extra-output")
        
        for output, format in all_outputs:
            try:
                write_cart(output, cart, format, size_handler=args.count,
                        debug_handler=args.trace_compression,
                        unicode_caps=args.unicode_caps, old_compress=args.old_compression,
                        force_compress=args.count or args.force_compression,
                        best_compress=args.best_compression,fast_compress=args.fast_compression, keep_compression=args.keep_compression,
                        screenshot_path=args.label, title=args.title)
            except OSError as e:
                throw("cannot write cart: %s" % e)

    if args.version:
        print("version: %d, v%d.%d.%d:%d, %c" % (cart.version_id, *cart.version_tuple, cart.platform))

    if errors:
        return 2

def main(raw_args):
    try:
        return main_inner(raw_args)
    except CheckError as e:
        sys.stdout.flush()
        eprint("ERROR: " + str(e))
        return 1

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
