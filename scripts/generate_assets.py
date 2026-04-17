"""
Generate Gôn! Quiz visual assets:
  - assets/images/icon_master.png  (1024x1024 — dùng cho flutter_launcher_icons)
  - landing/play_store_icon.png    (512x512  — upload lên CH Play)
  - landing/banner.png             (1024x500 — feature graphic CH Play)
"""
import math
import os
from PIL import Image, ImageDraw, ImageFont

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# ── Font paths (macOS) ────────────────────────────────────────────────────────
FONT_PATHS = [
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
    "/Library/Fonts/Arial Bold.ttf",
    "/Library/Fonts/Arial.ttf",
    "/System/Library/Fonts/Supplemental/Arial.ttf",
]
EMOJI_FONT = "/System/Library/Fonts/Apple Color Emoji.ttc"

def load_font(size, bold=True):
    for path in FONT_PATHS:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                continue
    return ImageFont.load_default()

def load_emoji_font(size):
    if os.path.exists(EMOJI_FONT):
        try:
            return ImageFont.truetype(EMOJI_FONT, size)
        except Exception:
            pass
    return load_font(size)

# ── Colour palette ────────────────────────────────────────────────────────────
BG_TOP    = (10,  8,  30)
BG_BOT    = (13, 26, 58)
GOLD_1    = (248, 208, 96)
GOLD_2    = (232, 160, 32)
ORANGE    = (249, 115, 22)
WHITE     = (255, 255, 255)
GREY      = (160, 180, 208)
DARK      = (0,   0,   0)

# ── Helpers ───────────────────────────────────────────────────────────────────
def v_gradient(img, top_col, bot_col):
    draw = ImageDraw.Draw(img)
    w, h = img.size
    for y in range(h):
        t = y / h
        r = int(top_col[0] + (bot_col[0]-top_col[0]) * t)
        g = int(top_col[1] + (bot_col[1]-top_col[1]) * t)
        b = int(top_col[2] + (bot_col[2]-top_col[2]) * t)
        draw.line([(0, y), (w, y)], fill=(r, g, b))

def gold_text(draw, text, x, y, font, anchor="mm"):
    """Draw text with a gold colour and soft glow."""
    # glow
    for dx in range(-4, 5, 2):
        for dy in range(-4, 5, 2):
            draw.text((x+dx, y+dy), text, font=font,
                      fill=(232, 160, 32, 60), anchor=anchor)
    draw.text((x, y), text, font=font, fill=GOLD_1, anchor=anchor)

def draw_football(draw, cx, cy, r):
    """Draw a simplified football (white circle + black hexagon patches)."""
    # White ball
    draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=(245, 245, 245),
                 outline=(200, 200, 200), width=max(1, r//40))

    # Pentagon/patch pattern — simplified 5-spot pattern
    patch_r = int(r * 0.22)
    spots = [
        (0, 0),
        (0, -0.42),
        (0.40, -0.13),
        (0.25,  0.36),
        (-0.25,  0.36),
        (-0.40, -0.13),
    ]
    for sx, sy in spots:
        px, py = cx + int(sx * r), cy + int(sy * r)
        draw.ellipse([px-patch_r, py-patch_r, px+patch_r, py+patch_r],
                     fill=(20, 20, 20))

def draw_hexgrid(draw, w, h, size=36):
    """Subtle hex grid background."""
    for row in range(-1, h // size + 3):
        for col in range(-1, int(w / (size * 1.73)) + 3):
            cx = col * size * 1.73 + (row % 2) * size * 0.865
            cy = row * size * 1.5
            pts = []
            for i in range(6):
                a = math.pi/3 * i - math.pi/6
                pts.append((cx + size * math.cos(a), cy + size * math.sin(a)))
            draw.polygon(pts, outline=(255, 255, 255, 8))

def rounded_rect(draw, x, y, w, h, r, fill=None, outline=None, width=1):
    draw.rounded_rectangle([x, y, x+w, y+h], radius=r,
                            fill=fill, outline=outline, width=width)

def pill(draw, x, y, w, h, text, font, text_color=WHITE):
    rounded_rect(draw, x, y, w, h, h//2,
                 fill=(255, 255, 255, 18),
                 outline=(255, 255, 255, 30), width=1)
    draw.text((x + w//2, y + h//2), text, font=font,
              fill=text_color, anchor="mm")

# ══════════════════════════════════════════════════════════════════════════════
# ICON  1024×1024
# ══════════════════════════════════════════════════════════════════════════════
def make_icon(size=1024):
    img = Image.new("RGBA", (size, size), BG_TOP)
    v_gradient(img, BG_TOP, BG_BOT)
    draw = ImageDraw.Draw(img, "RGBA")

    cx, cy, S = size//2, size//2, size

    # Subtle radial glow
    for ri in range(420, 0, -1):
        alpha = int(55 * (1 - ri/420))
        draw.ellipse([cx-ri, cy-ri, cx+ri, cy+ri],
                     fill=(232, 160, 32, alpha))

    # Outer gold ring
    ring_w = max(20, size//50)
    draw.ellipse([cx-460*S//1024, cy-460*S//1024,
                  cx+460*S//1024, cy+460*S//1024],
                 outline=GOLD_2, width=ring_w)
    # Inner thin ring
    draw.ellipse([cx-410*S//1024, cy-410*S//1024,
                  cx+410*S//1024, cy+410*S//1024],
                 outline=(248, 208, 96, 50), width=2)

    # Football
    ball_r = int(240 * S / 1024)
    draw_football(draw, cx, cy + int(50 * S / 1024), ball_r)

    # "Gôn!" — large gold
    f_gon = load_font(int(200 * S / 1024))
    gold_text(draw, "Gôn!", cx, int(210 * S / 1024), f_gon, anchor="mm")

    # "QUIZ" — white, spaced
    f_quiz = load_font(int(88 * S / 1024))
    draw.text((cx, int(860 * S / 1024)), "QUIZ", font=f_quiz,
              fill=(255, 255, 255, 210), anchor="mm")

    return img

# ══════════════════════════════════════════════════════════════════════════════
# BANNER  1024×500
# ══════════════════════════════════════════════════════════════════════════════
def make_banner(W=1024, H=500):
    img = Image.new("RGBA", (W, H), BG_TOP)
    v_gradient(img, BG_TOP, BG_BOT)
    draw = ImageDraw.Draw(img, "RGBA")

    # Hex grid overlay
    draw_hexgrid(draw, W, H, size=34)

    # Decorative blobs
    blobs = [
        (820,  80, 180, (232, 160, 32, 18)),
        (900, 420, 120, (59,  130, 246, 15)),
        ( 60, 350,  90, (232, 160, 32, 13)),
        (160,  50, 220, (34,  197,  94, 10)),
    ]
    for bx, by, br, bc in blobs:
        draw.ellipse([bx-br, by-br, bx+br, by+br], fill=bc)

    # LEFT — football
    ball_r = 165
    # glow behind ball
    for gi in range(180, 0, -4):
        a = int(50 * (1 - gi/180))
        draw.ellipse([190-gi, H//2-gi, 190+gi, H//2+gi],
                     fill=(232, 160, 32, a))
    draw_football(draw, 195, H//2 + 10, ball_r)

    # "Gôn!" mini gold above ball
    f_mini = load_font(46)
    gold_text(draw, "Gôn!", 195, 82, f_mini, anchor="mm")

    # RIGHT — app name
    LEFT = 370

    f_title = load_font(90)
    gold_text(draw, "Gôn! Quiz", LEFT + 10, 195, f_title, anchor="lm")

    f_tag = load_font(28)
    draw.text((LEFT, 260), "Thách thức tri thức bóng đá Việt Nam",
              font=f_tag, fill=GREY, anchor="lm")

    # Divider
    draw.line([(LEFT, 294), (960, 294)],
              fill=(232, 160, 32, 100), width=2)

    # Pills
    pill_data = ["🏆 V-League", "🇻🇳 Đội tuyển", "🌍 Thế giới", "🔥 Ca Khía"]
    f_pill = load_font(20)
    px = LEFT
    for p in pill_data:
        pw = int(draw.textlength(p, font=f_pill)) + 32
        pill(draw, px, 316, pw, 42, p, f_pill, text_color=(208, 204, 238))
        px += pw + 10

    # CTA badge
    bx, by, bw, bh = LEFT, 392, 316, 52
    # orange gradient simulation
    for gx in range(bw):
        t = gx / bw
        r = int(GOLD_2[0] + (ORANGE[0]-GOLD_2[0]) * t)
        g = int(GOLD_2[1] + (ORANGE[1]-GOLD_2[1]) * t)
        b = int(GOLD_2[2] + (ORANGE[2]-GOLD_2[2]) * t)
        draw.line([(bx+gx, by+2), (bx+gx, by+bh-2)], fill=(r, g, b))
    rounded_rect(draw, bx, by, bw, bh, bh//2,
                 outline=ORANGE, width=1)
    f_cta = load_font(20)
    draw.text((bx+bw//2, by+bh//2), "📲  Tải miễn phí trên CH Play",
              font=f_cta, fill=DARK, anchor="mm")

    # Stars
    f_star = load_font(18)
    star_xs = [730, 768, 806, 844, 882]
    for i, sx in enumerate(star_xs):
        sy = 430 if i % 2 == 0 else 412
        draw.text((sx, sy), "★", font=f_star,
                  fill=(232, 160, 32, 150), anchor="mm")
    f_rating = load_font(13)
    draw.text((904, 422), "4.9 / 5.0", font=f_rating,
              fill=(139, 138, 160), anchor="lm")

    return img

# ══════════════════════════════════════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════════════════════════════════════
if __name__ == "__main__":
    os.makedirs(os.path.join(BASE, "landing"), exist_ok=True)

    # 1. App icon 1024×1024 → assets (used by flutter_launcher_icons)
    icon_1024 = make_icon(1024)
    icon_out = os.path.join(BASE, "assets", "images", "icon_master.png")
    icon_1024.convert("RGB").save(icon_out, "PNG")
    print(f"✓ icon_master.png (1024×1024) → {icon_out}")

    # 2. Play Store icon 512×512
    icon_512 = make_icon(512)
    icon_512_out = os.path.join(BASE, "landing", "play_store_icon.png")
    icon_512.convert("RGB").save(icon_512_out, "PNG")
    print(f"✓ play_store_icon.png (512×512) → {icon_512_out}")

    # 3. Feature graphic banner 1024×500
    banner = make_banner(1024, 500)
    banner_out = os.path.join(BASE, "landing", "banner.png")
    banner.convert("RGB").save(banner_out, "PNG")
    print(f"✓ banner.png (1024×500) → {banner_out}")

    print("\nDone! Chạy tiếp: flutter pub run flutter_launcher_icons")
