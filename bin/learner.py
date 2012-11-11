#!/usr/bin/python
# -*- coding: utf-8 -*-

import re
from sklearn.svm import LinearSVC

class ComparableDiff:

  def __init__(self):
    self.alinea = 0
    self.action = ""
    self.mots = []

  def motize(self, string):
    mots = []
    for mot in re.split('[ \-\'\"]+', string):
      if mot:
        mots.append(mot)
    return mots

  def cleanMots(self):
    while len(self.motsajout) and len(self.motssupprime) and self.motsajout[0] == self.motssupprime[0]:
      del self.motsajout[0]
      del self.motssupprime[0]
    while len(self.motsajout) and len(self.motssupprime) and self.motsajout[-1] == self.motssupprime[-1]:
      del self.motsajout[-1]
      del self.motssupprime[-1]

  def loadFromString(self, string):
    splited = string.split('\t')
    self.alinea = int(splited[0])
    self.action = splited[1]
    self.motsajout = []
    self.motssupprime = []
    if (self.action == "ajout" and not splited[3]):
      self.motsajout = self.motize(splited[2])
    else:
      if (self.action == "supprime" and not splited[3]):
        self.motssupprime = self.motize(splited[2])
      else:
        self.motssupprime = self.motize(splited[2])
        self.motsajout = self.motize(splited[3])
    if (splited[4]):
      self.id = splited[4]
    else:
      raise Exception("Should provide an id")
    self.cleanMots()
    return self

  def toString(self):
    return "id:",int(self.id),"alinea:"+str(self.alinea)+",action:"+str(self.action)+",mots:"+str(self.motssupprime)+","+str(self.motsajout)

  def display(self):
    print self.toString()

  def getIdentifiant(self):
    return self.id

class ComparableCollection(list):
  def loadFromFile(self, filepath):
      file = open(filepath)
      for str in file:
          comparable = ComparableDiff()
          self.append(comparable.loadFromString(str))
      return self

class CompareDiff:
  action2distance = {"ajout": 0, "remplace": 1, "supprime": 2}

  def __init__(self, amd, diff):
    self.diff = diff
    self.amd = amd
    self.comparaison = self.__compare()

  def __compareArrayMots(self, mots1, mots2):
#    print "comparearraymots: ", mots1, mots2
    if (not len(mots1) and not len(mots2)):
      return 1.0
    if (not len(mots1) or not len(mots2)):
      return 0.0
    for taille in range(len(mots1), 0, -1):
#      print "taille:", taille
      for pos1 in range(0, len(mots1) - taille + 1):
#        print "pos1:", pos1
#        print "range(0, ", len(mots2) - taille + 1,")"
        for pos2 in range(0, len(mots2) - taille + 1):
#          print "pos2:", pos2
#          print "compareArrayMots: ", mots1[pos1:pos1+taille], mots2[pos2:pos2+taille]
          if (mots1[pos1:pos1+taille] == mots2[pos2:pos2+taille]):
#            print "VRAI", taille, pos1, pos2
            return float(taille)/len(mots1)
    return 0.0

  def __compareAlinea(self):
    return abs(self.amd.alinea - self.diff.alinea)

  def __compareAction(self):
    return abs(self.action2distance[self.amd.action] - self.action2distance[self.diff.action])

  def __compareMots(self):
    if (self.__compareAlinea() > 10):
      return 0
    return self.__compareMotsAjout() + self.__compareMotsSupprime()

  def __compareMotsAjout(self):
    if (self.__compareAlinea() > 10):
      return 0
    return self.__compareArrayMots(self.amd.motsajout, self.diff.motsajout)

  def __compareMotsSupprime(self):
    if (self.__compareAlinea() > 10):
      return 0
    return self.__compareArrayMots(self.amd.motssupprime, self.diff.motssupprime)

  def __compare(self):
    return [self.__compareAlinea(), self.__compareMotsSupprime(), self.__compareMotsAjout(), self.__compareMotsSupprime() * len(self.amd.motssupprime), self.__compareMotsAjout() * len(self.amd.motsajout)]
#, self.action2distance[self.diff1.action], self.action2distance[self.diff2.action]]

  def compare(self):
    return self.comparaison
  

class ComparableResults:

  def __init__(self, resultFilePath):
    self.correspondance = dict()
    self.loadFromFile(resultFilePath)

  def loadFromFile(self, filepath):
    file = open(filepath)
    for str in file:
      corresp = str.split(';')
      lid = corresp[0]
      try:
        self.correspondance.setdefault(int(corresp[1]), dict()).setdefault(int(lid), True)
        print corresp[1], lid, self.correspondance[int(corresp[1])][int(lid)]
      except ValueError:
        continue

  def match(self, amdDiff, pplDiff):
    try:
      return self.correspondance.get(int(amdDiff.id), dict()).get(int(pplDiff.id), False)
    except ValueError:
      return False

  def display(self):
    for amdId in self.correspondance:
      for lineid in self.correspondance[amdId]:
        print amdId, lineid

indexinit = 10

ppl = ComparableCollection().loadFromFile("tmp/article1.wdiff")
amendements = ComparableCollection().loadFromFile("tmp/amendements_adoptés.comparables.csv")
result = ComparableResults("example/correspondance_amendements_wdiff.csv")

X = []
y = []

for amd in amendements:
  print "==================================================="
  for diff in ppl:
    comp = CompareDiff(amd, diff).compare()
    if comp[0] < 15 and not comp[1:3] == [0.0, 0.0]:
      X.append(comp)
      y.append(result.match(amd, diff))
"""
    if (comp[0] < 2):
      print "amendement\t", amd.toString()
      print "diff\t\t", diff.toString()
      print "compare\t\t", comp
      if (comp == [0, 0.0, 0.0]):
        print "!!!!!!!!!!!!!!!!!"
      if 
        print "Should MATCH !!!!!!!!!!!!!", amd.id, diff.id
"""


from sklearn.linear_model import LogisticRegression
clf = LogisticRegression()
clf = clf.fit(X, y)

nb_match = 0
nb_should = 0
fauxPositifs = 0
fauxNegatifs = 0

for amd in amendements:
  print "==================================================="
  for diff in ppl:
    comp = CompareDiff(amd, diff).compare()
    predicted = False
    shouldMatch = False
    if comp[0:3] == [0, 1.0, 1.0]:
      print "(true)", comp[0:3], comp
      predicted = True
    if not predicted and clf.predict(comp)[0]:
      print "(learner)", comp
      predicted = True
    if predicted:
      print amd.id, diff.id, "match !!"
      nb_match += 1
    if result.match(amd, diff):
      shouldMatch = True
      print amd.id, diff.id, "should match"
      print comp
      nb_should += 1
    if not shouldMatch and     predicted:
      fauxPositifs += 1
      print "=== Faux positifs :( ==="
      print "np Amendement:", amd.toString()
      print "np PPL:", diff.toString()
    if     shouldMatch and not predicted:
      fauxNegatifs += 1
      print "=== Faux négatifs :( ==="
      print "np Amendement:", amd.toString()
      print "np PPL:", diff.toString()

print "resultats:", nb_match, nb_should;
print "Nb faux positifs:", fauxPositifs;
print "Nb faux négatifs:", fauxNegatifs;
