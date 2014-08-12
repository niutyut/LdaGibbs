# csvToLatex
# takes a csv file and outputs a table for Latex. 

import os
import csv

inBase = raw_input("Please enter the base name of your csv file (don't include the path): -------> ")
inPath = raw_input("Please enter the path to the directory where the file lives: -----> ")
inFN = '/'.join(inBase, inPath)
outBase = inFN.split(".")[0] + "Latex" + ".txt"
outPath = raw_input("Please enter the path to the directory where you'd like the latex table to go: ------> ")
outFN = '/'.join([outPath, outBase])
title = raw_input("What is the title of your latex table? --------> ")

# Latex for beginning table environment
tableIntro = ['\\begin{table}[htdp] \n', '\\caption{' + title + '} \n', '\\begin{center} \n']
# Latex for ending table environment
tableOutro = ['\\end{tabular} \n', '\\end{center} \n', '\\label{default} \n', '\\end{table} \n']

def csvRowToLatex(row):
    return " & ".join(row) + r" \\"  +"\n"

def getRowInst(first):
    colForm = r'||'
    numCols = len(first)
    i = 0
    while i < numCols:
        colForm += r'c|'
        i += 1
    return colForm + r'}' + '\n'

inFile = open(inFN, 'rb')
reader = csv.reader(inFile)
outFile = open(outFN, 'w')
first = reader.next()
tableIntro.append(r'\begin{tabular}{' + getRowInst(first) + '\n')
for line in tableIntro:
    outFile.write(line)
outFile.write(csvRowToLatex(first))
for row in reader:
    outFile.write(csvRowToLatex(row))
outFile.write('\n')
for line in tableOutro:
    outFile.write(line)
outFile.close()




        
        
            
    

    
