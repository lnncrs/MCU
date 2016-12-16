
with open('anhangabau [Nodes].csv') as fin:
    for line in fin:
        line = 'a' + line
        print(line,end="",flush=True)

with open('anhangabau [Edges].csv') as fin:
    for line in fin:
        line = 'a' + line
        line = line[:34] + 'a' + line[34:]
        print(line,end="",flush=True)



