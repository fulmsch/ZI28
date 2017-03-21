#!/usr/bin/python3

import yaml, os, sys, getopt

def main(argv):
	helpmsg = 'Usage: zi28doc.py -i <inputfile>'
	infile_name = ''
	outfile_name = ''
	index_name = ''
	try:
		opts, args = getopt.getopt(argv, "hi:o:x:")
	except getopt.GetoptError:
		print(helpmsg)
		sys.exit(-1)
	for opt, arg in opts:
		if opt == '-h':
			print(helpmsg)
			sys.exit(0)
		elif opt == '-i':
			infile_name = arg
		elif opt == '-o':
			outfile_name = arg
		elif opt == '-x':
			index_name = arg
	
	if infile_name == '':
		infile = sys.stdin
	elif os.path.isfile(infile_name):
		infile = open(infile_name, 'r')
	else:
		print('Error: file "' + infile_name + '" not found')
		sys.exit(-1)

	if outfile_name == '':
		outfile = sys.stdout
	else:
		outfile = open(outfile_name, 'w+')

	index = {'files':[],'routines':[]}
	if not index_name == '':
		if os.path.isfile(index_name):
			index_file = open(index_name, 'r')
			lines = index_file.readlines()[1:-1]
			lines = ''.join(lines)
			index = yaml.load(lines)
			index_file.close()
			if not ('files' in index and 'routines' in index):
				print('Error: file "' + index_name + '" is invalid')
				sys.exit(-1)

		index_file = open(index_name, 'w+')


	lines = infile.readlines()
	name = infile.name
	sdesc = ''
	desc = ''
	n = 0
	for line in lines:
		if line[:2] == ';;':
			if n == 0:
				sdesc = line.lstrip('; ')
			desc = desc + line.lstrip('; ')
			n = n + 1
		else:
			break

	if n > 0:
		#File contains a description and should be added to the documentation

		#Append the filename and short description to index
		entry = {'name':name, 'desc':sdesc}
		if entry not in index['files']:
			index['files'].append(entry)

		file_index = {'name':name, 'desc':desc, 'routines':[]}
		del lines[:n]

		#Finde routines
		i = 0
		while i < len(lines):
			if lines[i][:2] == ';;':
				desc = ''
				sdesc = lines[i].lstrip('; ')
				name = lines[i-1].strip(': \n')
				name = name.split()[-1]
				#entry = {'name':name, 'desc': []}
				while True:
					if lines[i][:2] == ';;':
						desc = desc + lines[i].lstrip('; ')
						i = i+1
					else:
						break
				entry = {'name':name, 'file':infile.name, 'sdesc':sdesc}
				if entry not in index['routines']:
					index['routines'].append(entry)

				entry = {'name':name, 'sdesc':sdesc, 'desc':desc}
				if entry not in file_index['routines']:
					file_index['routines'].append(entry)
			i = i + 1
		outfile.write('---\n' + yaml.dump(file_index, indent=4) + '---')

	if 'index_file' in locals():
		index_file.write('---\n' + yaml.dump(index, indent=4) + '---')


if __name__ == "__main__":
	main(sys.argv[1:])
