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
    parser = argparse.ArgumentParser(description='Adds an user to a group in GitLab.')
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
    parser.add_argument('--groupFullPath', dest='groupFullPath', required=True,
                        help='Full path to the repository. Example: JAVA/SIM/sim_J2_00')
    parser.add_argument('--userName', dest='userName', required=True,
                        help='User Login Name in GitLab. Example: PaquitoChocolatero')
    parser.add_argument('--userRole', dest='userRole', required=True,
                        help='User Role in the group (*not* for all groups nor for the whole system. '+
                        'Example: God')
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
    
    groupIc = addUserToGitlabGroup(args.userName, args.userRole, args.groupFullPath, args)

logger = configureLogger(os.path.basename(sys.argv[0]))
gitlablib.logger = logger
main()
