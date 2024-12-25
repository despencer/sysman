#!/usr/bin/env python

from datetime import date
import hivex

def getnode(hive, path, node=None):
    if node == None:
        node = hive.root()
    for p in path.split('\\'):
        node = hive.node_get_child(node, p)
    return node

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
        table = cls()
        for cname, cwidth in columns.items():
            if isinstance(cwidth, Column):
                table.columns[cname] = cwidth
                cwidth.name = cname
            else:
                table.columns[cname] = Column(cname, cwidth)
        table.append(hive, path, list(columns.keys()), conversion)
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

def main():
    import argparse

    parser = argparse.ArgumentParser(description="Dumps an information from software hive")
    parser.add_argument("softfile", type=str, help="Path to the Software registry hive")
    args = parser.parse_args()
    softhive = hivex.Hivex(args.softfile)
    installed = Table.load(softhive, 'Microsoft\\Windows\\CurrentVersion\\Uninstall',
             {'InstallDate': Column.date(), 'DisplayName': 80, 'DisplayVersion':20, 'Publisher':30},
             conversion={'InstallDate':date.fromisoformat} )
    installed.append(softhive, 'WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall',
             ['InstallDate', 'DisplayName', 'DisplayVersion', 'Publisher'], conversion={'InstallDate':date.fromisoformat} )
    installed.sort('InstallDate')
    print(installed)

if __name__ == "__main__":
    main()
