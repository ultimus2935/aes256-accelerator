def gf_mult(a, b):
    p = 0
    for _ in range(8):
        if b & 1: p ^= a
        
        hi_bit_set = a & 0x80
        a = (a << 1) & 0xFF
        
        if hi_bit_set: a ^= 0x1B 
        
        b >>= 1
    return p

def gf_inv(a):
    if a == 0: return 0
    
    for b in range(1, 256):
        if gf_mult(a, b) == 1: return b
        
    return 0

def rol8(val, shift):
    return ((val << shift) | (val >> (8 - shift))) & 0xFF

def affine_transform(b):
    s = b ^ rol8(b, 1) ^ rol8(b, 2) ^ rol8(b, 3) ^ rol8(b, 4)
    return s ^ 0x63

sbox = []
for i in range(256):
    inverse = gf_inv(i)
    substituted_byte = affine_transform(inverse)
    sbox.append(substituted_byte)

with open("data/sbox_lut.mem", 'w') as f:
    for i in range(0, 256, 16):
        row = sbox[i:i+16]
        hex_strings = [f"{byte:02X}" for byte in row]
        
        f.write(" ".join(hex_strings) + "\n")