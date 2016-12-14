#!/usr/bin/python3

import os, sys

if len(sys.argv) != 2:
	print('Usage: relocate.py <inputfile>')
	sys.exit(-1)

infile_name = sys.argv[1]
outfile_name = os.path.splitext(infile_name)[0]+'.rel'


if not os.path.isfile(infile_name):
	print('Error: file "', infile_name, '" not found')
	sys.exit(-1)

infile = open(infile_name, 'r')
outfile = open(outfile_name, 'w')


# Search for all relocation markers
n_rel_markers = 0

for line in infile:
	if line[0] == '&':
		# Relocation marker found
		n_rel_markers += 1

if n_rel_markers > 254:
	print('Error: too many relocation markers')
	sys.exit(-1)

# Build the relocatable assembly file
infile.seek(0)
n = 0

outfile.write('.z80\nheader:\n')
# Data region size
outfile.write('\t.dw end - data\n')
# Number of relocation markers
outfile.write('\t.db ' + str(n_rel_markers) + '\n')
# Padding
outfile.write('\t.db 00h\n')

outfile.write('header_table:\n')

# Insert relocation table
for i in range(0, n_rel_markers):
	outfile.write('\t.dw rel' + str(i) + ' + 2\n')

outfile.write('\n.org 0100h\ndata:\n')


# Replace relocation markers
for line in infile:
	if line[0] == '&':
		outfile.write(line.replace('&rel', 'rel'+str(n), 1))
		n += 1

	else:
		outfile.write(line)

outfile.write('\nend:')



infile.close()
outfile.close()
sys.exit(0)
