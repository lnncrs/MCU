from csv import writer

with open('eggs.csv', 'w', newline='') as csvfile:
    spamwriter = writer(csvfile, delimiter=' ', quotechar='|', quoting=QUOTE_MINIMAL)

    spamwriter.writerow(['Spam'] * 5 + ['Baked Beans'])
    spamwriter.writerow(['Spam', 'Lovely Spam', 'Wonderful Spam'])