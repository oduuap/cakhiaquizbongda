"""
Ca Khia FC — App Icon Generator v4
Layout: Shield | "CA KHIA" in red top | Stars row | Ball on divider | "FC" + subtitle bottom
"""
from PIL import Image, ImageDraw, ImageFilter, ImageFont
import math, os

S = 512
cx, cy = S // 2, S // 2

# ── Palette ─────────────────────────────────────────────────────────────────
BG1   = (10, 8, 30)
BG2   = (25, 6, 45)
RED   = (210, 35, 50)
RED2  = (165, 18, 32)
GOLD  = (255, 200, 0)
GOLD2 = (210, 155, 0)
ORG   = (255, 120, 40)
WHITE = (255, 255, 255)
NAVY  = (18, 14, 48)
BLACK = (8, 8, 8)


# ── Helpers ──────────────────────────────────────────────────────────────────
def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(len(a)))


def load_font(path, size):
    try:
        return ImageFont.truetype(path, size)
    except Exception:
        try:
            return ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", size)
        except Exception:
            return ImageFont.load_default()


def text_centered(draw, text, cx, y, font, color, shadow=True):
    bb = draw.textbbox((0, 0), text, font=font)
    tw = bb[2] - bb[0]
    x  = cx - tw // 2
    if shadow:
        draw.text((x+2, y+2), text, font=font, fill=(0, 0, 0, 200))
    draw.text((x, y), text, font=font, fill=color)


def shield_pts(cx, cy, w, h):
    hw = w / 2
    t  = cy - h * 0.50
    m  = cy + h * 0.12
    b  = cy + h * 0.52
    return [
        (cx - hw,        t),
        (cx + hw,        t),
        (cx + hw,        m),
        (cx + hw * 0.55, b - h * 0.05),
        (cx,             b),
        (cx - hw * 0.55, b - h * 0.05),
        (cx - hw,        m),
    ]


# ── 1. Background ─────────────────────────────────────────────────────────────
def make_bg():
    img = Image.new("RGBA", (S, S), BG1 + (255,))
    d   = ImageDraw.Draw(img)
    for y in range(S):
        c = lerp(BG1, BG2, y / S)
        d.line([(0, y), (S, y)], fill=c + (255,))
    gl = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    gd = ImageDraw.Draw(gl)
    for r in range(200, 0, -4):
        a = int(14 * (1 - r / 200))
        gd.ellipse([cx-r, cy-r, cx+r, cy+r], fill=(80, 20, 130, a))
    return Image.alpha_composite(img, gl)


# ── 2. Shield ─────────────────────────────────────────────────────────────────
def draw_shield(img, sw=340, sh=370, offset_y=8):
    """Returns (img, top_y, stripe_y, bot_y)"""
    shield_cx = cx
    shield_cy = cy + offset_y
    pts = shield_pts(shield_cx, shield_cy, sw, sh)

    # Outer gold glow
    gl = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    gd = ImageDraw.Draw(gl)
    for e in range(16, 0, -1):
        ep = [(x + (x - shield_cx) * e / 50, y + (y - shield_cy) * e / 50)
              for x, y in pts]
        gd.polygon(ep, fill=GOLD + (int(45 * (1 - e / 16)),))
    gl = gl.filter(ImageFilter.GaussianBlur(6))
    img = Image.alpha_composite(img, gl)
    d   = ImageDraw.Draw(img)

    # Shield body (navy)
    d.polygon(pts, fill=NAVY + (255,))

    # Red top stripe (top 42%)
    stripe_frac = 0.42
    top_y    = shield_cy - sh * 0.50
    stripe_y = top_y + sh * stripe_frac
    bot_y    = shield_cy + sh * 0.52

    clip = Image.new("L", (S, S), 0)
    ImageDraw.Draw(clip).polygon(pts, fill=255)

    red_lay = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    rd      = ImageDraw.Draw(red_lay)
    for row in range(int(top_y), int(stripe_y) + 1):
        t = (row - top_y) / (sh * stripe_frac)
        c = lerp(RED, RED2, t)
        rd.line([(0, row), (S, row)], fill=c + (255,))
    red_lay.putalpha(clip)
    img = Image.alpha_composite(img, red_lay)

    d = ImageDraw.Draw(img)

    # Divider line
    inset = int(sw * 0.44)
    d.line([(cx - inset, int(stripe_y)), (cx + inset, int(stripe_y))],
           fill=GOLD + (255,), width=4)

    # Gold border
    d.polygon(pts, outline=GOLD + (255,), width=6)
    # Inner thin border
    ip = [(int(shield_cx + (x - shield_cx) * 0.92),
           int(shield_cy + (y - shield_cy) * 0.92)) for x, y in pts]
    d.polygon(ip, outline=GOLD2 + (160,), width=2)

    return img, top_y, stripe_y, bot_y


# ── 3. Stars row ──────────────────────────────────────────────────────────────
def draw_stars(img, cx, y, n=3, r=10):
    d   = ImageDraw.Draw(img)
    gap = r * 3.0
    start_x = cx - gap * (n - 1) / 2
    for i in range(n):
        sx  = start_x + i * gap
        pts = []
        for j in range(5):
            a  = math.radians(-90 + j * 72)
            pts.append((sx + r * math.cos(a), y + r * math.sin(a)))
            a2 = math.radians(-90 + j * 72 + 36)
            pts.append((sx + r * 0.42 * math.cos(a2), y + r * 0.42 * math.sin(a2)))
        d.polygon(pts, fill=GOLD + (255,))


# ── 4. Football ───────────────────────────────────────────────────────────────
def draw_football(img, bx, by, r):
    # Drop shadow
    sh = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    sd = ImageDraw.Draw(sh)
    for i in range(16, 0, -1):
        a = int(65 * (1 - i / 16))
        sd.ellipse([bx-r+i, by-r+i+10, bx+r+i, by+r+i+10], fill=(0, 0, 0, a))
    sh = sh.filter(ImageFilter.GaussianBlur(7))
    img = Image.alpha_composite(img, sh)

    d = ImageDraw.Draw(img)
    # Ball body
    d.ellipse([bx-r, by-r, bx+r, by+r],
              fill=(242, 242, 242, 255), outline=(160, 160, 160, 255), width=2)

    def pent(px, py, pr, rot):
        pts = []
        for i in range(5):
            a = math.radians(rot + i * 72 - 90)
            pts.append((px + pr * math.cos(a), py + pr * math.sin(a)))
        d.polygon(pts, fill=(20, 20, 20, 255))

    # Center patch
    pent(bx, by, r * 0.26, 0)
    # 5 surrounding patches
    for i in range(5):
        a = math.radians(-90 + i * 72)
        pent(bx + r * 0.52 * math.cos(a),
             by + r * 0.52 * math.sin(a),
             r * 0.20, i * 72 + 36)

    # Shine
    d.ellipse([bx - r * 0.52, by - r * 0.56,
               bx + r * 0.02, by - r * 0.08],
              fill=(255, 255, 255, 140))
    return img


# ── 5. Text ───────────────────────────────────────────────────────────────────
def draw_text(img, top_y, stripe_y, bot_y, ball_y, ball_r):
    d = ImageDraw.Draw(img)

    impact  = "/System/Library/Fonts/Supplemental/Impact.ttf"
    f_title = load_font(impact, 62)
    f_fc    = load_font(impact, 50)
    f_sub   = load_font("/System/Library/Fonts/Helvetica.ttc", 15)

    # ── "CA KHIA" in red stripe, above ball ──
    # Available vertical space: top_y+8 .. ball_y-ball_r-6
    text_zone_top = top_y + 10
    text_zone_bot = ball_y - ball_r - 8
    bb  = d.textbbox((0, 0), "CA KHIA", font=f_title)
    th  = bb[3] - bb[1]
    ty  = int((text_zone_top + text_zone_bot) / 2 - th / 2)
    text_centered(d, "CA KHIA", cx, ty, f_title, GOLD, shadow=True)

    # ── "FC" in bottom half ──
    nav_center = (stripe_y + bot_y) / 2
    bb2 = d.textbbox((0, 0), "FC", font=f_fc)
    th2 = bb2[3] - bb2[1]
    fc_y = int(nav_center - th2 / 2 - 6)
    text_centered(d, "FC", cx, fc_y, f_fc, ORG, shadow=True)

    # ── "QUIZ BONG DA" small subtitle ──
    sub_y = fc_y + th2 + 4
    text_centered(d, "QUIZ BONG DA", cx, sub_y, f_sub,
                  (180, 180, 210, 200), shadow=False)

    return img


# ── 6. Round corners ─────────────────────────────────────────────────────────
def round_corners(img, r=88):
    mask = Image.new("L", (S, S), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, S-1, S-1], radius=r, fill=255)
    result = img.copy()
    result.putalpha(mask)
    return result


# ── Main ──────────────────────────────────────────────────────────────────────
def generate():
    img = make_bg()
    img, top_y, stripe_y, bot_y = draw_shield(img)

    # Ball: sits on divider, centered
    ball_r = 52
    ball_x = cx
    ball_y = int(stripe_y)   # ball center IS the divider

    # Stars: between "CA KHIA" text and ball — placed at 70% of red stripe
    star_y = int(top_y + (stripe_y - top_y) * 0.80) - ball_r // 2 + 2
    draw_stars(img, cx, star_y, n=3, r=9)

    img = draw_football(img, ball_x, ball_y, ball_r)
    img = draw_text(img, top_y, stripe_y, bot_y, ball_y, ball_r)
    img = round_corners(img, 88)
    return img


def save_all(master, base_dir):
    sizes = {
        "icon_master.png":    512,
        "play_store_512.png": 512,
        "android_192.png":    192,
        "android_144.png":    144,
        "android_96.png":      96,
        "android_72.png":      72,
        "android_48.png":      48,
        "android_36.png":      36,
    }
    os.makedirs(base_dir, exist_ok=True)
    for name, size in sizes.items():
        out = master.resize((size, size), Image.LANCZOS)
        out.save(os.path.join(base_dir, name), "PNG")
        print(f"  ✓ {name}")


if __name__ == "__main__":
    print("Generating Ca Khia FC icon v4...")
    icon = generate()
    out  = os.path.join(os.path.dirname(__file__), "..", "assets", "images")
    save_all(icon, out)
    print("\nDone! 🎉")
