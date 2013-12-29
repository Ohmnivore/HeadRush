#!/usr/bin/env python
#HeadRush Google App Engine master server source

import logging
import webapp2
import json
import datetime
import re
from google.appengine.ext import ndb as db
#from google.appengine.ext import deferred

ServerList = []
IPRegistry = {}
text = ''

class Server(db.Model):
    name = db.StringProperty()
    mapname = db.StringProperty()
    gamemode = db.StringProperty()
    cp = db.IntegerProperty()
    mp = db.IntegerProperty()
    passworded = db.BooleanProperty()
    address = db.StringProperty()
    timer = db.DateTimeProperty()

def Truthify(boolean):
    try:
        if boolean == True:
            return 'Yes'
        else:
            return 'No'
    except:
        return ''

class MainHandler(webapp2.RequestHandler):
    def get(self):
        global debug
        global IPRegistry, ServerList
        text = ''
        numbservers = 0
        ServerList = Server.query()
        for p in ServerList.iter():
            if (datetime.datetime.now() - p.timer).seconds < 100:
                numbservers += 1
                text += '%(name)s|%(mapname)s|%(gm)s|%(cp)d/%(mp)d|%(pass)s<BR>' % \
                {'name':p.name,'mapname':p.mapname,'gm':p.gamemode,'cp':p.cp,'mp':p.mp,'pass':Truthify(p.passworded)}
            else:
                p.key.delete()
        if len(text) == 0:
            html = '<HTML><HEAD><TITLE>HeadRush master server</TITLE></HEAD><BODY><CENTER>There are no public servers at the moment.</body></HTML>'
            self.response.write(html)
        else:
            title = 'Servers online: %(number)s<BR><a href="/ip">Click here to see the IP for each server</a>' % \
            {"number": str(numbservers)}
            html = '<HTML><HEAD><TITLE>HeadRush master server</TITLE></HEAD><BODY><CENTER>%(title)s<BR>Server name|Map name|Game mode|Current players/Max players|Password required<BR>%(text)s</CENTER></body></HTML>' % \
            {'title': title, 'text': text}

            self.response.write(html)

class IPReadHandler(webapp2.RequestHandler):
    def get(self):
        global debug
        global IPRegistry, ServerList
        text = ''
        numbservers = 0
        ServerList = Server.query()
        for p in ServerList.iter():
            if (datetime.datetime.now() - p.timer).seconds < 100:
                numbservers += 1
                text += '%(name)s|%(mapname)s|%(gm)s|%(cp)d/%(mp)d|%(pass)s|%(ip)s<BR>' % \
                {'name':p.name,'mapname':p.mapname,'gm':p.gamemode,'cp':p.cp,'mp':p.mp,'pass':Truthify(p.passworded),'ip':p.address}
            else:
                p.key.delete()
        if len(text) == 0:
            html = '<HTML><HEAD><TITLE>HeadRush master server</TITLE></HEAD><BODY><CENTER>There are no public servers at the moment.</body></HTML>'
            self.response.write(html)
        else:
            title = 'Servers online: %(number)s' % \
            {"number": str(numbservers)}
            html = '<HTML><HEAD><TITLE>HeadRush master server</TITLE></HEAD><BODY><CENTER>%(title)s<BR>Server name|Map name|Game mode|Current players/Max players|Password required|IP<BR>%(text)s</CENTER></body></HTML>' % \
            {'title': title, 'text': text}

            self.response.write(html)

class ReadHandler(webapp2.RequestHandler):
    def get(self):
        ServerList = Server.query()
        if ServerList.count(limit=1) == 0:
            self.response.write('')
        else:
            servers = []
            for x in ServerList.iter():
                if (datetime.datetime.now() - x.timer).seconds < 100:
                    server = [x.name,x.mapname,x.gamemode,x.cp,x.mp,Truthify(x.passworded),x.address]
                    servers.append(server)
                else:
                    x.key.delete()
            self.response.write(json.dumps(servers))

class ServerHandler(webapp2.RequestHandler):
    def post(self):
        ip = self.request.remote_addr
        cmd = self.request.get('cmd')
        duplicate = False
        logging.info(cmd)
        logging.info(self.request.get('info'))
        if cmd == '+':
            for server in Server.query().iter():
                if server.address == ip:
                    duplicate = True
                    server.timer = datetime.datetime.now()
            if duplicate == False:
                #try:
                x = json.loads(self.request.get('info'))
                x.append(ip)
                x[0] = re.sub(r'[^\w]', '', x[0])
                x[1] = re.sub(r'[^\w]', '', x[1])
                x[2] = re.sub(r'[^\w]', '', x[2])
                if x[3] <= 100 and x[4] <= 100 and (x[5] == True or x[5] == False) and len(x[0]) <= 20 and len(x[1]) <= 20 and len(x[2]) <= 20:
                    serverx = Server()
                    # serverx.name, serverx.mapname, serverx.gamemode, serverx.cp, serverx.mp, serverx.passworded, serverx.address = x
                    serverx.name = x[0]
                    serverx.mapname = x[1]
                    serverx.gamemode = x[2]
                    serverx.cp = x[3]
                    serverx.mp = x[4]
                    serverx.passworded = x[5]
                    serverx.address = ip
                    serverx.timer = datetime.datetime.now()
                    serverx.put()
                #except:
                #    pass
        if cmd == '-':
            query = Server.gql("WHERE address = :1", ip)
            #server = IPRegistry[ip].get()
            server = query.get()
            server.delete()
        if cmd == 'p':
            query = Server.gql("WHERE address = :1", ip)
            server = query.get()
            pstats = json.loads(self.request.get('info'))
            server.cp = int(pstats[0])
            server.mp = int(pstats[1])
            server.put()
        #if cmd == '+p':
        #    query = Server.gql("WHERE address = :1", ip)
        #    server = query.get()
        #    #server = IPRegistry[ip].get()
        #    server.cp += 1
        #    server.put()
        #if cmd == '-p':
        #    query = Server.gql("WHERE address = :1", ip)
        #    #server = IPRegistry[ip].get()
        #    server = query.get()
        #    server.cp -= 1
        #    server.put()
        if cmd == 'm':
            query = Server.gql("WHERE address = :1", ip)
            server = query.get()
            if len(re.sub(r'[^\w]', '', self.request.get('info'))) <= 20:
                server.mapname = re.sub(r'[^\w]', '', self.request.get('info'))
            server.put()
        if cmd == 'g':
            query = Server.gql("WHERE address = :1", ip)
            server = query.get()
            if len(re.sub(r'[^\w]', '', self.request.get('info'))) <= 20:
                server.gamemode = re.sub(r'[^\w]', '', self.request.get('info'))
            server.put()
        if cmd == 'h':
            query = Server.gql("WHERE address = :1", ip)
            server = query.get()
            server.timer = datetime.datetime.now()
            server.put()


app = webapp2.WSGIApplication([
    ('/', MainHandler),
    ('/read', ReadHandler),
    ('/server', ServerHandler),
    ('/ip', IPReadHandler)
]) #, debug=True])