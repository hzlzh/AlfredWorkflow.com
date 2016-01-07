# -*- coding: utf-8 -*-

import sys, os

import alfred
alfred.setDefaultEncodingUTF8()

def get_exts(ext):
    template = os.listdir('./templates/')
    modules = map(list, map(os.path.splitext, template))
    exts = list(set(zip(*modules)[1]))
    rightExt = filter(lambda x: x.find(ext)==0, exts)
    rightExt.insert(0, ext)
    rightExt = list(set(rightExt))
    return rightExt

def get_template(ext, module):
    template = os.listdir('./templates/')
    modules = map(list, map(os.path.splitext, template))
    modulesForExt = filter(lambda x: x[1]==ext, modules)
    templateForExt = map(list, zip(*modulesForExt))
    if len(templateForExt)>0:
        templateForExt = templateForExt[0]
        templateForExt.insert(0,'')
        templateForExt = filter(lambda x: x.find(module)==0, templateForExt )
        templateForExt = filter(lambda x: x!= ext.replace('.', ''), templateForExt)
    else:
        templateForExt.insert(0,'')

    return templateForExt

def get_filename_module():
    out = sys.argv[1].split(' ')
    length = len(out)
    filename = ''
    module = ''
    if length >= 1:
        filename = out[0]
    if length >=2:
        filename = ' '.join(out[0:length-1])
        module = out[length-1]
    return filename, module

def get_feedback(filename, rightExts, templateForExt):
    basename, ext = os.path.splitext(filename)
    feedback = alfred.Feedback()

    addItem = lambda titleItem: feedback.addItem(
            title   = 'Create New File: ' + titleItem,
            arg     = titleItem,
            autocomplete = titleItem,
#            subtitle = titleItem,
            )

    if (filename == '') | (filename == '!'):
        if filename == '':
            feedback.addItem(
                title   = 'Create New File',
                subtitle = 'Enter a filename and extension for your new file. Type ? for help.',
                )
        feedback.addItem(
                title   = 'Open template folder',
                subtitle = 'Edit the template files',
                arg     = '!',
                autocomplete = '!',
                icontype = 'fileicon',
                icon    = 'templates'
                )
        return feedback

    if filename == '?':
        feedback.addItem(
            title   = 'Go into Help',
            arg     = '?'
            )
        return feedback

    if len(templateForExt) == 0:
        titleItem = filename
        addItem(titleItem)
    elif (templateForExt[0] == '') & (len(templateForExt) == 1):
        for i in rightExts:
            titleItem = basename+i
            addItem(titleItem)
    else:
        for i in templateForExt:
            titleItem = filename+ ' ' + i
            addItem(titleItem)

    return feedback


def main():
    filename, module = get_filename_module()
    basename, ext = os.path.splitext(filename)

    rightExts = get_exts(ext)
    templateForExt = get_template(ext, module)

    feedback = get_feedback(filename, rightExts, templateForExt)

    feedback.output()

if __name__ == '__main__':
    main()
