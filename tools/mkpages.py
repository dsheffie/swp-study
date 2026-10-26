#!/usr/bin/env python3
"""mkpages.py <repo root>: generate kernels/<k>.html for every TSVC kernel and the
all-kernels table in index.html (between the <!-- KERNELS --> markers).

Inputs: results/ipc_table.txt, results/hotloops.tsv (tools/trace_kernel.sh rows),
harness/src/loops.f, listings/*.s, harness/one_<k>_{swp,noswp}.elf (make one K=<k>),
and optional hand-written analysis in kernels/notes/<k>.html, whose
<!-- title: --> / <!-- lede: --> comments replace the generated ones."""
import html, os, re, subprocess, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rank

root = sys.argv[1]
esc = html.escape

def ipc_rows():
    rows = {}
    for l in open(root + '/results/ipc_table.txt'):
        p = l.split()
        if len(p) == 11 and p[4] == '|' and p[0] != 'kern':
            rows[p[0]] = dict(ins_n=int(p[1]), cyc_n=int(p[2]), ipc_n=float(p[3]),
                              ins_s=int(p[5]), cyc_s=int(p[6]), ipc_s=float(p[7]))
    return rows

def hot_loops():
    h = {}
    for l in open(root + '/results/hotloops.tsv'):
        p = l.split()
        if p[0] == 'kernel':
            continue
        k, v = p[0], p[1]
        if p[2] == 'none':
            h[(k, v)] = None
        else:
            h[(k, v)] = dict(head=int(p[2], 16), tail=int(p[3], 16), trips=int(p[4]),
                             start=int(p[5]), len=int(p[6]))
    return h

def fortran():
    """kernel -> (description lines, timed-region source lines), in loops.f order"""
    src = open(root + '/harness/src/loops.f').read().split('\n')
    out, i = {}, 0
    while i < len(src):
        m = re.match(r'^\s+subroutine\s+(\w+)', src[i], re.I)
        if not m:
            i += 1
            continue
        k = m.group(1).lower()
        i += 1
        desc = []
        while i < len(src) and re.match(r'^[cC]', src[i]):
            t = src[i][1:].strip()
            if t:
                desc.append(t)
            i += 1
        body, inside = [], False
        while i < len(src) and not re.match(r'^\s+end\s*$', src[i], re.I):
            if re.search(r't2\s*=\s*second\(\)', src[i], re.I):
                inside = False
            if inside:
                body.append(src[i].rstrip())
            if re.search(r't1\s*=\s*second\(\)', src[i], re.I):
                inside = True
            i += 1
        out[k] = (desc, body)
    return out

def mipspro_notes(listing):
    """kernel -> list of #<swps>/#<swpf> blocks from that kernel's function"""
    notes, cur, block = {}, None, []
    for l in open(listing, errors='replace'):
        m = re.match(r'^([a-z0-9]+)_:', l)
        if m:
            cur = m.group(1)
            notes.setdefault(cur, [])
        t = l.strip()
        if cur and (t.startswith('#<swps>') or t.startswith('#<swpf>')):
            block.append(t)
        elif block:
            body = [b for b in block if b not in ('#<swps>', '#<swpf>')]
            if body and body not in notes[cur]:
                notes[cur].append(body)
            block = []
    return notes

def cycles_per_iter(blocks):
    for b in blocks:
        for l in b:
            m = re.search(r'(\d+) cycles per (?:(\d+) )?iteration', l)
            if m:
                return int(m.group(1)) / int(m.group(2) or 1)
    return None

def loop_asm(k, v, loop):
    elf = '%s/harness/one_%s_%s.elf' % (root, k, v)
    dis = subprocess.run(['mips64-linux-gnuabi64-objdump', '-d', '--start-address=0x%x' % loop['head'],
                          '--stop-address=0x%x' % (loop['tail'] + 4), elf],
                         capture_output=True, text=True).stdout
    lines = []
    for l in dis.splitlines():
        m = re.match(r'^\s*([0-9a-f]+):\s+[0-9a-f]{8}\s+(\S+)\s*(.*)$', l)
        if m:
            lines.append(('%s  %s %s' % (m.group(1), m.group(2), m.group(3))).rstrip())
    return '\n'.join(lines)

def note(k):
    p = '%s/kernels/notes/%s.html' % (root, k)
    if not os.path.exists(p):
        return None
    s = open(p).read()
    title = re.search(r'<!-- title: (.*?) -->', s, re.S)
    lede = re.search(r'<!-- lede: (.*?) -->', s, re.S)
    body = re.sub(r'<!-- (title|lede): .*? -->\n?', '', s, flags=re.S)
    return dict(title=title.group(1) if title else None, lede=lede.group(1) if lede else None, body=body)

def verdict(r):
    x = r['cyc_n'] / r['cyc_s']
    if abs(x - 1) < 0.03:
        return 'SWP makes no measurable difference (within 3%).', ''
    if x > 1:
        return 'SWP is %.2f× faster.' % x, 'good'
    return 'SWP is %.2f× slower.' % (1 / x), 'bad'

def fmt_cpi(c):
    return '—' if c is None else ('%g' % round(c, 2))

PAGE = '''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{k}: MIPSpro SWP on r9999</title>
<meta name="description" content="TSVC {k} ({desc0}) compiled by MIPSpro 7.30 with and without software pipelining, run on the r9999 core.">
<link rel="stylesheet" href="../style.css">
</head>
<body>
<main class="wide">
<div class="crumb"><a href="../index.html">← MIPSpro SWP on r9999</a> · {nav}</div>
<h1>{title}</h1>
<p class="lede">{lede}</p>

<div class="tablewrap">
<table class="num">
  <tr><th></th><th class="r">no SWP</th><th class="r">SWP</th></tr>
  <tr><td>cycles (timed loop)</td><td class="r">{cyc_n:,}</td><td class="r {cls}">{cyc_s:,}</td></tr>
  <tr><td>instructions</td><td class="r">{ins_n:,}</td><td class="r">{ins_s:,}</td></tr>
  <tr><td>IPC</td><td class="r">{ipc_n:.3f}</td><td class="r {cls}">{ipc_s:.3f}</td></tr>
  <tr><td>mispredicts in the kernel</td><td class="r">{mn:,}</td><td class="r">{ms:,}</td></tr>
  <tr><td>branch-likely in the kernel (static)</td><td class="r">{ln}</td><td class="r">{ls}</td></tr>
  <tr><td>MIPSpro estimate, R4000 cycles per iteration</td><td class="r">—</td><td class="r">{cpi}</td></tr>
</table>
</div>

<h2>The kernel</h2>
<p>{descs}</p>
<pre>{src}</pre>
<h3>MIPSpro's software-pipelining notes</h3>
{notes}

<h2>The hot loop</h2>
<p>The most frequently taken backward branch in the kernel's own code, found from the retired-instruction trace.</p>
<div class="pair">
<div>
<h3>No SWP</h3>
{asm_n}
</div>
<div>
<h3>SWP</h3>
{asm_s}
</div>
</div>
{analysis}
<h2>Pipetraces</h2>
<p>Two trips of the hot loop from the middle of the run (F fetch, A allocate, C complete, R retire; grey = memory-pipe
events, with S also marking ALU issue). Scroll inside each frame.</p>
{trace_s}
{trace_n}
<footer><a href="../index.html">← all kernels</a> · {nav}</footer>
</main>
</body>
</html>
'''

def asm_block(k, v, loop):
    if loop is None:
        return '<p>No loop found in the kernel\'s own code.</p>'
    return '<p><code>%x</code>–<code>%x</code>, %d trips.</p>\n<pre>%s</pre>' % (
        loop['head'], loop['tail'], loop['trips'], esc(loop_asm(k, v, loop)))

def trace_block(k, v, loop, name):
    if loop is None:
        return '<p>%s: no loop found, so no pipetrace.</p>' % name
    return ('<div class="trace">\n  <div class="bar"><h3>%s</h3><span><a href="../pipetraces/%s_%s_focus.html">open</a> · '
            '<a href="../pipetraces/%s_%s.html">420-instruction window</a></span></div>\n'
            '  <iframe src="../pipetraces/%s_%s_focus.html" title="%s %s pipetrace" loading="lazy"></iframe>\n</div>'
            % (name, k, v, k, v, k, v, k, name))

def main():
    ipc = ipc_rows()
    hot = hot_loops()
    src = fortran()
    notes_s = mipspro_notes(root + '/listings/tsvc_f_r4000_swp.s')
    ls, ln, ms, mn = rank.counts(root)
    order = [k for k in src if k in ipc]
    rows = []
    for i, k in enumerate(order):
        r, f = ipc[k], k + '_'
        desc, body = src[k]
        blocks = notes_s.get(k, [])
        cpi = cycles_per_iter(blocks)
        lede, cls = verdict(r)
        n = note(k)
        nav = []
        if i > 0:
            nav.append('previous: <a href="%s.html">%s</a>' % (order[i - 1], order[i - 1]))
        if i + 1 < len(order):
            nav.append('next: <a href="%s.html">%s</a>' % (order[i + 1], order[i + 1]))
        if blocks:
            notes_html = '\n'.join('<pre>%s</pre>' % esc('\n'.join(b)) for b in blocks)
        else:
            notes_html = '<p>No <code>#&lt;swps&gt;</code>/<code>#&lt;swpf&gt;</code> notes in this kernel.</p>'
        page = PAGE.format(
            k=k, desc0=esc(desc[0] if desc else ''), nav=' · '.join(nav),
            title=n['title'] if n and n['title'] else k,
            lede=n['lede'] if n and n['lede'] else esc(lede),
            cls=cls, cpi=fmt_cpi(cpi), ms=ms[f], mn=mn[f], ls=ls[f], ln=ln[f],
            descs=esc(' / '.join(desc)) if desc else '', src=esc('\n'.join(body)),
            notes=notes_html,
            asm_n=asm_block(k, 'noswp', hot.get((k, 'noswp'))),
            asm_s=asm_block(k, 'swp', hot.get((k, 'swp'))),
            analysis='\n' + n['body'] if n else '',
            trace_s=trace_block(k, 'swp', hot.get((k, 'swp')), 'SWP'),
            trace_n=trace_block(k, 'noswp', hot.get((k, 'noswp')), 'No SWP'),
            **r)
        open('%s/kernels/%s.html' % (root, k), 'w').write(page)
        rows.append((k, desc[0] if desc else '', r, cpi, mn[f], ms[f], ls[f], n is not None))
    # all-kernels table for index.html
    t = ['<div class="tablewrap">', '<table class="num sortable" id="all">',
         '<thead><tr><th>kernel</th><th>category</th><th class="r">cycles SWP/noSWP</th><th class="r">insns SWP/noSWP</th>'
         '<th class="r">IPC no SWP</th><th class="r">IPC SWP</th><th class="r">mispredicts no SWP</th>'
         '<th class="r">mispredicts SWP</th><th class="r">branch-likely SWP</th><th class="r">MIPSpro cyc/iter</th></tr></thead><tbody>']
    for k, d, r, cpi, mnk, msk, lsk, has in rows:
        x = r['cyc_s'] / r['cyc_n']
        cls = 'good' if x < 0.97 else 'bad' if x > 1.03 else ''
        t.append('<tr><td data-v="%s"><a href="kernels/%s.html">%s</a>%s</td><td class="wrap">%s</td>'
                 '<td class="r %s" data-v="%.4f">%.2f</td><td class="r" data-v="%.4f">%.2f</td>'
                 '<td class="r">%.3f</td><td class="r">%.3f</td><td class="r">%d</td><td class="r">%d</td>'
                 '<td class="r">%d</td><td class="r" data-v="%s">%s</td></tr>'
                 % (k, k, k, ' ★' if has else '', esc(d), cls, x, x, r['ins_s'] / r['ins_n'], r['ins_s'] / r['ins_n'],
                    r['ipc_n'], r['ipc_s'], mnk, msk, lsk, '%.4f' % cpi if cpi is not None else '-1', fmt_cpi(cpi)))
    t += ['</tbody></table>', '</div>']
    idx = open(root + '/index.html').read()
    idx = re.sub(r'(<!-- KERNELS -->\n).*?(<!-- /KERNELS -->)', lambda m: m.group(1) + '\n'.join(t) + '\n' + m.group(2),
                 idx, flags=re.S)
    open(root + '/index.html', 'w').write(idx)
    print('%d kernel pages' % len(rows))

main()
