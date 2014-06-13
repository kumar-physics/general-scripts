#!/usr/bin/env python

import sys
import time
import os
import requests
from requests.exceptions import HTTPError
from HTMLParser import HTMLParser
from urlparse import urljoin
from pyquery import PyQuery as pq
import re


class FormParser(HTMLParser,object):
    def __init__(self):
        super(FormParser,self).__init__()
        self.inputs = {}
        self.action = ""
    def handle_starttag(self, tag, attrs):
        if tag == "input":
            #print "found input: "+repr(attrs)[:500]
            name = None
            value = None
            for k,v in attrs:
                if k == "name":
                    name = v
                elif k == "value":
                    value = v
            if name is not None:
                self.inputs[name] = value
        if tag == "form":
            for k,v in attrs:
                if k == "id":
                    if v != "aspnetForm":
                        print "ERROR: unknown form detected: "+v
                        break
                elif k == "action":
                    self.action = v

class Page(object):
    """Represents an file fetchable online. The file is cached locally.

    This is an abstract class. Subclasses should implement _request(session)
    """

    delay = 3
    _lastFetchTime = 0 # time of last actual fetch, from time.time()
    @classmethod
    def sleepPolitely(cls):
        """Sleep until a polite amount of time has passed since the last fetch.

        Use to throttle requests to a server
        """
        #wait for delay seconds to have passed.
        #not thread-safe
        while time.time()-Page._lastFetchTime < Page.delay:
            time.sleep( time.time()-Page._lastFetchTime + .1)


    def __init__(self, filename,url,parent=None):
        # parameters to load the Cluster
        self.filename=filename

        # parent page which must be fetched before this one
        self.parent=parent

        self.hasFetched=False

        self.text = None
        self.url = url

    def getPayload(self):
        if self.parent is not None:
            return dict(self.parent.getPayload())
        else:
            return dict()

    def _request(self,session):
        "returns a http request object. Should have streaming enabled."
        raise NotImplementedError()

    def fetch(self,session):
        """downloads the html file by submitting a get request to the given URL
        """
        if session is None: raise ValueError("Invalid session")

        # fetch parent
        if self.parent is not None and not self.parent.hasFetched:
            self.parent.fetch(session)

        # throttle requests
        Page.sleepPolitely()

        global r #for debugging
        r = self._request(session)
        Page._lastFetchTime = time.time()
        r.raise_for_status()

        bufferlen = 16*1024

        # set text property for small or textual files
        if 'text' in r.headers.get('content-type','text').lower() or \
                int(r.headers.get('content-length', -1)) < bufferlen or \
                r.encoding in ["utf-8","txt","text","latin1"]:
            self.text = r.text
        #write to file
        with open(self.filename,'wb') as file:
            # read content in 8k chunks
            try:
                for content in r.iter_content(bufferlen):
                    file.write(content)
            #except (IOError,KeyboardInterrupt) as e:
            except:
                print "Interrupted while writing "+self.filename
                # try to clean up file after errors
                try:
                    os.remove(self.filename)
                except:
                    pass
                raise sys.exc_info()[0]
        Page._lastFetchTime = time.time()

        self.hasFetched = True
        self.url = r.url

    def isCached(self):
        return os.path.isfile(self.filename) and \
            os.stat(self.filename).st_size > 0

    def load(self,session=None):
        """Loads the html file from cache or fetches it fresh
        """
        if self.isCached():
            with open(self.filename,'r') as file:
                self.text = file.read()
        else:
            self.fetch(session)

class HTMLPage(Page):

    def __init__(self, filename,url,parent=None):
        super(HTMLPage,self).__init__(filename,url,parent)


    def _request(self,session):
        global r #for debugging
        print "GET %s"%(self.url)
        r = session.post(self.url,stream=True)
        return r

class StatsPage(HTMLPage):

    def __init__(self, filename,url,parent=None):
        super(StatsPage,self).__init__(filename,url,parent)

        self.parser = None
        self.groups = None

    def getPayload(self):
        payload = super(StatsPage,self).getPayload()
        if self.parser is not None:
            payload.update(self.parser.inputs)
        return payload

    def fetch(self,session):
        super(StatsPage,self).fetch(session)
        #parse groups
        self.parse(session)


    def parse(self,session=None):
        """Parse this page and get an array of groups

        return a tuple containing the form url, a dict of hidden values, and
        the array of Group objects
        """
        if self.text is None:
            self.load(session)

        self.parser = FormParser()
        self.parser.feed(self.text)

        self.url = urljoin(self.url,self.parser.action)
        self.groups = StatsPage._parseStatDetailsForGroups(self.text)

        print "Payload parsed from stats page:"
        print pad(str_truncated(self.parser.inputs),4)
        return self.groups

    def getAllGroups(self,session=None):
        """Parse this page and get an array of groups

        return a tuple containing the form url, a dict of hidden values, and
        the array of Group objects
        """
        if self.groups is not None:
            return self.groups
        else:
            return self.parse(session)
 
    @staticmethod
    def _parseStatDetailsForGroups(html):
        pquery = pq(html)

        groups = []
        hrefRE = re.compile("javascript: *__doPostBack *\( *"
                "['\"]([^'\"]*)['\"] *, *['\"]([^'\"]*)['\"] *\)")
        for row in pquery("#ctl00_MainContent_StatDetailGridView tr")[1:]:
            td = row.find("td[1]")
            a = td.find("a")
            pfam = a.text.strip()
            href = a.get("href")
            match = hrefRE.match(href)
            target,argument = match.groups()

            if len(groups)==0 or groups[-1].name != pfam:
                groups.append( Group(pfam,target,argument) )
        return groups


class ASPPage(Page):
    """Represents an file fetchable through an ASP session

    The file is cached locally.
    """

    def __init__(self, filename,posturl,eventtarget,eventargument,parent=None):
        super(ASPPage,self).__init__(filename,None,parent)

        # parameters to load the Cluster
        self.posturl=posturl
        self.eventtarget=eventtarget
        self.eventargument=eventargument

    def getPayload(self):
        payload = super(ASPPage,self).getPayload()
        payload['__EVENTTARGET'] = self.eventtarget
        payload['__EVENTARGUMENT'] = self.eventargument
        return payload

    def _request(self,session):
        payload = self.getPayload()

        print "POST %s target='%s' arg='%s'"%(self.posturl,self.eventtarget,self.eventargument)
        print str_truncated(payload)
        r = session.post(self.posturl,data=payload,stream=True)
        return r


class ClusterPage(ASPPage):
    def __init__(self, filename,posturl,eventtarget,eventargument,parent=None):
        super(ClusterPage,self).__init__(filename,posturl,eventtarget,eventargument,parent)
        self.parser = None
        self.clusters = None

    def getPayload(self):
        payload = super(ClusterPage,self).getPayload()
        if self.parser is not None:
            payload.update(self.parser.inputs)
        return payload

    def fetch(self,session):
        super(ClusterPage,self).fetch(session)
        #parse groups
        self.parse(session)

    def getClusterInterfaces(self,filename,cluster,session=None):
        if self.url is None:
            self.fetch(session)
        url = urljoin(self.url, self.parser.action)
        return ASPPage(filename, url,
                cluster.eventtarget,cluster.eventargument, self)

    def parse(self,session):
        self.parser = FormParser()
        self.parser.feed(self.text)

    def getClusterTable(self,session,filename):
        """Get an ASPPage representing the cluster table, to be cached at `filename`
        """
        if self.text is None or self.url is None:
            self.fetch(session)

        if self.parser is None:
            self.parse(session)

        clusterurl = urljoin(self.url,self.parser.action)

        table = ASPPage(filename,clusterurl,'ctl00$MainContent$LinkClusterData','',  self)

        return table

    def getAllClusters(self,session=None):
        """Parse this page and get an array of Cluster objects
        """
        # check for cached results
        if self.clusters is not None:
            return self.clusters

        if self.text is None:
            self.load(session)

        pquery = pq(self.text)


        hrefRE = re.compile("javascript: *__doPostBack *\( *"
                "['\"]([^'\"]*)['\"] *, *['\"]([^'\"]*)['\"] *\)")
        spanRE = re.compile("(\d+) \((\d+\.\d+|\d+)\)")

        #for row in pquery("#ctl00_MainContent_StatDetailGridView tr")[1:]:

        col2 = pquery("#ctl00_MainContent_HGridView a[id$='_LinkCluster']")
        col3 = pquery("#ctl00_MainContent_HGridView span[id$='_LabelCF']")
        col4 = pquery("#ctl00_MainContent_HGridView span[id$='_LabelEntry']")
        col5 = pquery("#ctl00_MainContent_HGridView span[id$='_LabelPdb']")
        col6 = pquery("#ctl00_MainContent_HGridView span[id$='_LabelPisa']")
        col7 = pquery("#ctl00_MainContent_HGridView span[id$='_LabelAsu']")
        col8 = pquery("#ctl00_MainContent_HGridView span[id$='_LabelType']")
        col9 = pquery("#ctl00_MainContent_HGridView span[id$='_LabelMinSeqId']")
        col10 = pquery("#ctl00_MainContent_HGridView span[id$='_LabelSa']")

        #Crystal Form (CF) containing Arch = 50; #PDB containing Arch = 80.
        caption = pquery("#ctl00_MainContent_HGridView caption div")[0].text
        totalCF, totalEntries = re.findall("Arch\s*=\s*(\d+)",caption)



        self.clusters = []
        for link, cfs, entries, pdbBA, pisaBA, asu, interfaceTypes, minSeqId, sa in zip(
                col2, col3, col4, col5, col6, col7, col8, col9, col10 ):
            clusterNum = link.text.strip()

            href = link.get("href")
            match = hrefRE.match(href)
            target,argument = match.groups()

            match = spanRE.match(cfs.text)
            numCF, pCF = match.groups()
            numCF = int(numCF)
            pCF = float(pCF)

            numEntries = int(entries.text)

            match = spanRE.match(pdbBA.text)
            numPdbBA, pPdbBA = match.groups()
            numPdbBA = int(numPdbBA)
            pPdbBA = float(pPdbBA)

            match = spanRE.match(pisaBA.text)
            numPisaBA, pPisaBA = match.groups()
            numPisaBA = int(numPisaBA)
            pPisaBA = float(pPisaBA)

            match = spanRE.match(asu.text)
            numAsu, pAsu = match.groups()
            numAsu = int(numAsu)
            pAsu = float(pAsu)

            alltypes = interfaceTypes.text.strip().split(",")

            seqId = float(minSeqId.text)

            area = float(sa.text) #seems to be an int

            self.clusters.append( Cluster(clusterNum, numCF, totalCF,
                numEntries, totalEntries, numPdbBA, numPisaBA,
                numAsu, alltypes, seqId, area, target, argument) )

        return self.clusters

    def writeClustersTSV(self,filename,session=None):
        """Write clusters to a TSV file
        """
        with open(filename,'w') as file:
            clusters = self.getAllClusters()
            file.write(Cluster.header())
            file.write("\n")
            for cluster in clusters:
                file.write(str(cluster))
                file.write("\n")


## Data model classes
class Cluster(object):
    def __init__(self,clusterNum,cfs,totalCFs,entries,totalEntries,
            pdbBA,pisaBA,asu,interfaceTypes,minSeqID,surfaceArea,
            eventtarget,eventargument):
        self.clusterNum = int(clusterNum)
        self.cfs = int(cfs)
        self.totalCFs = int(totalCFs)
        self.entries = int(entries)
        self.totalEntries = int(totalEntries)
        self.pdbBA = int(pdbBA)
        self.pisaBA = int(pisaBA)
        self.asu = int(asu)
        self.interfaceTypes = interfaceTypes
        self.minSeqID = float(minSeqID)
        self.surfaceArea = float(surfaceArea)
        self.eventtarget = eventtarget
        self.eventargument = eventargument
    def __repr__(self):
        return "Cluster(%s)" % ", ".join([repr(x) for x in (
            self.clusterNum, self.cfs, self.totalCFs, self.entries,
            self.totalEntries, self.pdbBA, self.pisaBA, self.asu,
            self.interfaceTypes, self.minSeqID, self.surfaceArea,
            self.eventtarget, self.eventargument)] )
    @classmethod
    def header(cls):
        return "Cluster#\t#CFs\t#Entries\t#PDBBA\t#PISABA\t#ASU\tType\tMinSeqID\tSurfaceArea"
    def __str__(self):
        "Replicate the HTML table in TSV format"
        return "{self.clusterNum}\t{self.cfs} ({pCFs})\t" \
                "{self.entries}\t{self.pdbBA} ({pPDB})\t" \
                "{self.pisaBA} ({pPisa})\t{self.asu} ({pASU})\t{interfaceTypes}\t" \
                "{self.minSeqID}\t{self.surfaceArea}" \
                .format(self=self,
                        pCFs=   float(self.cfs) /self.totalCFs,
                        pPDB=   float(self.pdbBA) /self.totalEntries,
                        pPisa=  float(self.pisaBA) /self.totalEntries,
                        pASU=   float(self.asu) /self.totalEntries,
                        interfaceTypes=",".join(self.interfaceTypes) )

class Group(object):
    "A ProtCid group"
    def __init__(self,name,eventtarget,eventargument):
        """name: Pfam architecture, e.g. '(PALP)'
        eventtarget,eventargument: arguments for the post callback
        """
        self.name = name
        self.eventtarget = eventtarget
        self.eventargument = eventargument

    def __repr__(self):
        return "Group('%s', '%s', '%s')" % (self.name, self.eventtarget, self.eventargument)

def str_truncated(dictionary,width=80):
    lines = [("%s: %s"%(k,v))[:(width+1)] for k,v in dictionary.items() ]
    lines = [ line[:(width-3)]+"..." if len(line)>width else line for line in lines]
    return "\n".join(lines)

def pad(str,spaces):
    return "\n".join([" "*spaces + line for line in str.split("\n")])

def main():
    global session

    Page.delay = 3

    minCFs = 5
    minPercentCFs = 0

    for grouptype in [ "single", "pair" ]:
        root = 'http://dunbrack2.fccc.edu/ProtCiD'
        url = "%s/Statistics/StatDetails.aspx?M=%d&SeqId=90&Type=%s"%(root,minCFs,grouptype)
        statFilename = "clusters/%s-%d.html"%(grouptype,minCFs)


        try:
            session
        except NameError:
            session = requests.Session()

        # Fetch the list of clusters
        statsPage = StatsPage(statFilename,url)
        try:
            groups = statsPage.getAllGroups(session)
        except HTTPError as e:
            print "ERROR downloading statistics: %s"%(e)
            return

        for group in groups:
            groupNum = int(group.eventargument.split('$')[1])
            if groupNum < 215:
                #continue
                pass
            # for each cluster, store
            # - the html file for further parsing
            # - The interface table (.txt.gz)
            # - a text form of the html main table
            # - interface files for all clusters with >=5 CFs (eg 18000_1.tar.gz)
            dirname = "clusters/%s" % group.name
            clusterhtmlfilename = "%s/%s.html" % (dirname,group.name)
            clustertablefilename = "%s/%s.txt.gz" % (dirname,group.name)
            clusterTextFilename = "%s/%s.tsv" % (dirname,group.name)

            # create directory
            if not os.path.exists(dirname):
                try:
                    os.makedirs(dirname)
                except os.error:
                    print "ERROR creating "+dirname
                    continue

            # Set up ASPPage for this cluster
            clusterHTML = ClusterPage(clusterhtmlfilename,statsPage.url,group.eventtarget, group.eventargument, statsPage)
            if clusterHTML.isCached():
                print "HIT "+clusterhtmlfilename
            else:
                print "FETCH "+clusterhtmlfilename
            try:
                clusterHTML.load(session)
                #clusterHTML.fetch(session)
            except HTTPError as e:
                print "ERROR FETCHING %s: %s"%(clustertablefilename,e)
                continue

            # set url manually, since otherwise it requires a fetch to compute
            if clusterHTML.url is None:
                clusterHTML.url = "http://dunbrack2.fccc.edu/ProtCid/ClusterInfo.aspx?DomainLevel=false"


            # Save the page in TSV form
            if not os.path.exists(clusterTextFilename):
                clusterHTML.writeClustersTSV(clusterTextFilename)

            # Download the full table
            clusterTable = clusterHTML.getClusterTable(session,clustertablefilename)
            if clusterTable.isCached():
                print "HIT "+clustertablefilename
            else:
                print "FETCH "+clustertablefilename
                try:
                    clusterTable.load(session)
                except HTTPError as e:
                    print "ERROR FETCHING %s: %s"%(clustertablefilename,e)
                    continue

            # Download relevant cluster interfaces

            try:
                for cluster in clusterHTML.getAllClusters(session):
                    numCFs = cluster.cfs
                    pCFs = float(cluster.cfs)/cluster.totalCFs

                    if numCFs >= minCFs and pCFs >= minPercentCFs:
                        #download this cluster
                        pdbFilename = "%s/%s_%d.tar.gz" % (dirname,group.name,cluster.clusterNum)
                        pdbFile = clusterHTML.getClusterInterfaces(pdbFilename,cluster,session)

                        if pdbFile.isCached():
                            print "HIT "+pdbFilename
                        else:
                            print "FETCH "+pdbFilename
                            pdbFile.load(session)

            except HTTPError as e:
                print "ERROR FETCHING %s: %s"%(pdbFilename,e)
                # force refetch
                statsPage.hasFetched = False

            # force refetch
            #statsPage.hasFetched = False
        print "DONE with %s-%d" % (grouptype,minCFs)
    print ("DONE")


if __name__ == "__main__":
    main()

    #html = open('ProtCid_StatDetails.html','r').read()
    #groups = parseStatDetailsForGroups(html)
    #for group in groups:
    #    print( "%s\t%s"%(group.name,group.eventargument) )
    #clusterPage = ClusterPage('ProtCid_Clusters.html',None,None,None)
    #clusterPage.writeClustersTSV('ProtCid_Clusters.tsv')
    #clusters = clusterPage.getAllClusters()
    #for cluster in clusters:
    #    print cluster

