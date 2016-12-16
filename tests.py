line = 'Matt Murdock         // ...                    (26 episodes, 2015-2016'
sep1 = 'episode'
sep2 = '('


if line.find(sep1) != -1:

    print(line[line.find(sep1)-5:line.find(sep1)].replace('(','').replace(')','').replace(' ',''))
    #line = line[line.find(sep2)+1:line.find(sep1)]
    print(line)


exit()
