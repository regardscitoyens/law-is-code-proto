#!/usr/bin/python
# -*- coding=utf-8 -*-
"""Create a json from from a procedure csv one"""

import sys
import simplejson as json
import csv

def row2dir(row):
    return row[3]+'_'+row[5].replace(' ', '')+'_'+row[6]+'_'+row[7]

procedure = {'type': 'Normale'}
steps = []
with open(sys.argv[1], 'rb') as csvfile:
    csvproc = csv.reader(csvfile, delimiter=';')
    for row in csvproc:
        step = {'date': row[10], 'stage': row[5], 'institution': row[6], 'source_url': row[8]}
        if (row[4] != 'EXTRA'):
            step['directory'] = row2dir(row)
            step['step'] = row[7]
            step['resulting_text_directory'] =  row2dir(row)+'/texte'
            if ((row[3] != 'XX') and (int(row[3]) > 0)):
                step['working_text_directory'] = row2dir(prevrow)+'/texte'
            steps.append(step)
        else:
            if (row[5] == 'URGENCE'):
                procedure['type'] = 'Accelerée'
            else:
                steps.append(step)
        prevrow = row
    procedure['steps'] = steps
    procedure['beginning'] = steps[0]['date']
    print json.dumps(procedure, sort_keys=True, ensure_ascii=False).encode("utf-8")
                         
