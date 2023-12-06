#!/usr/bin/env python3
import base64
import gzip
import io

def str2scancode(s):
    scancodes = {
        "a": [0x1E], "b": [0x30], "c": [0x2E], "d": [0x20], "e": [0x12],
        "f": [0x21], "g": [0x22], "h": [0x23], "i": [0x17], "j": [0x24],
        "k": [0x25], "l": [0x26], "m": [0x32], "n": [0x31], "o": [0x18],
        "p": [0x19], "q": [0x10], "r": [0x13], "s": [0x1F], "t": [0x14],
        "u": [0x16], "v": [0x2F], "w": [0x11], "x": [0x2D], "y": [0x15],
        "z": [0x2C]
    }
    for x in list(scancodes.keys()):
        scancodes[x].append(scancodes[x][0] | 0x80)
        scancodes[x.upper()] = [0x2A] + scancodes[x] + [0xAA]
    for i in range(1, 10):
        scancodes[str(i)] = [1 + i, 0x80 | (1 + i)]
    scancodes["0"] = [0x0B, 0x8B]
    scancodes["-"] = [0x0C, 0x8C]
    scancodes[" "] = [0x39, 0xB9]
    scancodes["<"] = [0x2A, 0x33, 0xB3, 0xAA]
    scancodes["("] = [0x2A, 0x0A, 0x8A, 0xAA]
    scancodes[")"] = [0x2A, 0x0B, 0x8B, 0xAA]
    scancodes["."] = [0x34, 0xB4]
    scancodes["/"] = [0x35, 0xB5]
    scancodes["\n"] = [0x1C, 0x9C]
    scancodes["="] = [0x0D, 0x8D]
    scancodes["+"] = [0x2A, 0x0D, 0x8D, 0xAA]
    scancodes["|"] = [0x2A, 0x2B, 0xAB, 0xAA]
    scancodes[">"] = [0x2A, 0x34, 0xB4, 0xAA]
    scancodes["&"] = [0x2A, 0x08, 0x88, 0xAA]
    codes = []
    for c in s:
        codes += scancodes[c]
    ret = []
    cmd = "vboxmanage controlvm arch keyboardputscancode {} > nul"
    for chunk in [codes[i:i+128] for i in range(0, len(codes), 128)]:
        ret.append(cmd.format(" ".join("{:02X}".format(x) for x in chunk)))
    return "\n".join(ret)


if __name__ == "__main__":
    with open("host.bat", "r") as f:
        template = f.read()
    with open("guest.sh", "rb") as f:
        script = f.read()
    out = io.BytesIO()
    with gzip.GzipFile(fileobj=out, mode="wb", mtime=0, filename="") as f:
        f.write(script)
    out = base64.b64encode(out.getvalue()).decode()
    command = f"echo {out} | base64 -d | zcat > setup.sh && chmod u+x setup.sh && ./setup.sh\n"
    scancodes = str2scancode(command)
    with open("archvbox.bat", "wb") as f:
        f.write(template.format(scancodes=scancodes).encode())
    print("written to archvbox.bat")
