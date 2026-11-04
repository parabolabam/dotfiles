#!/usr/bin/env python3
"""Herdr agent picker: `--side` = live sidebar pane, default = popup card grid. Python 3 stdlib only."""
import argparse, json, os, re, select, signal, subprocess, sys, termios, time, tty, zlib

from sprites import PALETTES, POOL, SPRITES

NAVY, ROWBG, CARD, CARD_B, WIN = (22, 22, 30), (36, 36, 52), (42, 27, 61), (75, 46, 107), (26, 16, 40)
WHITE, DIM, ORANGE, INK = (240, 240, 248), (112, 112, 142), (248, 184, 0), (16, 16, 24)
WS_COLORS = [(248, 154, 60), (248, 216, 56), (56, 216, 200), (248, 120, 184), (120, 160, 248)]
STATES = {  # colour, badge text, state-box glyph
    "blocked": ((248, 56, 0), "HELP!", "!"),
    "done": ((88, 216, 84), "DONE", "✦"),
    "working": ((248, 216, 56), "WORKING", "»"),
    "idle": ((108, 140, 248), "IDLE", "z"),
    "unknown": ((124, 124, 140), "???", "?"),
}
ORDER = list(STATES)
CW, CH, GX = 34, 10, 1  # card size (popup), gap
FLOOR = ((107, 58, 42), (74, 42, 34))


def rgb(h): return tuple(int(h[i:i + 2], 16) for i in (1, 3, 5))
def cut(t, n): return t if len(t) <= n else t[:max(0, n - 1)] + "…" if n > 0 else ""


class Canvas:
    def __init__(s, w, h): s.w, s.h, s.c = w, h, [[(" ", WHITE, NAVY, 0)] * w for _ in range(h)]

    def put(s, x, y, text, fg=WHITE, bg=None, b=0):
        for i, ch in enumerate(text):
            if 0 <= y < s.h and 0 <= x + i < s.w:
                s.c[y][x + i] = (ch, fg, bg or s.c[y][x + i][2], b)

    def rect(s, x, y, w, h, bg):
        for j in range(h):
            s.put(x, y + j, " " * w, WHITE, bg)

    def lines(s):
        out = []
        for row in s.c:
            o, last = "", None
            for ch, f, g, b in row:
                if (f, g, b) != last:
                    o += "\x1b[0;%s38;2;%d;%d;%d;48;2;%d;%d;%dm" % ("1;" if b else "", *f, *g)
                    last = (f, g, b)
                o += ch
            out.append(o + "\x1b[0m")
        return out


def sprite(cv, x, y, a, tick):
    """16x8-cell window: stars, brick floor, character, state box."""
    name, col, glyph = a["sprite"], STATES[a["state"]][0], STATES[a["state"]][2]
    pal = {k: rgb(v) for k, v in PALETTES[name].items()}
    px = [[WIN] * 16 for _ in range(16)]
    h = zlib.crc32(a["pane"].encode())
    for i, (sx, sy) in enumerate(((1 + h % 5, 1 + h // 7 % 3), (9 + h // 3 % 4, 5 + h // 11 % 4))):
        px[sy][sx] = (252, 252, 252) if (tick + i) % 2 else (156, 140, 200)
    for fx in range(16): px[15][fx] = FLOOR[fx // 2 % 2]
    for yy, row in enumerate(SPRITES[name][tick % 2]):
        for xx, c in enumerate(row):
            if c != ".": px[yy][xx] = pal[c]
    for r in range(8):
        for c in range(16):
            cv.c[y + r][x + c] = ("▀", px[2 * r][c], px[2 * r + 1][c], 0)
    on = not (a["state"] == "blocked" and tick % 2)
    cv.put(x + 15, y, glyph, INK, col if on else CARD_B, 1)


def card(cv, x, y, cw, a, sel, tick):
    col, badge, _ = STATES[a["state"]]
    bc = ORANGE if sel else CARD_B
    cv.rect(x, y, cw, CH, CARD)
    cv.put(x, y, "┌" + "─" * (cw - 2) + "┐", bc, CARD)
    cv.put(x, y + CH - 1, "└" + "─" * (cw - 2) + "┘", bc, CARD)
    for j in range(1, CH - 1):
        cv.put(x, y + j, "│", bc, CARD)
        cv.put(x + cw - 1, y + j, "│", bc, CARD)
    sprite(cv, x + 2, y + 1, a, tick)
    tx, tw = x + 19, cw - 20
    cv.put(tx, y + 1, "[%s]" % badge, col if not (a["state"] == "blocked" and tick % 2) else WHITE, CARD, 1)
    cv.put(tx, y + 3, cut(a["ws"], tw), WHITE, CARD, 1)
    t = a["title"]
    for j in range(3):  # wrap the title over 3 lines, last one truncated
        cv.put(tx, y + 4 + j, cut(t[:tw] if j < 2 else t, tw) if t else "", (176, 164, 200), CARD)
        t = t[tw:]


def window(n, sel, vis, view):
    top = view.get("top", 0)
    top = sel if sel < top else sel - vis + 1 if sel >= top + vis else top
    view["top"] = max(0, min(top, n - vis))
    return view["top"]


def render_side(ws, agents, sel, tick, W, H, view):
    cv, hits = Canvas(W, H), []
    cv.put(1, 0, "▒▒ SPACES", DIM)
    y = 1
    for i, w in enumerate(ws[:6]):
        c = WS_COLORS[i % len(WS_COLORS)]
        n = sum(a["ws_id"] == w["id"] for a in agents)
        bg = ROWBG if w["focused"] else NAVY
        cv.rect(0, y, W, 1, bg)
        if w["focused"]: cv.put(0, y, "▌", ORANGE, bg)
        label, cnt = cut(w["label"], W - 10), str(n)
        cv.put(2, y, "⌂", c, bg)
        cv.put(4, y, label, c, bg, 1)
        rx = 5 + len(label)
        if rx < W - 2 - len(cnt): cv.put(rx, y, "─" * (W - 2 - len(cnt) - rx), (60, 60, 82), bg)
        cv.put(W - 1 - len(cnt), y, cnt, DIM, bg)
        hits.append((y, y + 1, "ws", w["id"]))
        y += 1
    y += 1
    busy = "%d BUSY" % sum(a["state"] == "working" for a in agents)
    cv.put(1, y, "▒▒ AGENTS", DIM)
    cv.put(W - 1 - len(busy), y, busy, ORANGE)
    y += 1
    cw, vis = max(24, W - 2), max(1, (H - y - 1) // CH)
    if not agents:
        cv.put(2, y + 1, "no agents", DIM)
    top = window(len(agents), sel, vis, view)
    for k, a in enumerate(agents[top:top + vis]):
        card(cv, 1, y, cw, a, top + k == sel, tick)
        hits.append((y, y + CH, "agent", a["pane"]))
        y += CH
    cv.put(1, H - 1, "j/k move ⏎ jump", DIM)
    if agents:
        pos = "%d/%d" % (sel + 1, len(agents))
        cv.put(W - 1 - len(pos), H - 1, pos, DIM)
    return cv, hits


def render_popup(ws, agents, sel, tick, W, H, view):
    cv = Canvas(W, H)
    cv.put(1, 0, "▒▒ SELECT AGENT", WHITE, None, 1)
    r = "%d AGENTS" % len(agents)
    cv.put(W - 1 - len(r), 0, r, DIM)
    cv.put(0, 1, "━" * W, CARD_B)
    pr = max(1, (W + GX) // (CW + GX))
    vis = max(1, (H - 3) // CH)
    top = window(-(-len(agents) // pr), sel // pr, vis, view)
    lm = (W - (min(pr, max(1, len(agents))) * (CW + GX) - GX)) // 2
    for r in range(top, min(-(-len(agents) // pr), top + vis)):
        for i in range(r * pr, min(len(agents), r * pr + pr)):
            card(cv, lm + (i - r * pr) * (CW + GX), 2 + (r - top) * CH, CW, agents[i], i == sel, tick)
    if not agents:
        cv.put((W - 23) // 2, H // 2, "NO AGENTS - PRESS START", DIM)
    foot = "hjkl/arrows move  ⏎ jump  q quit"
    cv.put((W - len(foot)) // 2, H - 1, foot, DIM)
    return cv, []


def herdr(*a):
    try:
        return json.loads(subprocess.run(["herdr", *a], capture_output=True, text=True, timeout=3).stdout)["result"]
    except Exception:
        return {}


def fetch():
    ws = [dict(id=w.get("workspace_id"), label=w.get("label", ""), focused=bool(w.get("focused")))
          for w in herdr("workspace", "list").get("workspaces", [])]
    names = {w["id"]: w["label"] for w in ws}
    out = [dict(agent=a.get("agent", ""),
                state=a.get("agent_status") if a.get("agent_status") in STATES else "unknown",
                pane=a.get("pane_id", ""), ws_id=a.get("workspace_id"), focused=bool(a.get("focused")),
                ws=names.get(a.get("workspace_id")) or os.path.basename(a.get("cwd", "").rstrip("/")),
                title=a.get("terminal_title_stripped") or "")
           for a in herdr("agent", "list").get("agents", [])]
    for a in out: a["sprite"] = POOL[zlib.crc32(a["pane"].encode()) % len(POOL)]  # stable per agent instance
    order = {w["id"]: i for i, w in enumerate(ws)}
    return ws, sorted(out, key=lambda a: (order.get(a["ws_id"], 99), a["pane"]))


def demo():
    ws = [dict(id="d%d" % i, label=l, focused=i == 1) for i, l in enumerate(["greetings", "Negative detection", "CNR"])]
    titles = ["negative-detection", "refactor the executor pipeline and add tests", "waiting for approval", "done: fixed flaky test"]
    ag = [dict(agent="claude", state=ORDER[i % 5], pane="demo:p%d" % i, ws_id=ws[i % 3]["id"], focused=i == 1,
               ws=ws[i % 3]["label"], title=titles[i % 4], sprite=POOL[i % len(POOL)]) for i in range(16)]
    return ws, ag


def spawn(*cmd):
    subprocess.Popen(cmd, start_new_session=True, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def run(get, side, live):
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    w = sys.stdout.write

    def data():
        ws, ag = get()
        return ws, ag if side else sorted(ag, key=lambda a: (ORDER.index(a["state"]), a["ws"].lower()))

    def focused(ag):
        return next((i for i, a in enumerate(ag) if a["focused"]), None)

    try:
        tty.setraw(fd)
        w("\x1b[?1049h\x1b[?25l" + ("\x1b[?1000h\x1b[?1006h" if side else "") + "\x1b[2J")
        (ws, agents), t_fetch, view, last, size, hits, moved = data(), time.time(), {}, None, None, [], 0
        sel = focused(agents) or 0
        while True:
            now = time.time()
            if now - t_fetch > 1:
                cur = agents[sel]["pane"] if agents else None
                (ws, agents), t_fetch = data(), now
                idx = [i for i, a in enumerate(agents) if a["pane"] == cur]
                sel = idx[0] if idx else min(sel, max(0, len(agents) - 1))
                if side and now - moved > 5 and focused(agents) is not None:
                    sel = focused(agents)
            sz = tuple(os.get_terminal_size())
            if sz != size:
                size, last = sz, None
                w("\x1b[2J")
            cv, hits = (render_side if side else render_popup)(ws, agents, sel, int(now / .5) % 2, sz[0], sz[1], view)
            out = "\x1b[H" + "\r\n".join(cv.lines())
            if out != last:
                w(out)
                sys.stdout.flush()
                last = out
            if not select.select([fd], [], [], .1)[0]:
                continue
            pr = 1 if side else max(1, (sz[0] + GX) // (CW + GX))
            for k in re.findall(rb"\x1b\[<\d+;\d+;\d+[Mm]|\x1b\[[A-D]|\x1bO[A-D]|.", os.read(fd, 256), re.S):
                if k in (b"q", b"\x1b", b"\x03"):
                    return
                m = re.match(rb"\x1b\[<(\d+);\d+;(\d+)([Mm])", k)
                if m:
                    b, y = int(m[1]), int(m[2]) - 1
                    if b in (64, 65) and agents:  # wheel
                        sel, moved = max(0, min(len(agents) - 1, sel + (-1 if b == 64 else 1))), now
                    elif b == 0 and m[3] == b"M" and live:
                        for y0, y1, kind, ident in hits:
                            if y0 <= y < y1:
                                if kind == "ws":
                                    spawn("herdr", "workspace", "focus", ident)
                                else:
                                    spawn("herdr", "agent", "focus", ident)
                                    sel, moved = next(i for i, a in enumerate(agents) if a["pane"] == ident), now
                    continue
                if k in (b"\r", b"\n"):
                    if agents and live:
                        if side: spawn("herdr", "agent", "focus", agents[sel]["pane"])
                        else: spawn("sh", "-c", 'sleep 0.15; herdr agent focus "$1"', "sh", agents[sel]["pane"])
                    if not side:
                        return
                    continue
                d = {b"h": -1, b"\x1b[D": -1, b"\x1bOD": -1, b"l": 1, b"\x1b[C": 1, b"\x1bOC": 1,
                     b"k": -pr, b"\x1b[A": -pr, b"\x1bOA": -pr, b"j": pr, b"\x1b[B": pr, b"\x1bOB": pr}.get(k, 0)
                if d:
                    sel, moved = (max(0, min(len(agents) - 1, sel + d)) if agents else 0), now
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
        w("\x1b[0m\x1b[?1000l\x1b[?1006l\x1b[?25h\x1b[?1049l")
        sys.stdout.flush()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--side", action="store_true")
    ap.add_argument("--demo", action="store_true")
    ap.add_argument("--frame", action="store_true")
    ap.add_argument("--cols", type=int, default=120)
    ap.add_argument("--rows", type=int, default=40)
    ap.add_argument("--sel", type=int, default=0)
    a = ap.parse_args()
    get = demo if a.demo else fetch
    if a.frame:
        ws, ag = get()
        if not a.side: ag = sorted(ag, key=lambda x: (ORDER.index(x["state"]), x["ws"].lower()))
        cv, _ = (render_side if a.side else render_popup)(ws, ag, min(a.sel, max(0, len(ag) - 1)), 0, a.cols, a.rows, {})
        print("\n".join(cv.lines()))
    else:
        run(get, a.side, not a.demo)


if __name__ == "__main__":
    main()
