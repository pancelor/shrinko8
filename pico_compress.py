from utils import *
from pico_defs import *

def print_size(name, size, limit, prefix=None, handler=None):
    if handler and handler != True:
        handler(prefix, name, size, limit)
    else:
        percent = size / limit * 100
        fmt = "%.2f%%" if percent >= 95 else "%.0f%%"
        if prefix:
            name = "%s %s" % (prefix, name)
        name += ":"
        print(name, size, fmt % percent)

def print_code_size(size, **kwargs):
    print_size("chars", size, 0xffff, **kwargs)

def print_compressed_size(size, **kwargs):
    print_size("compressed", size, k_code_size, **kwargs)

def write_code_size(cart, handler=None, input=False):
    print_code_size(len(cart.code), prefix="input" if input else None, handler=handler)

def write_compressed_size(cart, handler=True, **opts):
    compress_code(BinaryWriter(BytesIO()), cart.code, size_handler=handler, force_compress=True, fail_on_error=False, **opts)

k_old_code_table = [
    None, '\n', ' ', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', # 00
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', # 0d
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', # 1a
    '!', '#', '%', '(', ')', '{', '}', '[', ']', '<', '>', # 27
    '+', '=', '/', '*', ':', ';', '.', ',', '~', '_' # 32
]

k_old_inv_code_table = {ch: i for i, ch in enumerate(k_old_code_table)}

k_old_compressed_code_header = b":c:\0"
k_new_compressed_code_header = b"\0pxa"

def update_mtf(mtf, idx, ch):
    for ii in range(idx, 0, -1):
        mtf[ii] = mtf[ii - 1]
    mtf[0] = ch

def uncompress_code(r, size_handler=None, debug_handler=None, **_):
    start_pos = r.pos()
    header = r.bytes(4, allow_eof=True)

    if header == k_new_compressed_code_header:
        unc_size = r.u16()
        com_size = r.u16()

        if size_handler:
            print_compressed_size(com_size, prefix="input", handler=size_handler)
        
        mtf = [chr(i) for i in range(0x100)]
        br = BinaryBitReader(r.f)
        if debug_handler: debug_handler.init(br)
        
        code = []
        while len(code) < unc_size:
            if br.bit():
                extra = 0
                while br.bit():
                    extra += 1
                idx = br.bits(4 + extra) + make_mask(4, extra)
                
                if debug_handler: debug_handler.update(mtf[idx])                    
                code.append(mtf[idx])
                
                update_mtf(mtf, idx, code[-1])
            else:
                offlen = (5 if br.bit() else 10) if br.bit() else 15                
                offset = br.bits(offlen) + 1

                if offset == 1 and offlen != 5:
                    assert offlen == 10
                    startlen = len(code)
                    while True:
                        ch = br.bits(8)
                        if ch != 0:
                            code.append(chr(ch))
                        else:
                            break
                        
                    if debug_handler: debug_handler.update(code[startlen:])
                else:
                    count = 3
                    while True:
                        part = br.bits(3)
                        count += part
                        if part != 7:
                            break
                    
                    if debug_handler: debug_handler.update((offset, count))
                    for _ in range(count):
                        code.append(code[-offset])
        
        if debug_handler: debug_handler.end()
        assert r.pos() == start_pos + com_size
        assert len(code) == unc_size

    elif header == k_old_compressed_code_header:
        unc_size = r.u16()
        assert r.u16() == 0 # ?
        if debug_handler: debug_handler.init(r)

        code = []
        while True:
            ch = r.u8()
            if ch == 0x00:
                ch2 = r.u8()
                if ch2 == 0x00:
                    break
                code.append(chr(ch2))
                if debug_handler: debug_handler.update(code[-1])

            elif ch <= 0x3b:
                code.append(k_old_code_table[ch])
                if debug_handler: debug_handler.update(code[-1])

            else:
                ch2 = r.u8()
                count = (ch2 >> 4) + 2
                offset = ((ch - 0x3c) << 4) + (ch2 & 0xf)
                assert count <= offset
                if debug_handler: debug_handler.update((offset, count))                
                for _ in range(count):
                    code.append(code[-offset])

        if size_handler:
            print_compressed_size(r.pos() - start_pos, prefix="input", handler=size_handler)

        if debug_handler: debug_handler.end()
        assert len(code) in (unc_size, unc_size - 1) # extra null at the end dropped?

    else:
        r.addpos(-len(header))
        code = [chr(c) for c in r.zbytes(k_code_size, allow_eof=True)]

    return "".join(code)

def get_compressed_size(r):
    start_pos = r.pos()
    header = r.bytes(4, allow_eof=True)

    if header == k_new_compressed_code_header:
        r.u16()
        return r.u16() # compressed size

    elif header == k_old_compressed_code_header:
        r.u16()
        r.u16()
        
        while True:
            ch = r.u8()
            if ch == 0:
                if r.u8() == 0:
                    break
            elif ch > 0x3b:
                r.u8()

        return r.pos() - start_pos

    else:
        r.addpos(-len(header))
        return len(r.zbytes(k_code_size))

class Lz77Tuple(Tuple):
    fields = ("off", "cnt") # the subtracted values, not the real values

class Lz77Advance(Tuple):
    fields = ("i", "cost", "ctxt", "item", "prev")

def get_lz77(code, min_c=3, max_c=0x7fff, max_o=0x7fff, measure=None, max_o_steps=None, fast_c=None, no_repeat=False, litblock_idxs=None):
    min_matches = defaultdict(list)
    next_litblock = litblock_idxs.popleft() if litblock_idxs else len(code)

    def get_match_length(left, left_i, right, right_i, min_c):
        c = min_c
        limit = min(len(left) - left_i, len(right) - right_i)
        while c < limit and left[left_i + c] == right[right_i + c]:
            c += 1
        return c

    def find_match(i, max_o=max_o):
        best_c, best_j = -1, -1
        best_slice = ""
        for j in reversed(min_matches[code[i:i+min_c]]):
            if best_slice == code[j:j+best_c]: # some speed-up, esp. for cpython
                c = get_match_length(code, i, code, j, best_c if best_c >= 0 else min_c)
            else:
                continue
                
            if max_c != None:
                c = min(c, max_c)
            if no_repeat:
                c = min(c, i - j)

            if max_o != None and j < i - max_o:
                break

            if c > best_c and c >= min_c or c == best_c and j > best_j:
                best_c, best_j = c, j
                best_slice = code[i:i+best_c]
        
        return best_c, best_j

    def mktuple(i, j, count):
        return Lz77Tuple(i - j - 1, count - min_c)

    i = 0
    prev_i = 0
    advances = deque() if measure else None
    curr_adv = None

    def add_advance(cost, ctxt, c, item):
        next_i = i + c
        adv_idx = 0
        insert_idx = None
        do_replace = False
        for adv in advances:
            if insert_idx is None:
                if next_i == adv.i:
                    insert_idx, do_replace = adv_idx, True
                elif next_i < adv.i:
                    insert_idx = adv_idx

            if insert_idx != None and cost >= adv.cost:
                return
            adv_idx += 1
        
        next_adv = Lz77Advance(next_i, cost, ctxt, item, curr_adv)
        if do_replace:
            advances[insert_idx] = next_adv
        elif insert_idx != None:
            advances.insert(insert_idx, next_adv)
        else:
            advances.append(next_adv)
    
    def get_advance_items(adv):
        while adv:
            yield adv.i, adv.item
            adv = adv.prev

    while i < len(code):
        if i >= next_litblock:
            if curr_adv: # get rid of any advances
                yield from reversed(tuple(get_advance_items(curr_adv)))
                curr_adv = None
                advances.clear()

            best_c = sys.maxsize
            end_litblock = litblock_idxs.popleft() if litblock_idxs else len(code)

            yield i, code[i:end_litblock]
            i = end_litblock

            next_litblock = litblock_idxs.popleft() if litblock_idxs else len(code)

        else:
            if measure:
                curr_ctxt = curr_adv.ctxt if curr_adv else None
                curr_cost = curr_adv.cost if curr_adv else 0

                # try using a literal
                ch_cost, ch_ctxt = measure(curr_ctxt, code[i])
                add_advance(curr_cost + ch_cost, ch_ctxt, 1, code[i])

                # try using a match
                best_c, best_j = find_match(i)
                if best_c >= 0:
                    lz_item = mktuple(i, best_j, best_c)
                    lz_cost, lz_ctxt = measure(curr_ctxt, lz_item)
                    add_advance(curr_cost + lz_cost, lz_ctxt, best_c, lz_item)

                if max_o_steps:
                    # try a shorter yet closer match
                    for step in max_o_steps:
                        if i - best_j <= step:
                            break

                        sh_best_c, sh_best_j = find_match(i, max_o=step)
                        if sh_best_c >= 0:
                            sh_item = mktuple(i, sh_best_j, sh_best_c)
                            sh_cost, sh_ctxt = measure(curr_ctxt, sh_item)
                            add_advance(curr_cost + sh_cost, sh_ctxt, sh_best_c, sh_item)
                
                curr_adv = advances.popleft()
                i = curr_adv.i
                
                if not advances:
                    # have a best choice, flush it
                    yield from reversed(tuple(get_advance_items(curr_adv)))
                    curr_adv = None

            else:
                best_c, best_j = find_match(i)
                if best_c >= 0:
                    yield i, mktuple(i, best_j, best_c)
                    i += best_c
                else:
                    yield i, code[i]
                    i += 1
            
        if not (fast_c != None and best_c >= fast_c):
            for j in range(prev_i, i):
                min_matches[code[j:j+min_c]].append(j)
        prev_i = i
    
    assert not curr_adv

from bisect import bisect
from operator import itemgetter
from collections import namedtuple

Entry=namedtuple('Entry',['chunks','clen','mtf'])

def compress2(w,code,size_handler=None,fail_on_error=True):
    def CHR(ch,mtf):
        """ note: updated mtf """
        idx=mtf.index(ch)
        update_mtf(mtf,idx,ch)
        cost=6+2*bisect([16,48,112,240],idx)
        return ('CHR',ch),cost

    def REF(offset,length):
        cost_offset=8+5*bisect([33,1025],offset)
        cost_length=((length+4)//7)*3
        return ('REF',offset,length),cost_offset+cost_length

    def RAW(start,length):
        cost=13 # header
        cost+=length*8
        cost+=1 # footer
        return ('RAW',start,length),cost

    def clone_prefix_best(idx):
        assert(0<=idx and idx<=len(code))
        chunks = dptab[idx].chunks[:]
        clen = dptab[idx].clen
        mtf = dptab[idx].mtf[:]
        return chunks,clen,mtf

    def compress_prefix_options(idx):
        if idx==0:
            HEADER_LEN_BITS=64
            chunks,clen,mtf = [],HEADER_LEN_BITS,[chr(i) for i in range(0x100)]
            yield Entry(chunks,clen,mtf)
            return

        # try CHR chunk
        chunks,clen,mtf=clone_prefix_best(idx-1)
        chunk,cost = CHR(code[idx-1],mtf)
        chunks.append(chunk)
        clen+=cost

        yield Entry(chunks,clen,mtf)

        # try REF chunks
        # for each reflen (3,4,...) try first closest backref
        reflen=3
        for jdx in reversed(range(0,idx-3)):
            if code[jdx:jdx+reflen]==code[idx-reflen:idx]: # slice at jdx equal to the last chars
                chunks,clen,mtf=clone_prefix_best(idx-reflen)

                chunk,cost = REF(idx-reflen-jdx,reflen)
                chunks.append(chunk)
                clen+=cost

                yield Entry(chunks,clen,mtf)

                reflen+=1

        # try RAW chunks. todo: ignore obviously bad options (e.g. we ignore 1-char RAW chunks but maybe 2 or 3 as well)
        for jdx in reversed(range(0,idx)):
            chunks,clen,mtf=clone_prefix_best(jdx)

            chunk,cost = RAW(jdx,idx-jdx)
            chunks.append(chunk)
            clen+=cost

            yield Entry(chunks,clen,mtf)

    def best_prefix_option(idx):
        opts=list(compress_prefix_options(idx))
        print("options",idx,code[:idx])
        for o in opts:
            print('  ',o.clen,o.chunks )# ,o.mtf[:8],'...')
        return min(opts,key=lambda o: o.clen) #itemgetter('clen'))

    # find best compression
    dptab = [] # i => (chunks,clen,mtf) mapping
    for idx in range(len(code)+1):
        # compress code[:idx], store in dptab[idx]
        dptab.append(best_prefix_option(idx))
        print('best',idx,dptab[idx].clen,dptab[idx].chunks,'\n')
    
    # write
    bw = BinaryBitWriter(w.f)
    mtf = [chr(i) for i in range(0x100)]
    def write_match(offset_val, count_val):
        bw.bit(0)
        
        offset_bits = max(round_up(count_significant_bits(offset_val), 5), 5)
        assert offset_bits in (5, 10, 15)
        bw.bit(offset_bits < 15)
        if offset_bits < 15:
            bw.bit(offset_bits < 10)
        bw.bits(offset_bits, offset_val)
        
        while count_val >= 7:
            bw.bits(3, 7)
            count_val -= 7
        bw.bits(3, count_val)
        print('write_match\t',bw.bit_position-start_pos_bw,offset_val,count_val)

    def write_literal(ch):
        bw.bit(1)
        ch_i = mtf.index(ch)
        
        i_val = ch_i 
        i_bits = 4
        while i_val >= (1 << i_bits):
            bw.bit(1)
            i_val -= 1 << i_bits
            i_bits += 1
            
        bw.bit(0)
        bw.bits(i_bits, i_val)
                        
        update_mtf(mtf, ch_i, ch)
        print('write_literal\t',bw.bit_position-start_pos_bw,ch,ord(ch))

    def write_litblock(str):
        bw.bit(0); bw.bit(1); bw.bit(0)
        bw.bits(10, 0)

        for ch in str:
            bw.bits(8, ord(ch))
        bw.bits(8, 0)
        print('write_litblock\t',bw.bit_position-start_pos_bw,str)

    start_pos = w.pos()
    w.bytes(k_new_compressed_code_header)
    w.u16(len(code) & 0xffff) # only throw under fail_on_error below
    len_pos = w.pos()
    w.u16(0) # revised below
    start_pos_bw = bw.bit_position

    for chunk in dptab[-1].chunks:
        if chunk[0]=='REF':
            offset,length=chunk[1],chunk[2]
            write_match(offset-1,length-3)
        elif chunk[0]=='CHR':
            ch=chunk[1]
            write_literal(ch)
        elif chunk[0]=='RAW':
            start,length=chunk[1],chunk[2]
            write_litblock(code[start:start+length])
    bw.flush()

    size = w.pos() - start_pos
    if size_handler:
        print_compressed_size(size, handler=size_handler)
    
    if fail_on_error:
        check(len(code) < 0x10000, "cart has too many characters!")
        check(size <= k_code_size, "cart takes too much compressed space!")
    
    w.setpos(len_pos)
    w.u16(size & 0xffff) # only throw under fail_on_error above

def compress_code(w, code, size_handler=None, debug_handler=None, force_compress=False, 
                  fail_on_error=True, best_compress=False, fast_compress=False, old_compress=False, **_):
    is_new = not old_compress
    min_c = 3

    print('code',len(code),code)
    if best_compress:
        assert(is_new)
        return compress2(w,code,fail_on_error=fail_on_error,size_handler=size_handler)
    
    if len(code) >= k_code_size or force_compress: # (>= due to null)
        start_pos = w.pos()
        w.bytes(k_new_compressed_code_header if is_new else k_old_compressed_code_header)
        w.u16(len(code) & 0xffff) # only throw under fail_on_error below
        len_pos = w.pos()
        w.u16(0) # revised below
                
        if is_new:
            bw = BinaryBitWriter(w.f)
            start_pos_bw = bw.bit_position
            if debug_handler: debug_handler.init(bw)
            mtf = [chr(i) for i in range(0x100)]

            def mtf_cost_heuristic(ch_i):
                mask = 1 << 4
                count = 6
                while ch_i >= mask:
                    mask = (mask << 1) | (1 << 4)
                    count += 2
                if ch_i >= 16:
                    count -= 1 # heuristic, since mtf generally pays forward
                return count

            def measure(ctxt_mtf, item):
                if isinstance(item, Lz77Tuple):
                    offset_bits = max(round_up(count_significant_bits(item.off), 5), 5)
                    count_bits = ((item.cnt // 7) + 1) * 3
                    cost = 2 + (offset_bits < 15) + offset_bits + count_bits

                else:
                    ctxt_mtf = ctxt_mtf or mtf                        
                    ch_i = ctxt_mtf.index(item)
                    cost = mtf_cost_heuristic(ch_i)

                    ctxt_mtf = ctxt_mtf[:] # a bit wasteful, but doesn't impact perf in practice
                    update_mtf(ctxt_mtf, ch_i, item)

                return cost, ctxt_mtf

            # heuristicly find at which indices we should enter/leave literal blocks
            def preprocess_litblock_idxs():
                premtf = [chr(i) for i in range(0x100)]
                pre_min_c = 4 # ignore questionable lz77s
                last_cost_len = 0x20
                last_cost_mask = last_cost_len - 1
                last_costs = [0 for i in range(last_cost_len)]
                sum_costs = 0
                litblock_idxs = deque()

                in_litblock = False
                def add_last_cost(i, cost):
                    nonlocal sum_costs, in_litblock

                    cost_i = i & last_cost_mask
                    sum_costs -= last_costs[cost_i]
                    last_costs[cost_i] = cost
                    sum_costs += cost

                    if i >= last_cost_len and (not in_litblock and sum_costs > 19) or (in_litblock and sum_costs < 0):
                        in_litblock = not in_litblock

                        ordered_costs = last_costs[cost_i + 1:] + last_costs[:cost_i + 1]
                        best_func = max if in_litblock else min
                        best_j = best_func(range(last_cost_len), key=lambda j: sum(ordered_costs[-j-1:]))

                        litblock_idxs.append(i - best_j)

                for i, item in get_lz77(code, min_c=pre_min_c, fast_c=0):
                    if isinstance(item, Lz77Tuple):
                        count = item.cnt + pre_min_c
                        cost = (20 - count * 8) // count
                        for j in range(count):
                            add_last_cost(i + j, cost)
                    else:
                        ch_i = premtf.index(item)
                        update_mtf(premtf, ch_i, item)
                        cost = mtf_cost_heuristic(ch_i)
                        add_last_cost(i, cost - 8)                        

                for i in range(last_cost_len): # flush litblock
                    add_last_cost(len(code) + i, 0)

                return litblock_idxs
                    
            def write_match(offset_val, count_val):
                bw.bit(0)
                
                offset_bits = max(round_up(count_significant_bits(offset_val), 5), 5)
                assert offset_bits in (5, 10, 15)
                bw.bit(offset_bits < 15)
                if offset_bits < 15:
                    bw.bit(offset_bits < 10)
                bw.bits(offset_bits, offset_val)
                
                while count_val >= 7:
                    bw.bits(3, 7)
                    count_val -= 7
                bw.bits(3, count_val)
                print('write_match\t',bw.bit_position-start_pos_bw,offset_val,count_val)

            def write_literal(ch):
                bw.bit(1)
                ch_i = mtf.index(ch)
                
                i_val = ch_i 
                i_bits = 4
                while i_val >= (1 << i_bits):
                    bw.bit(1)
                    i_val -= 1 << i_bits
                    i_bits += 1
                    
                bw.bit(0)
                bw.bits(i_bits, i_val)
                                
                update_mtf(mtf, ch_i, ch)
                print('write_literal\t',bw.bit_position-start_pos_bw,ch,ord(ch))

            def write_litblock(str):
                bw.bit(0); bw.bit(1); bw.bit(0)
                bw.bits(10, 0)

                for ch in str:
                    bw.bits(8, ord(ch))
                bw.bits(8, 0)
                print('write_litblock\t',bw.bit_position-start_pos_bw,str)

            if fast_compress:
                items = get_lz77(code, min_c=min_c, max_c=None, fast_c=16)
            else:
                items = get_lz77(code, min_c=min_c, max_c=None, measure=measure,
                                 max_o_steps=(0x20, 0x400), litblock_idxs=preprocess_litblock_idxs())

            for i, item in items:
                if isinstance(item, Lz77Tuple):
                    write_match(item.off, item.cnt)
                    if debug_handler: debug_handler.update((item.off + 1, item.cnt + min_c))
                elif len(item) == 1:
                    write_literal(item)
                    if debug_handler: debug_handler.update(item)
                else:
                    write_litblock(item)
                    if debug_handler: debug_handler.update(item)
                    
            if debug_handler: debug_handler.end()
            bw.flush()

        else:
            if debug_handler: debug_handler.init(w)

            def measure(ctxt, item):
                if isinstance(item, Lz77Tuple):
                    return 2, ctxt
                elif item in k_old_inv_code_table:
                    return 1, ctxt
                else:
                    return 2, ctxt

            def write_match(offset_val, count_val):
                offset_val += 1
                count_val += 1
                w.u8(0x3c + (offset_val >> 4))
                w.u8((offset_val & 0xf) + (count_val << 4))

            def write_literal(ch):
                ch_i = k_old_inv_code_table.get(ch, 0)
                
                if ch_i > 0:
                    w.u8(ch_i)
                
                else:
                    w.u8(0)
                    w.u8(ord(ch))

            for i, item in get_lz77(code, min_c=min_c, max_c=0x11, max_o=0xc3f, no_repeat=True,
                                    measure=None if fast_compress else measure):
                if isinstance(item, Lz77Tuple):
                    write_match(item.off, item.cnt)
                    if debug_handler: debug_handler.update((item.off + 1, item.cnt + min_c))
                else:
                    write_literal(item)
                    if debug_handler: debug_handler.update(item)
                    
            if debug_handler: debug_handler.end()

        size = w.pos() - start_pos
        if size_handler:
            print_compressed_size(size, handler=size_handler)
        
        if fail_on_error:
            check(len(code) < 0x10000, "cart has too many characters!")
            check(size <= k_code_size, "cart takes too much compressed space!")
        
        if is_new:   
            w.setpos(len_pos)
            w.u16(size & 0xffff) # only throw under fail_on_error above
            
    else:
        w.bytes(encode_p8str(code))

class CompressionTracer:
    """a debug_handler that traces compression to a file"""
    def __init__(m, path):
        m.file = file_create_text(path)

    def init(m, reader):
        m.reader = reader
        m.old_bitpos = m.curr_bitpos()
        m.code = []
    
    def curr_bitpos(m):
        if isinstance(m.reader, (BinaryBitReader, BinaryBitWriter)):
            return m.reader.bit_position
        elif isinstance(m.reader, (BinaryReader, BinaryWriter)):
            return m.reader.position * 8
        fail()

    def escape(m, str):
        return '"%s"' % str.replace('"', '""') # let \n/etc go unescaped, good for excel/etc

    def update(m, item):
        bitpos = m.curr_bitpos()
        bitsize = bitpos - m.old_bitpos

        if isinstance(item, tuple):
            offset, count = item
            for _ in range(count):
                m.code.append(m.code[-offset])
            str = "".join(m.code[-count:])
            m.file.write("%d,%s,%d:%d\n" % (bitsize, m.escape(str), offset, count))

        else:
            for ch in item:
                m.code.append(ch)
            m.file.write("%d,%s\n" % (bitsize, m.escape(item)))

        m.old_bitpos = bitpos

    def end(m):
        m.file.close()
