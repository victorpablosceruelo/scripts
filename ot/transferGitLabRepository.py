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
    parser.add_argument('--sourceFullPath', dest='sourceFullPath', required=True,
                        help='Full path to the repository to transfer (move). Example: JAVA/SIM/sim_J2_00')
    parser.add_argument('--targetFullPath', dest='targetFullPath', required=True,
                        help='Full path to the group that will hold the repository. Example: JAVA/SIM2/sim_J2_00')
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

    reposPath, reposName = os.path.split(args.sourceFullPath)
    
    groupIc = transferRepository(reposName, reposPath, args.targetFullPath, args)

logger = configureLogger(os.path.basename(sys.argv[0]))
gitlablib.logger = logger
main()
