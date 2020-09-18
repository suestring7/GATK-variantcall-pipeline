import sys,os
fname=sys.argv[1]
chunk=sys.argv[2]
olist=open(fname,'r')
nlist=open(fname.split(".")[0]+"-"+chunk+".list",'w')

chunk=int(chunk)
n=-1
for line in olist:
	info=line.strip().split('-')
	last=int(info[1])
	if n==-1:
		print(info[0],end='-',file=nlist)
		n=0
	if last-n<chunk:
		continue
	else:
		print(info[1],file=nlist)
		print(info[0],end='-',file=nlist)
		n=last
if n!=last:
	print(info[1],file=nlist)
olist.close()
nlist.close()
