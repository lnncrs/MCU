from bs4 import BeautifulSoup
from urllib.request import urlopen

#list imdb movies
movies = ['http://www.imdb.com/title/tt0371746/', #iron man
          'http://www.imdb.com/title/tt0800080/', #hulk
          'http://www.imdb.com/title/tt1228705/', #iron man 2
          'http://www.imdb.com/title/tt0800369/', #thor
          'http://www.imdb.com/title/tt0458339/', #captain america
          'http://www.imdb.com/title/tt0848228/', #avengers
          'http://www.imdb.com/title/tt1300854/', #iron man 3
          'http://www.imdb.com/title/tt2364582/', #shield
          'http://www.imdb.com/title/tt1981115/', #thor 2
          'http://www.imdb.com/title/tt1843866/', #captain america 2
          'http://www.imdb.com/title/tt2015381/', #GoG
          'http://www.imdb.com/title/tt3475734/', #agent carter
          'http://www.imdb.com/title/tt3322312/', #daredevil
          'http://www.imdb.com/title/tt2395427/', #avengers 2
          'http://www.imdb.com/title/tt0478970/', #ant man
          'http://www.imdb.com/title/tt2357547/', #jessica jones
          'http://www.imdb.com/title/tt3498820/', #captain america 3
          'http://www.imdb.com/title/tt1211837/'  #doctor strange
          ]

#test movie
#movies = ['http://www.imdb.com/title/tt2364582/']

#print header
print('order,movie,year,actor,character')

#iterate
for mov in movies:
    html = urlopen(mov)
    soup = BeautifulSoup(html, 'html.parser')

    morder = 0
    mtitle = ''
    myear = ''

    morder = movies.index(mov)

    mtt = soup.find('div', {'class': ['originalTitle']})
    if mtt is not None:
        mtitle = mtt.text.replace(' (original title)', '')
    else:
        mtt = soup.find('div', {'class': ['title_wrapper']})
        mtitle = mtt.h1.text.split('(', 1)[0].strip()

    myy = soup.find('span', {'id': ['titleYear']})
    if myy is not None:
        myear = myy.a.text
    else:
        sep1 = 'TV Series ('
        sep2 = '-'
        myy = soup.find('a', {'title': ['See more release dates']})
        if myy.find(sep1) != -1:
            myear = myy.text[len(sep1):myy.text.find(sep2)-3]
        else:
            myear = ''

    ptb = soup.find('table', {'class': ['cast_list']})
    for ptr in ptb.find_all('tr', {'class': ['even', 'odd']}):

        line = ''
        aname = ''
        acharacter = ''

        for ptd in ptr.find_all('td'):
            if 'itemprop' in ptd['class']:
                if ptd.a.span.text != '':
                    aname = ptd.a.span.text
            if 'character' in ptd['class']:
                pa = ptd.div.find_all('a')
                if len(pa) == 0:
                    acharacter = ' '.join(ptd.div.text.split())
                if len(pa) == 1:
                    acharacter = pa[0].text
                if len(pa) > 1:
                    acharacter = pa[0].text + ' / ' + pa[1].text
            #if 'primary_photo' in ptd['class']:
                #line = ptd.a.img['src'] + ','
                #line += ptd.a.img['title']

        print(str(morder) + ',' + mtitle + ',' + myear + ',' + aname + ',' + acharacter)
