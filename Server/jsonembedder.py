import json, os, sys

parentdir = os.path.dirname(os.path.abspath(sys.argv[0]))
sys.path.insert(0,parentdir)
mypath = os.path.normpath(os.path.dirname(os.path.abspath(sys.argv[0])))

lvls = {}

def FetchLvls():
    # x = 0
    for lvl in os.listdir(os.path.join(mypath, 'src', 'lvls')):
        for file in os.listdir(os.path.join(mypath, 'src', 'lvls', lvl)):
            # container = ""
            if len(open(os.path.join(mypath, 'src', 'lvls', lvl, file), 'r').read()) > 0:
                if os.path.basename(file)[-3:] == '.hr':
                    print "k"
                    lvl = json.loads(open(os.path.join(mypath, 'src', 'lvls', lvl, file), 'r').read())
                    # container = open(os.path.join(mypath, 'src', 'lvls', lvl, file), 'r').read()#.replace('\n', ''))
                    lvls[lvl[0]["name"]] = lvl
                    # x += 1
                    # print open(os.path.join(mypath, 'src', 'lvls', lvl, file), 'r').read()
                    # print dicttoxml.dicttoxml(lvls)

FetchLvls()

#Finish, and write to file
json.dump(lvls, open(os.path.join(mypath, 'src', 'jsonembedded.txt'), 'w'))
print 'Succeeded!'