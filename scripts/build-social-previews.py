"""Build branded 1200x630 PNG share images. Requires Pillow."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

root = Path(__file__).resolve().parents[1] / 'site'
fonts = Path('C:/Windows/Fonts')
for slug, name, theme, lines in [
    ('yaqeen', 'Yaqeen', '#173f38', ['Islamic faith.', 'Daily remembrance.', 'A caring community.']),
    ('afrimed', 'Afrimed', '#194e5b', ['Health technology.', 'Connections to care.', 'Community support.']),
]:
    image = Image.new('RGB', (1200, 630), '#f5f3e9')
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle((840, -80, 1350, 710), radius=230, fill=theme)
    draw.ellipse((890, 160, 1250, 520), outline='#a5bcac', width=2)
    draw.text((70, 55), name, font=ImageFont.truetype(str(fonts/'georgia.ttf'), 62), fill=theme)
    for i, line in enumerate(lines):
        draw.text((70, 190+i*80), line, font=ImageFont.truetype(str(fonts/'georgia.ttf'), 48), fill=theme)
    draw.text((70, 540), 'COMING SOON', font=ImageFont.truetype(str(fonts/'arial.ttf'), 24), fill=theme)
    if slug == 'afrimed':
        icon = Image.open(root/'afrimed-icon.png').convert('RGBA')
        icon.thumbnail((180, 180))
        image.paste(icon, (950, 230), icon)
    else:
        draw.text((980, 250), 'Y', font=ImageFont.truetype(str(fonts/'georgia.ttf'), 130), fill='#e7d6a0')
    image.save(root/slug/'social-preview.png', optimize=True)
print('Built social preview images')
