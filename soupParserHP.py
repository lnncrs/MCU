from bs4 import BeautifulSoup
from urllib.request import urlopen

#list imdb movies
movies = ['http://www.imdb.com/title/tt0241527/fullcredits',
          'http://www.imdb.com/title/tt0295297/fullcredits',
          'http://www.imdb.com/title/tt0304141/fullcredits',
          'http://www.imdb.com/title/tt0330373/fullcredits',
          'http://www.imdb.com/title/tt0373889/fullcredits',
          'http://www.imdb.com/title/tt0417741/fullcredits',
          'http://www.imdb.com/title/tt0926084/fullcredits',
          'http://www.imdb.com/title/tt1201607/fullcredits'
          ]

#test movie
#movies = ['http://www.imdb.com/title/tt3322312/fullcredits']

#print header
print('order,movie,year,actor,character,rank')

#iterate
for mov in movies:
    html = urlopen(mov)
    soup = BeautifulSoup(html, 'html.parser')

    morder = 0
    mtitle = ''
    myear = ''

    morder = movies.index(mov)

    mtt = soup.find('h3', {'itemprop': ['name']})
    if mtt is not None:
        mtitle = mtt.a.text.strip()
        myear = mtt.span.text.replace('(','').replace(')','').replace('–','').strip()

    # myy = soup.find('span', {'id': ['titleYear']})
    # if myy is not None:
    #     myear = myy.a.text
    # else:
    #     sep1 = 'TV Series ('
    #     sep2 = '-'
    #     myy = soup.find('a', {'title': ['See more release dates']})
    #     if myy.find(sep1) != -1:
    #         myear = myy.text[len(sep1):myy.text.find(sep2)-3]
    #     else:
    #         myear = ''

    ptb = soup.find('table', {'class': ['cast_list']})
    for ptr in ptb.find_all('tr', {'class': ['even', 'odd']}):

        line = ''
        aname = ''
        acharacter = ''
        arank = '10'
        mline = False

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
                    if ptd.div.text.find('episode') != -1:

                        arank = ptd.div.text
                        arank = arank[arank.find('episode')-5:arank.find('episode')].replace('(','').replace(')','').replace(' ','')

                        #arank = ptd.div.text.replace('(uncredited)','').replace('(archive footage)','').strip()
                        #arank = arank[arank.find('(')+1:arank.find('episodes')]
                    #else:
                        #if ptd.div.text.find('episode') != -1:
                            #arank = ptd.div.text.replace('(uncredited)','').replace('(archive footage)','').strip()
                            #arank = arank[arank.find('(')+1:arank.find('episode')]

                    mline = True
                if len(pa) > 1:
                    acharacter = pa[0].text
                    #acharacter = pa[0].text + ' / ' + pa[1].text
                    mline = True
            #if 'primary_photo' in ptd['class']:
                #line = ptd.a.img['src'] + ','
                #line += ptd.a.img['title']
        if mline:
            print(str(morder) + ',' + mtitle + ',' + myear + ',' + aname + ',' + acharacter + ',' + arank)
