# coding=utf8

import sys
import json


def formatPropertyName(name):
    name = name.replace('"', '')
    is_underscore = False
    formated = ''
    nameMap = ''
    for c in name:
        if c == '_':
            is_underscore = True
        else:
            if is_underscore:
                formated += c.upper()
            else:
                formated += c
            is_underscore = False
    formated = formated.replace('Url', 'URL')
    if formated == 'id':
        formated = 'ID'
    elif formated == 'description':
        formated = 'desc'
    elif formated == 'private':
        formated = 'isPrivate'
    elif formated == 'public':
        formated == 'isPublic'
    nameMap = '        @"%s": @"%s"' % (formated, name)
    return (nameMap, formated)

def detectiveType(value):
    if not value:
        return '@property (nonatomic, readonly, copy) NSString *%s;'
    if type(value) == int:
        return '@property (nonatomic, assign) NSUInteger %s;'
    elif type(value) == bool:
        return '@property (nonatomic, assign) BOOL %s;'
    elif type(value) == list:
        return '@property (nonatomic, strong) NSArray *%s;'
    elif type(value) == dict:
        return '@property (nonatomic, strong) XXX *%s;'
    elif value.startswith('http'):
        return '@property (nonatomic, readonly, strong) NSURL *%s;'
    else:
        return '@property (nonatomic, readonly, copy) NSString *%s;'

def main():
    jsonpath = sys.argv[1].strip()
    print 'jsonpath:', jsonpath
    property_output = ''
    nameMaps = []
    nameMap_output = '+ (NSDictionary *)replacedKeyFromPropertyName\n{\n    return @{'

    with open(jsonpath, 'r') as jsonfile:
        dic = json.loads(jsonfile.read())
        for name, value in dic.items():
            nameMap, name = formatPropertyName(name)
            nameMaps.append(nameMap)
            typestr = detectiveType(value)
            tmp = typestr % name
            property_output += tmp + '\n'

        nameMap_output += '\n' + ',\n'.join(nameMaps) + '\n    };\n}'
        print '\n----> property_output:\n', property_output + '\n+ (NSDictionary *)replacedKeyFromPropertyName;'
        print '\n----> nameMap_output:\n', nameMap_output

if __name__ == '__main__':
    main()
