from __future__ import print_function
import sys
import re
import numpy

Fasta = open(sys.argv[1],'r')
out = int(sys.argv[2]) # 0 for Ns, 1 for intervals
Ns=0
Nlen=0
stat=0
now=0
nchr=0
fnow=open("tmp.txt",'w')
if out==0:
	while True:
		c = Fasta.read(1)
		if not c:
			if stat == 0:
				print("-"+str(now),file=fnow)
			#print("Scanned "+str(now) +"bp sequence with "+str(Ns)+" Ns detected.")
			fnow.close()
			break
		if c == ">":
			L = Fasta.readline().strip()
			print("-"+str(now),file=fnow)
			#if nchr!=0:
			#	print("Scanned "+str(now) +"bp sequence with "+str(Ns)+" Ns detected.")
			#print(L)
			now=0
			Ns=0
			Nlen=0
			stat=0
			nchr=nchr+1
			fnow.close()
			fnow=open("chr"+str(nchr)+".list",'w')
			print(L+":1",end='',file=fnow)
			continue
		if c == "N":
			now = now + 1
			Nlen = Nlen + 1
			if stat == 0:
				stat = 1
				Ns = Ns + 1
				print("-"+str(now),file=fnow)
			else:
				continue
		elif c == "\n":
			continue
		else:
			now = now + 1
			if stat == 0:
				continue
			if stat == 1:
				stat = 0
				print(L+":"+str(now),end='',file=fnow)
				Nlen = 0
elif out==1:
	while True:
		c = Fasta.read(1)
		if not c:
		#	if stat == 1:
		#		print(str(now))
			print("-"+str(now))
			break
		if c == ">":
			L = Fasta.readline()
			if nchr!=0:
				print("Scanned "+str(now) +"bp sequence with "+str(Ns)+" Ns detected.")
			print(L)
			print("0",end='')
			now=0
			Ns=0
			Nlen=0
			stat=0
			nchr=nchr+1
			continue
		if c == "N":
			now = now + 1
			Nlen = Nlen + 1
			if stat == 0:
				stat = 1
				Ns = Ns + 1
				print("-"+str(now))
			else:
				continue
		elif c == "\n":
			continue
		else:
			now = now + 1
			if stat == 0:
				continue
			if stat == 1:
				stat = 0
				print(str(now),end='')
				Nlen = 0
