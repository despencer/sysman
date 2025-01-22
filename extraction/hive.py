def getnode(hive, path, node=None):
    if node == None:
        node = hive.root()
    for p in path.split('\\'):
        node = hive.node_get_child(node, p)
    return node

def getkey(hive, node, name):
    for v in hive.node_values(node):
        if hive.value_key(v) == name:
            return v
    return None

def getvalue(hive, key):
    decoder = { 1: lambda h,k: h.value_string(k), 3: lambda h,k: h.value_value(k)[1],  4:lambda h,k: h.value_dword(k),
                7: lambda h,k: h.value_multiple_strings(k) }
    valtype = hive.value_type(key)[0]
    if valtype in decoder:
        return decoder[valtype](hive, key)
    return str(valtype) + ': Unknown registry value type'
