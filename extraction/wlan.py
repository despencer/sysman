#!/usr/bin/env python
from collections import Counter
import Evtx.Evtx as evtx
import Evtx.Views as e_views

ns = {'evt':'http://schemas.microsoft.com/win/2004/08/events/event'}

nevents = {'11010':'MsmSecurity Start', '11004':'MsmSecurity Stop', '11005':'MsmSecurity Success', '11000':'MsmAssociation Start',
           '11001':'MsmAssociation Success', '11002':'MsmAssociation Failure', '11006':'MsmSecurity Failure', '8001':'AcmConnection Success',
           '8002':'AcmConnection Failure', '8003':'AcmConnection Disconnect', '8000':'AcmConnection Start'}
ntasks = {'24010':'AcmConnection', '24011':'MsmAssociation', '24012':'MsmSecurity'}

def printstat(name, cnt, lookup):
    print(name)
    for key, value in cnt.most_common():
        print(key, value, lookup[key] if key in lookup else '')

def stat(evtxlog):
    ids = Counter()
    tasks = Counter()
    ssid = Counter()
    for record in evtxlog.records():
        event = record.lxml()
        system = event.xpath('evt:System', namespaces=ns)[0]
        ids[system.xpath('evt:EventID/text()', namespaces=ns)[0]] += 1
        tasks[system.xpath('evt:Task/text()', namespaces=ns)[0]] += 1
        ssid[event.xpath('evt:EventData/evt:Data[@Name="SSID"]/text()', namespaces=ns)[0]] += 1
    printstat('Events', ids, nevents)
    printstat('Tasks', tasks, ntasks)
    printstat('SSID', ssid, {})

def main():
    import argparse

    parser = argparse.ArgumentParser(description="Dump a binary EVTX file into XML.")
    parser.add_argument("evtx", type=str, help="Path to the Windows EVTX event log file")
    parser.add_argument("func", type=str, help="Function to perform: stat")
    args = parser.parse_args()

    with evtx.Evtx(args.evtx) as log:
        {'stat':stat}[args.func](log)

if __name__ == "__main__":
    main()
