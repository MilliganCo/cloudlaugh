#!/usr/bin/env python3
"""
Generates a minimal PNG launcher icon with a laughing emoji background.
Uses only Python stdlib (zlib, struct).
"""
import zlib
import struct
import os

SCRIPT_DIR = os.path.dirname(__file__)
RES_DIR = os.path.join(SCRIPT_DIR, '..', 'android', 'app', 'src', 'main', 'res')

SIZES = {
    'mipmap-mdpi':    48,
    'mipmap-hdpi':    72,
    'mipmap-xhdpi':   96,
    'mipmap-xxhdpi':  144,
    'mipmap-xxxhdpi': 192,
}


def png_chunk(name: bytes, data: bytes) -> bytes:
    length = struct.pack('>I', len(data))
    crc = struct.pack('>I', zlib.crc32(name + data) & 0xFFFFFFFF)
    return length + name + data + crc


def make_png(size: int) -> bytes:
    """Create a solid yellow circle on dark background PNG."""
    bg = (26, 26, 46)       # Dark blue-navy background
    fg = (255, 215, 0)      # Gold circle
    cx = cy = size / 2
    radius = size * 0.42

    rows = []
    for y in range(size):
        row = bytearray()
        for x in range(size):
            dx, dy = x - cx, y - cy
            if dx * dx + dy * dy <= radius * radius:
                row += bytes(fg)
            else:
                row += bytes(bg)
        rows.append(b'\x00' + bytes(row))   # filter byte None (0)

    raw = b''.join(rows)
    compressed = zlib.compress(raw, 9)

    ihdr_data = struct.pack('>IIBBBBB', size, size, 8, 2, 0, 0, 0)
    idat_data = compressed

    png = b'\x89PNG\r\n\x1a\n'
    png += png_chunk(b'IHDR', ihdr_data)
    png += png_chunk(b'IDAT', idat_data)
    png += png_chunk(b'IEND', b'')
    return png


def main():
    for folder, size in SIZES.items():
        out_dir = os.path.join(RES_DIR, folder)
        os.makedirs(out_dir, exist_ok=True)
        path = os.path.join(out_dir, 'ic_launcher.png')
        with open(path, 'wb') as f:
            f.write(make_png(size))
        print(f"  {folder}/ic_launcher.png  ({size}x{size})")
    print("Icons generated.")


if __name__ == '__main__':
    main()
