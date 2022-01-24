#!/usr/bin/env python3

import sys
import argparse
import xml.etree.ElementTree as ET


class AssemblyXML():
    """NCBI Assembly XML metadata parser"""
    
    def __init__(self, xmlfile):
        with open(xmlfile) as infile:
            data = infile.read()
        # Check for proper formatting
        if not (data.startswith('<data>') and data.endswith('<\data>')):
            data = '<data>\n' + data + '\n</data>'
        self.xmltree = ET.fromstring(data)
        self.attrs = []
        self.assembly_attrs = []
    
    def get_attrs(self, attrs):
        """Extract parsed attributes from XML file.
        
        Arguments:
            attrs - a list of desired attributes.

        Return:
            all_attr_lists - the values corresponding to each item in attrs.

        """
        self.assembly_attrs = []
        self.attrs = attrs
        for assembly in self.xmltree:
            assembly = list(assembly)
            attrdict = {}
            # For each assembly, add requested attrs to list
            for element in assembly:
                if element.tag == 'FtpPath_GenBank' and element.text == None:
                    continue
                if element.tag == 'FtpPath_GenBank' and 'SpeciesGenome' in attrs:
                    if element.text == None:
                        continue
                    attrdict['SpeciesGenome'] = element.text.split('/')[-1] + '_genomic.fna'
                if element.tag in attrs:
                    if element.tag == 'SpeciesName':
                        attrdict['SpeciesName'] = element.text.replace(' ', '_')
                    else:
                        attrdict[element.tag] = element.text
            self.assembly_attrs.append(attrdict)
        return self.assembly_attrs

    def write(self, outfilename=None):
        data = []
        for attrdict in self.assembly_attrs:
            data.append([attrdict.get(key, 'NA') for key in self.attrs])
            if 'NA' in data[-1]:
                data.pop()
        data = '\n'.join(['\t'.join(line) for line in data]) + '\n'
        if outfilename:
            with open(outfilename, 'w') as outfile:
                outfile.write(data)
        else:
            sys.stdout.write(data)


def main():
    axml = AssemblyXML(sys.argv[1])
    attrs = sys.argv[2:]
    attr_list = axml.get_attrs(attrs)
    axml.write()

if __name__ == '__main__':
    main()
