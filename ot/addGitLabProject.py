import json
import requests
import argparse
import os
import time
import sys
import logging
import urllib3
from pprint import pformat
import gitlablib as gitlablib
from gitlablib import * 
from logginglib import *

def addICtails(reposPath):
    if reposPath.endswith(os.sep):
        reposPath = reposPath[:-1]
    if reposPath.startswith(os.sep):
        reposPath = reposPath[1:]

    # Add -ic to group name
    reposSubPath, reposGroup = os.path.split(reposPath)
    reposGroup = reposGroup + '-ic'

    # Add -ic to area name
    reposSubPath, reposArea = os.path.split(reposSubPath)
    reposArea = reposArea + '-ic'

    reposSubPath, reposLang = os.path.split(reposSubPath)
    if ((reposLang is None) or (reposLang.strip() == '') or (reposLang.strip() == os.sep)):
        raise Exception('Invalid programming language name. Remaining subpath: {0}'.format(reposSubPath))

    if ((not (reposSubPath is None)) and (reposSubPath.strip() != '') and (reposSubPath.strip() != os.sep)):
        raise Exception('Invalid repository subpath. Repository language: {0}'.format(reposLang))

    reposSubPathOut = os.path.join(reposGroup, reposSubPath)
    reposSubPathOut = os.path.join(reposArea, reposSubPathOut)
    reposSubPathOut = os.path.join(reposLang, reposSubPathOut)
    
    return reposSubPathOut

def createIcProjectBranches(projectIC, args):
    # en IC
    # createProjectBranch(projectIC, 'master', 'hotfix', args)
    createProjectBranch(projectIC, 'master', 'release-candidate', args)
    createProjectBranch(projectIC, 'release-candidate', 'integracion', args)

    protectBranch(projectIC, 'release-candidate', args)
    protectBranch(projectIC, 'integracion', args)

def createProjectBranches(project, args):
    # en fork
    createProjectBranch(project, 'integracion', 'developer', args)
    createProjectBranch(project, 'integracion', 'developer-hotfix', args)

    protectBranch(project, 'release-candidate', args)
    protectBranch(project, 'integracion', args)
    protectBranch(project, 'developer', args)
    protectBranch(project, 'developer-hotfix', args)

def main():
    parser = argparse.ArgumentParser(description='Adds a project to GitLab.')
#    parser.add_argument('integers', metavar='N', type=int, nargs='+',
#                        help='an integer for the accumulator')
    parser.add_argument('--gitlab', dest='gitlabServer', action='store',
                        help='GitLab url. Ex: https://des-gitlab.scae.redsara.es ',
                        default='https://des-gitlab.scae.redsara.es')
    parser.add_argument('--gitlabPrivateToken', dest='gitlabPrivateToken', action='store',
                        help='GitLab private token. Example: wsVbcc9GSzCudwiTg-sG',
                        default='wsVbcc9GSzCudwiTg-sG')
    parser.add_argument('--gitlabQueryHeaders', dest='gitlabQueryHeaders', action='store',
                        help='GitLab query headers.',
                        default={})
    parser.add_argument('--repoFullPath', dest='repoFullPath', required=True,
                        help='Full path to the repository. Example: JAVA/SIM/sim_J2_0040/sim')
    parser.add_argument('--enableSSLwarnings', dest='enableSSLwarnings', type=bool, 
                        help='Enables SSL warnings.')
    parser.print_help()
    
    args = parser.parse_args()
    print ' '
    print 'Default gitlab server: {0}'.format(args.gitlabServer)
    print ' '
    
    args.gitlabQueryHeaders['Private-Token'] = '{0}'.format(args.gitlabPrivateToken)

    if (not(args.enableSSLwarnings)):
        urllib3.disable_warnings()
    
    reposPath, reposName = os.path.split(args.repoFullPath)
    logger.info('Repository name: {0}'.format(reposName))

    reposPathIC = addICtails(reposPath)

    # groupIC tiene el mismo path que 
    groupIc = findOrCreateProjectParent(reposName, reposPathIC, args)
    group = findOrCreateProjectParent(reposName, reposPath, args)

    projectIC = addProjectToGroup(reposName, groupIc, args)

    createIcProjectBranches(projectIC, args)

    project = doProjectFork(projectIC, group, args)

    createProjectBranches(project, args)    

logger = configureLogger(os.path.basename(sys.argv[0]))
gitlablib.logger = logger
main()
