#!/usr/bin/python
# -*- coding=utf-8 -*-
"""Create file arborescence corresponding to a law json output from parse_texte.py

Run with python json2arbo.py JSON_FILE PROJECT
where LAW_FILE results from perl download_loi.pl URL > LAW_FILE
Outputs results to stdout

Dependencies :
simplejson"""

import os, sys, re
import simplejson as json

def mkdirs(d):
  if not os.path.exists(d):
    os.makedirs(d)

re_sec_path = re.compile(r"(\d)(\D)")
def sec_path(s):
  return re_sec_path.sub(r"\1/\2", s)

def write_text(t, p):
  try:
    f = open(p, "w")
  except:
    print "ERROR: Cannot file to write", p
    return
  f.write(t.encode("utf-8"))
  f.close()

def write_json(j, p):
  write_text(json.dumps(j, sort_keys=True, indent=1, ensure_ascii=False), p)

re_cl_ids = re.compile(r"\s+")

replace_str = [
  (re.compile(r'"'), " "),
  (re.compile(r"^[IVXLCDM]+\.?\s*-?\s*"), ""),
  (re.compile(r"\s+"), " ")
]
def clean_text(t):
  for regex, repl in replace_str:
    t = regex.sub(repl, t)
#  return t
  return t.strip()

try:
  FILE = sys.argv[1]
  f = open(FILE, "r")
except:
  print "ERROR: Cannot open json file", FILE
  sys.exit()

mkdirs("data") 
os.chdir("data")

try:
  project = sys.argv[2]
  mkdirs(project)
  os.chdir(project)
except:
  print "ERROR: Cannot create dir for project", project
  sys.exit()

textid = ""
for l in f:
  data = json.loads(l)
  if not "type" in data:
    print "ERROR: JSON badly formatted, missing field type:", data
    sys.exit()
  if data["type"] == "texte":
    textid = data["id"]
#   textid = date_formatted+"_"+data["id"]
    write_json(data, textid+".json")
    write_text(clean_text(data["titre"]), textid+".titre")
  elif textid == "":
    print "ERROR: JSON missing first line with text infos"
    sys.exit()
  elif data["type"] == "section":
    path = sec_path(data["id"])
    mkdirs(path)
    write_json(data, path+"/"+textid+".json")
    write_text(clean_text(data["titre"]), path+"/"+textid+".titre")
  elif data["type"] == "article":
    path = ""
    if "section" in data:
      path = sec_path(data["section"])+"/"
    path += "A"+re_cl_ids.sub('_', data["titre"])+"/"
    mkdirs(path)
    write_json(data, path+textid+".json")
    text = ""
    for i in range(len(data["alineas"])):
      if text != "":
        text += "\n"
      text += clean_text(data["alineas"][str(i+1)])
    write_text(text, path+textid+".alineas")

f.close()
