#!/usr/bin/env python

from datetime import date
import hivex
import os
import sys
sys.path.append(os.path.dirname(__file__))
import hive as hivelib
import tables

regids = {'{9dea862c-5cdd-4e70-acc1-f32b344d4795}':'Windows Boot Manager (bootmgr)',
          '{a5a30fa2-3d06-4e9f-b5f4-a01df9d1fcba}':'Firmware Boot Manager (fwbootmgr)',
          '{b2721d73-1db4-4c62-bf78-c548a880142d}':'Windows Memory Tester (memdiag)',
          '{147aa509-0358-4473-b83b-d950dda00615}':'Windows Resume Application',
          '{466f5a88-0af2-4f76-9038-095b170dc21c}':'Legacy Windows Loader (ntldr)',
          '{fa926493-6f1c-4193-a414-58f0b2456d1e}':'Current boot entry (current)',
          '{3afd365b-4349-11e3-b0da-a722f0df0a34}':'Windows Boot Loader (OS)',
          '{3afd365c-4349-11e3-b0da-a722f0df0a34}':'Windows Boot Loader (WinRE)',
          '{3afd365a-4349-11e3-b0da-a722f0df0a34}':'Resume from Hibernate',
          '{3afd365d-4349-11e3-b0da-a722f0df0a34}':'Device options',
          '{0ce4991b-e6b3-4b16-b23c-5e0d9250e5d9}':'EMS Settings',
          '{4636856e-540f-4170-a130-a84776f4c654}':'Debugger Settings',
          '{5189b25c-5558-4bf2-bca4-289b11bd29e2}':'RAM Defects',
          '{7ea2e1ac-2e61-4728-aaa3-896d9d0a9f0e}':'Global Settings',
          '{6efb52bf-1766-41db-a6b3-0ee5eff72bd7}':'Boot Loader Settings',
          '{7ff607e0-4395-11db-b0de-0800200c9a66}':'Hypervisor Settings',
          '{1afa9c49-16ab-4a5c-901b-212802da9460}':'Resume Loader Settings',
          '{7619dcc8-fafe-11d9-b411-000476eba25f}':'device',
          '{7619dcc9-fafe-11d9-b411-000476eba25f}':'osdevice' }

kinds = {1:'Application', 2:'Inherited', 3:'Device'}
appkinds = {1:'Firmware', 2:'Windows Boot', 3:'Legacy Loader', 4:'Real-mode'}
inheritkinds = {1:'Inheritable by any object', 2:'Inheritable by application objects', 3:'Inheritable by device objects'}
apptypes = {1:'FWBootMgr', 2:'BootMgr', 3:'OSLoader', 4:'Resume', 5:'MemDiag', 6:'NTLdr', 7:'SetupLdr', 8:'Bootsector', 9:'StartupCom', 10:'BootApp'}

elemtypes = {0x11000001: 'Device', 0x12000002:'Path', 0x12000004:'Description', 0x12000005:'Locale', 0x14000006:'Inherit',
             0x15000011: 'DebugType', 0x15000012: 'DebugAddress', 0x15000013: 'DebugPort', 0x15000014: 'BaudRate',
             0x16000020:'BootEMS',
             0x21000001:'OSDevice', 0x22000002:'SystemRoot', 0x26000010:'DetectKernelAndHal', 0x26000022:'WinPE', 0x260000B0:'EmsEnabled',
             0x24000001:'DisplayOrder', 0x24000002:'BootSequence', 0x23000003:'Default',0x25000004:'Timeout', 0x24000010:'ToolsDisplayOrder',
             0x250000F3:'HypervisorDebugType', 0x250000F4:'HypervisorDebugPort', 0x250000F5:'HypervisorBaudrate',
             0x31000003:'RamdiskSdiDevice', 0x32000004:'RamdiskSdiPath'}

edecoder = {}

def lookup(row, name, value, table):
    if value in table:
        row.append( {'Name': name, 'Value': table[value]} )
    else:
        row.append( {'Name': name, 'Value': 'Unknown'} )

def loadbcdobject(hive, node):
    table = tables.Table.make( {'Name':30, 'Value':80} )
    id = hive.node_name(node)
    table.data.append( {'Name': 'Id', 'Value': id} )
    lookup(table.data, 'Name', id, regids)

    otype = hivelib.getvalue(hive, hivelib.getkey(hive, hive.node_get_child(node, 'Description'), 'Type'))
    kind = otype >> 28
    table.data.append({'Name':'Type', 'Value': '{0:08X}'.format(otype)  })
    lookup(table.data, 'Kind', kind, kinds)
    if kind == 1:
        lookup(table.data, 'Image type', (otype >> 20)&0xF, appkinds)
    if kind == 2:
        lookup(table.data, 'Image type', (otype >> 20)&0xF, inheritkinds)
    atype = otype & 0x0FFFFF
    if atype != 0:
        lookup(table.data, 'Application type', atype, apptypes)

    for elem in hive.node_children(hive.node_get_child(node, 'Elements')):
        etype = int(hive.node_name(elem), 16)
        evalue = hivelib.getvalue(hive, hivelib.getkey(hive, elem, 'Element'))
        eformat = (etype>>24) & 0x0F
        if eformat in edecoder:
            evalue = edecoder[eformat](evalue)
        if etype in elemtypes:
            table.data.append( {'Name': elemtypes[etype], 'Value': evalue} )
        else:
            table.data.append( {'Name': 'Unknown: {0:08X}'.format(etype), 'Value': evalue} )

    return table

def main():
    import argparse
    import os
    import sys
    sys.path.append(os.path.dirname(__file__))

    parser = argparse.ArgumentParser(description="Dumps an information from BCD hive")
    parser.add_argument("bcdfile", type=str, help="Path to the Boot Configuration Data hive")
    args = parser.parse_args()
    bcdhive = hivex.Hivex(args.bcdfile)

    for obj in bcdhive.node_children(hivelib.getnode(bcdhive, 'Objects')):
        print(loadbcdobject(bcdhive, obj))

if __name__ == "__main__":
    main()
