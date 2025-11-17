#!/usr/bin/env python3
"""
Generate minimal valid PNG icon files without external dependencies.
Creates simple solid blue PNG files.
"""

import struct
import zlib

def create_png(width, height, filename, color=(0, 102, 204)):
    """
    Create a simple solid-color PNG file.

    Args:
        width: Image width in pixels
        height: Image height in pixels
        filename: Output filename
        color: RGB tuple (r, g, b) - default is blue #0066CC
    """

    def write_chunk(f, chunk_type, data):
        """Write a PNG chunk."""
        length = len(data)
        f.write(struct.pack('>I', length))
        f.write(chunk_type)
        f.write(data)
        crc = zlib.crc32(chunk_type + data) & 0xffffffff
        f.write(struct.pack('>I', crc))

    with open(filename, 'wb') as f:
        # PNG signature
        f.write(b'\x89PNG\r\n\x1a\n')

        # IHDR chunk (image header)
        ihdr_data = struct.pack('>IIBBBBB',
            width, height,  # width, height
            8,              # bit depth
            2,              # color type (2 = RGB)
            0,              # compression method
            0,              # filter method
            0               # interlace method
        )
        write_chunk(f, b'IHDR', ihdr_data)

        # IDAT chunk (image data)
        # Create raw image data (RGB)
        raw_data = bytearray()
        for y in range(height):
            raw_data.append(0)  # filter type (0 = none)
            for x in range(width):
                raw_data.extend(color)  # RGB pixel

        # Compress the raw data
        compressed_data = zlib.compress(bytes(raw_data), 9)
        write_chunk(f, b'IDAT', compressed_data)

        # IEND chunk (end of file)
        write_chunk(f, b'IEND', b'')

    print(f"Created {filename}: {width}x{height} PNG ({len(open(filename, 'rb').read())} bytes)")

if __name__ == '__main__':
    # Create icons with Beszel blue color (#0066CC)
    create_png(72, 72, 'icons/PACKAGE_ICON.PNG', color=(0, 102, 204))
    create_png(256, 256, 'icons/PACKAGE_ICON_256.PNG', color=(0, 102, 204))
    print("Icons created successfully!")
