#!/usr/bin/env python

from datetime import date
import hivex

def decode_productkey(rawbuf):
    idpart = bytearray(rawbuf)
    isWin8 = (idpart[14] // 6) & 1
    if isWin8:
        idpart[14] = (idpart[14] & 0xF7) | ((isWin8 & 2) * 4)

    charStore = "BCDFGHJKMPQRTVWXY2346789"
    productkey = ""
    lastC = 0    # isWin8 support

    for i in range(25):
        c = 0
        for j in range(14, -1, -1):
            c = (c << 8) ^ idpart[j]
            idpart[j] = c // 24
            c %= 24
        productkey = charStore[c] + productkey
        lastC = c

    if isWin8:
        insert = "N"
        if lastC == 0:
            productkey = insert + productkey
        else:
            keypart1 = productkey[1:1+lastC]
            productkey = productkey[1:].replace(keypart1, keypart1 + insert)

    return '-'.join([productkey[i * 5:i * 5 + 5] for i in range(5)])

def getnode(hive, path, node=None):
    if node == None:
        node = hive.root()
    for p in path.split('\\'):
        node = hive.node_get_child(node, p)
    return node

def getvalue(hive, key):
    decoder = { 1: lambda h,k: h.value_string(k), 3: lambda h,k: h.value_value(k)[1],  4:lambda h,k: h.value_dword(k) }
    valtype = hive.value_type(key)[0]
    if valtype in decoder:
        return decoder[valtype](hive, key)
    return str(valtype) + ': Unknown registry value type'

class Column:
    def __init__(self, name, width):
        self.name = name
        self.width = width
        self.presentation = str
        self.nvl = lambda x: ''

    @classmethod
    def date(cls):
        col = cls('Date', 10)
        col.nvl = lambda x: date(1900,1,1) if x == None else x
        return col

class Table:
    def __init__(self):
        self.data = []
        self.columns = {}

    @classmethod
    def load(cls, hive, path, columns, conversion={}):
        table = cls.make(columns)
        table.append(hive, path, list(columns.keys()), conversion)
        return table

    @classmethod
    def loadkeys(cls, hive, path):
        table = cls.make( {'Name':30, 'Value':80} )
        node = getnode(hive, path)
        for v in hive.node_values(node):
            table.data.append( {'Name':hive.value_key(v), 'Value':getvalue(hive, v)} )
        return table

    @classmethod
    def make(cls, columns):
        table = cls()
        for cname, cwidth in columns.items():
            if isinstance(cwidth, Column):
                table.columns[cname] = cwidth
                cwidth.name = cname
            else:
                table.columns[cname] = Column(cname, cwidth)
        return table

    def append(self, hive, path, columns, conversion={}):
        node = getnode(hive, path)
        for rownode in hive.node_children(node):
            row = {}
            for v in hive.node_values(rownode):
                name = hive.value_key(v)
                if name in columns:
                    value = hive.value_string(v)
                    if name in conversion:
                        value = conversion[name](value)
                    row[name] = value
            for cname in self.columns.keys():
                if cname not in row:
                    row[cname] = None
            self.data.append(row)

    def sort(self, cname):
        self.data = sorted(self.data, key=lambda x: self.columns[cname].nvl(x[cname]))

    def __repr__(self):
        ret = ''
        for c in self.columns.values():
            ret += c.name.ljust(c.width)[:c.width] + ' '
        ret += '\n'
        for c in self.columns.values():
            ret += ''.ljust(c.width, '-') + ' '
        ret += '\n'
        for row in self.data:
            for c in self.columns.values():
                value = ''
                if c.name in row:
                    value = c.presentation(row[c.name])
                ret += value.ljust(c.width)[:c.width] + ' '
            ret += '\n'
        return ret

def printheader(header):
    outline = ''.ljust(80, '=')
    print('\n'+outline)
    print('   ', header)
    print(outline)

def decode_sysinfo(sysinfo):
    prodid = next(filter(lambda x: x['Name'] == 'DigitalProductId', sysinfo.data))['Value']
    prodid4 = next(filter(lambda x: x['Name'] == 'DigitalProductId4', sysinfo.data))['Value']
    sysinfo.data.append({'Name':'DecodedProductId', 'Value':decode_productkey(prodid[52:52+15]) })
    sysinfo.data.append({'Name':'DecodedProductId4', 'Value':decode_productkey(prodid4[808:808+15]) })

def main():
    import argparse

    parser = argparse.ArgumentParser(description="Dumps an information from software hive")
    parser.add_argument("softfile", type=str, help="Path to the Software registry hive")
    args = parser.parse_args()
    softhive = hivex.Hivex(args.softfile)

    sysinfo = Table.loadkeys(softhive, 'Microsoft\\Windows NT\\CurrentVersion')
    decode_sysinfo(sysinfo)

    installed = Table.load(softhive, 'Microsoft\\Windows\\CurrentVersion\\Uninstall',
             {'InstallDate': Column.date(), 'DisplayName': 80, 'DisplayVersion':20, 'Publisher':30},
             conversion={'InstallDate':date.fromisoformat} )
    installed.append(softhive, 'WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall',
             ['InstallDate', 'DisplayName', 'DisplayVersion', 'Publisher'], conversion={'InstallDate':date.fromisoformat} )
    installed.sort('InstallDate')
    printheader('System Info')
    print(sysinfo)
    printheader('Installed Software')
    print(installed)

if __name__ == "__main__":
    main()
