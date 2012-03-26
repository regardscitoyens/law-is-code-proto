#!/usr/bin/python
# -*- coding=utf-8 -*-
"""Doc courte

Doc longue"""

import sys, re, html5lib
import simplejson as json
from bs4 import BeautifulSoup

try:
  FILE = sys.argv[1] 
  soup = BeautifulSoup(open(FILE,"r"), "html5lib")
except: 
  print "Erreur d'ouverture du fichier", FILE
  sys.exit() 

url = re.sub(r"^.*/http", "http", FILE)
url = re.sub(r"%3A", ":", re.sub(r"%2F", "/", url))
texte = {"type": "texte", "source": url}
# Generate Senat or AN ID from URL
if re.search(r"assemblee-?nationale", url):
  m = re.search(r"/(\d+)/.+/(ta)?[\w\-]*(\d{4})[\.\-]", url)
  texte["id"] = "A" + m.group(1) + "-"
  if not m.group(2) is None:
    texte["id"] += m.group(2)
  texte["id"] += m.group(3)
else:
  m = re.search(r"(ta)?s?(\d\d)-(\d{1,3})\.", url)
  texte["id"] = "S" + m.group(2) + "-"
  if not m.group(1) is None:
    texte["id"] += m.group(1)
  texte["id"] += "%03d" % int(m.group(3))

texte["titre"] = soup.title.string
texte["expose"] = ""

# Convert from roman numbers
romans_map = zip(
    (1000,  900, 500, 400 , 100,  90 , 50 ,  40 , 10 ,   9 ,  5 ,  4  ,  1),
    ( 'M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I')
)
def romans(n):
  i = res = 0
  for d, r in romans_map:
    while n[i:i + len(r)] == r:
      res += d
      i += len(r)
  return res

# Clean html and special chars
r_ws  = re.compile(r" ");
r_oe  = re.compile(r"œ", re.I)
r_fqu = re.compile(r'(«\s+|\s+»)')
r_quo = re.compile(r'(«|»|“|”|„|‟|❝|❞|＂|〟|〞|〝)')
r_apo = re.compile(r"(’|＇|’|ߴ|՚|ʼ|❛|❜)")
r_das = re.compile(r"(‒|–|—|―|⁓|‑|‐|⁃|⏤)")
r_att = re.compile(r"(</?\w+)[^>]*>")
r_em  = re.compile(r"(</?)em>", re.I)
r_str = re.compile(r"(</?)strong>", re.I)
r_com = re.compile(r"<(![^>]*|/?(p|br/?|span))>", re.I)
r_brk = re.compile(r"\s*\n+\s*")
r_mws = re.compile(r"\s+")
def clean_html(t):
  l =  r_ws.sub(" ", str(t))
  l =  r_oe.sub("oe", l)
  l = r_fqu.sub('"', l)
  l = r_quo.sub('"', l)
  l = r_apo.sub("'", l)
  l = r_das.sub("-", l)
  l = r_att.sub(r"\1>", l)
  l =  r_em.sub(r"\1i>", l)
  l = r_str.sub(r"\1b>", l)
  l = r_com.sub("", l)
  l = r_brk.sub(" ", l)
  l = r_mws.sub(" ", l)
  return l.strip()

def pr_js(a):
  print json.dumps(a, sort_keys=True, indent=1, ensure_ascii=False).encode("utf-8")

re_cl_html = re.compile(r"<[^>]+>")
re_cl_par  = re.compile(r"(\(|\))")
re_cl_uno  = re.compile(r"(premi|unique?)", re.I)
re_mat_sec = re.compile(r"((chap|t)itre|volume|livre|tome|(sous-)?section)\s+(.+)e?r?", re.I)
re_mat_art = re.compile(r"articles?\s+([^(]*)(\([^)]*\))?$", re.I)
re_mat_ppl = re.compile(r"(<b>)?pro.* loi", re.I)
re_mat_exp = re.compile(r"(<b>)?expos", re.I)
re_mat_end = re.compile(r"(<i>Délibéré|Fait à .*, le)", re.I)
re_mat_st  = re.compile(r"<i>\(?(non\s?-?)?(conform|modif|suppr|nouveau)", re.I)

read = art_num = ali_num = 0
section_id = ""
article = None
section = {"type": "section", "id": ""}
for text in soup.find_all("p"):
  line = clean_html(text)
  #print read, line
  if re_mat_ppl.match(line):
    read = 0
    if not texte.has_key("done"):
      pr_js(texte)
    texte["done"] = 1
  elif re_mat_exp.match(line):
    read = -1 # Deactivate description lecture
  elif read == -1:
    continue
  # Identify section zones
  elif re_mat_sec.match(line):
    read = 1 # Activate titles lecture
    m = re_mat_sec.match(line)
    section["type_section"] = m.group(1).lower()
    section_typ = m.group(1).upper()[0]
    if not m.group(3) is None:
      section_typ += "S"
    section_num = re_cl_uno.sub("1", m.group(4).strip())
    if re.match(r"\D", m.group(4)):
      section_num = romans(section_num)
    # Get parent section id to build current section id
    section_par = re.sub(r""+section_typ+"\d.*$", "", section["id"])
    section["id"] = section_par + section_typ + str(section_num)
  # Identify titles and new article zones
  elif re.match(r"<b>", line):
    line = re_cl_html.sub("", line).strip()
    # Read a new article
    if re_mat_art.match(line):
      if not article is None:
        pr_js(article)
      read = 2 # Activate alineas lecture
      art_num += 1
      ali_num = 0
      article = {"type": "article", "num": art_num, "alineas": {}}
      m = re_mat_art.match(line)
      article["titre"] = re_cl_uno.sub("1", m.group(1).strip())
      if not m.group(2) is None:
        article["statut"] = re_cl_par.sub("", str(m.group(2)).lower()).strip()
      if not section["id"] == "":
        article["section"] = section["id"]
    # Read a section's title
    elif read == 1:
      section["titre"] = line
      if not article is None:
        pr_js(article)
        article = None
      pr_js(section)
      read = 0
  # Read articles with alineas
  elif read == 2:
    if re_mat_end.match(line):
      break
    # Find extra status information
    elif re_mat_st.match(line):
      article["statut"] = re_cl_html.sub("", re_cl_par.sub("", line.lower()).strip())
      continue
    ali_num += 1
    line = re_cl_html.sub("", line)
    article["alineas"][ali_num] = line.strip()
  else:
    #metas
    continue
pr_js(article)


