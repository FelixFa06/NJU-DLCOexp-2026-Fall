#!/usr/bin/env python3
"""图片 -> VGA 显存 coe

显存布局：640x480，每像素 12bit（RGB 各取高 4 位），列优先存放，
每列占 512 行（480 行真实数据 + 32 行填充），以配合地址 {h_addr, v_addr[8:0]}。
"""
import sys
from PIL import Image

W, H = 640, 480     # 显示分辨率
STRIDE = 512        # 显存每列占的单元数
FILL = "FFF"        # 每列末尾的填充值，永远不会被扫描到


def to_43(im):
    """居中裁剪成 4:3"""
    w, h = im.size
    if w * 3 > h * 4:                   # 偏宽，裁左右
        nw = h * 4 // 3
        x = (w - nw) // 2
        im = im.crop((x, 0, x + nw, h))
    else:                               # 偏高，裁上下
        nh = w * 3 // 4
        y = (h - nh) // 2
        im = im.crop((0, y, w, y + nh))
    return im


def generate(pic_path, coe_path):
    im = Image.open(pic_path)
    if im.mode != "RGB":                # 有透明通道的先合成到白底，否则透明区会变成黑边
        im = im.convert("RGBA")
        bg = Image.new("RGBA", im.size, (255, 255, 255, 255))
        im = Image.alpha_composite(bg, im).convert("RGB")
    im = to_43(im).resize((W, H), Image.LANCZOS)
    pix = im.load()

    vals = []
    for x in range(W):                  # 列优先：外层是列号
        vals += ["%X%X%X" % (pix[x, y][0] >> 4, pix[x, y][1] >> 4, pix[x, y][2] >> 4)
                 for y in range(H)]
        vals += [FILL] * (STRIDE - H)   # 每列补到 512

    with open(coe_path, "w") as f:
        f.write("memory_initialization_radix=16;\nmemory_initialization_vector=\n")
        for i, v in enumerate(vals):
            f.write(v + (";\n" if i == len(vals) - 1 else ",\n" if i % 32 == 31 else ","))
    print("%s -> %s：%d 项" % (pic_path, coe_path, len(vals)))


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("用法: python coe_generate.py <图片> [输出.coe]")
    generate(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else "out.coe")
