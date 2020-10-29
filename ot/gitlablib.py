import json
import requests
import os
import time
import sys
from pprint import pformat

def invalidStatusCode(statusCode, validStatusCodes):
    for validStatusCode in validStatusCodes:
        if (validStatusCode == statusCode):
            return False

    return True

def checkGitLabQueryAnswer(queryAnswer, validCodes=[requests.codes.ok]):
    logger.debug ('Query Answer Status Code: {0}'.format(queryAnswer.status_code))
    if (invalidStatusCode(queryAnswer.status_code, validCodes)):
        logger.error ('Query Answer Status Code: {0}'.format(queryAnswer.status_code))
        if (queryAnswer.text):
            queryAnswerJson = json.loads(queryAnswer.text)
            logger.error(pformat(queryAnswerJson))
            
        queryAnswer.raise_for_status()
        raise Exception('Invalid http query response status code: {0}'.format(queryAnswer.status_code))

def getMaxPagesValue(queryResponse):
    logger.debug('Response headers: ')
    logger.debug(pformat(queryResponse.headers))
    logger.debug(' - ')

    queryHeaders = dict(queryResponse.headers)
    tmpMaxPages=int(queryHeaders.get('X-Total-Pages', 0))
    if (0 == tmpMaxPages):
        tmpMaxPages=int(queryHeaders.get('x-total-pages', 0))
        if (0 == tmpMaxPages):
            for value in queryHeaders.keys():
                if (value.lower().equals('x-total-pages')):
                    tmpMaxPages=int(queryHeaders.get(value, 0))

    if (0 == tmpMaxPages):
        tmpMaxPages=1

    return tmpMaxPages

def getAllGroupsFromGitLabServer(args):
    
    allGroupsJson = []
    currentPage = 1
    maxPages = 1
    while (currentPage <= maxPages):
        logger.debug('Getting the groups from the gitlab server ... ')
        groupsQueryUrl=args.gitlabServer + '/api/v4/groups'
        groupsQueryParams={   "all_available":"true",
                              "owned":"false",
                              "per_page":"20",
                              "page":"{0}".format(currentPage)}
        # "min_access_level":"false",

        logger.debug(pformat(groupsQueryParams))
        groupsQueryResponse = requests.get(groupsQueryUrl, verify=False, params=groupsQueryParams, headers=args.gitlabQueryHeaders)
        checkGitLabQueryAnswer(groupsQueryResponse)

        groupsQueryJson = json.loads(groupsQueryResponse.text)
        # print 'Response json: '
        logger.debug(pformat(groupsQueryJson))
        # print ' '
        
        maxPages = getMaxPagesValue(groupsQueryResponse) 
        logger.debug('New maxPages: {0}'.format(maxPages))
        currentPage+=1

        allGroupsJson += groupsQueryJson

    logger.debug(pformat(allGroupsJson))
    return allGroupsJson

def pathToArray(path):

    if path.endswith(os.sep):
        path = path[:-1]

    subPath, folderName = os.path.split(path)

    if ((os.sep == subPath) or ('' == subPath)):
        if ((os.sep == folderName) or ('' == folderName)):
            return []
        else:
            result=[ folderName ]
            return result
    else:
        result=pathToArray(subPath)
        result.append(folderName)
        return result
    
def findGroup(prePath, reposPath, allGroupsJson):

    reposPathArray=pathToArray(reposPath)
    logger.debug("Path {0} -->> {1} ".format(reposPath, reposPathArray))
    
    prePath=''
    group=None
    validParentGroup=None
    reposNotFoundSubPath=''
    
    for reposPathValue in reposPathArray:

        if (not(group is None)):
            prePath=group['full_path']
            validParentGroup=group
        else:
            prePath=''

        logger.debug('Looking for group with path or name: {0} in {1} '.format(reposPathValue, prePath))

        group=findGroupAux(prePath, reposPathValue, allGroupsJson)

        if (group is None):
            logger.warn('No match found while looking for {0} in {1} '.format(reposPathValue, prePath))
            reposNotFoundSubPath = os.path.join(reposNotFoundSubPath, reposPathValue)
        else:
            validParentGroup=group

    return reposNotFoundSubPath, validParentGroup
            
            
        
def findGroupAux(prePath, reposPathValue, allGroupsJson):
    
        prePathLC = prePath.lower()
        reposPathValueLC = reposPathValue.lower()

        visitedGroups = ''
        for groupsQueryJsonElement in allGroupsJson:
        
            group = dict(groupsQueryJsonElement)
            logger.debug('Group name {0} id {1} path {2} fullPath {3} '.format(group['name'], group['id'], group['path'], group['full_path']))
        
            visitedGroups = '{0} {1} ({2}, {3}, {4})'.format(visitedGroups, group['name'], group['path'], group['id'], group['full_path'])

            if (group['full_path'].lower().startswith(prePathLC)):
                logger.debug('Found full_path candidate ({0}): {1} '.format(prePathLC, group['full_path']))

                if (group['path'].lower() == reposPathValueLC):
                    logger.debug('Found path candidate ({0}): {1} '.format(reposPathValueLC, group['full_path']))

                    uncheckedPath=os.path.join(prePath, reposPathValue)

                    if (group['full_path'].lower() == uncheckedPath.lower()):
                        return group
                        
                if (group['name'].lower() == reposPathValueLC):

                    pathToCheck, folderName = os.path.split(group['full_path'])
                    if (pathToCheck.lower() == prePathLC):
                        return group
                    
        logger.warn('NOT Found group with path or name {0} in list {1} '.format(reposPathValue, visitedGroups))
        return None


def findOrCreateProjectParent(reposName, reposPath, args):

    allGroupsJson = getAllGroupsFromGitLabServer(args)
    reposNotFoundSubPath, parentGroup = findGroup('', reposPath, allGroupsJson)

    if (parentGroup is None):
        parentGroupPath='/'
    else:
        parentGroupPath=parentGroup['full_path']
    
    if ((not(reposNotFoundSubPath is None)) and (reposNotFoundSubPath.strip() != '')):
        logger.warn('Repository subPath to be created (not found): {0} parent folder: {1}'.format(reposNotFoundSubPath, parentGroupPath))

    if (None == parentGroup):
        logger.warn('Parent group not found. Adding the whole groups structure ({0})'.format(reposNotFoundSubPath))
        group = addGroups('/', reposNotFoundSubPath, args, None)

        return group
    else:
        logger.info('Parent group found. Name: {0} Path: {1}. Path: '.format(parentGroup['name'], parentGroup['full_path']))
        logger.debug(pformat(parentGroup))
        
        
        if ((reposNotFoundSubPath is None) or (reposNotFoundSubPath == os.sep) or (reposNotFoundSubPath == '')):
            logger.info('Found group {0} ({1}). Id: {2} '.format(parentGroup['name'], parentGroup['full_path'], parentGroup['id']))
            return parentGroup
        
        else:
            logger.info('Adding the groups structure {0} inside group {1} ({2})'.format(reposNotFoundSubPath, parentGroup['name'], parentGroup['full_path']))
            group = addGroups(parentGroup['full_path'], reposNotFoundSubPath, args, parentGroup)
            
            return group


def addGroups(parentPath, reposSubPathIn, args, parentGroup=None):

    if reposSubPathIn.endswith(os.sep):
        reposSubPathIn = reposSubPathIn[:-1]

    logger.warn('Adding group with path {0} in group with path {1} '.format(reposSubPathIn, parentPath))

    reposSubPath, reposFolderName = os.path.split(reposSubPathIn)

    # If os.path.split returns invalid reposFolderName, try again
    if ((reposFolderName is None) or (os.sep == reposFolderName) or ('' == reposFolderName)):
        logger.warn('addGroups: Invalid folderName ({0}) retrieved for path {1} '.format(reposFolderName, reposSubPathIn))
        reposSubPathIn = reposSubPath
        reposSubPath, reposFolderName = os.path.split(reposSubPathIn)
        
    logger.debug('addGroups: subPath: {0} folderName: {1} '.format(reposSubPath, reposFolderName))
    
    if ((reposSubPath is None) or (os.sep == reposSubPath) or ('' == reposSubPath)):
        
        logger.warn('No reposSubPath (None or empty value)')
        return addGroup(parentGroup, parentPath, reposFolderName, args)
        
    else:
        
        parentGroup=addGroups(parentPath, reposSubPath, args, parentGroup)
        
        # Recursively look for the oldest non-existing parent.
        reposSubPathAux=os.path.join(parentPath, reposSubPathIn)
        return addGroup(parentGroup, reposSubPathAux, reposFolderName, args)


def addGroup(parentGroup, parentPath, reposFolderName, args):

    if (parentGroup is None):
        parentGroupId=0
    else:
        parentGroupId=parentGroup['id']

    # reposPath=parentPath + os.sep + reposFolderName
    logger.info('Creating group {0} under group with id {1} ({2})'.format(reposFolderName, parentGroupId, parentPath))
    
    createGroupQueryUrl=args.gitlabServer + '/api/v4/groups'
    createGroupQueryParams={ "name":"{0}".format(reposFolderName),
                             "path":"{0}".format(reposFolderName.lower()),
                             "description" : "Group named {0}".format(reposFolderName),
                             "visibility" : 'private' }
    
    if (not (parentGroup is None)):
        createGroupQueryParams["parent_id"]="{0}".format(parentGroup['id'])
    # else:
    # createGroupQueryParams["parent_id"]=''
        
    logger.debug(pformat(createGroupQueryParams))
        
    createGroupQueryResponse = requests.post(
        createGroupQueryUrl, verify=False, params=createGroupQueryParams,
        headers=args.gitlabQueryHeaders)

    checkGitLabQueryAnswer(createGroupQueryResponse, validCodes=[requests.codes.ok, requests.codes.created])

    createGroupQueryResponseJson = json.loads(createGroupQueryResponse.text)
    logger.debug(pformat(createGroupQueryResponseJson))

    group = dict(createGroupQueryResponseJson)
    return group

def getAllProjectsInGroup(reposName, parentGroupId, args):

    # joinedJsons = []
    # currentPage = 1
    # maxPages = 1
    # while (currentPage <= maxPages):

    queryUrl=args.gitlabServer + '/api/v4/groups/{0}'.format(parentGroupId)
    queryParams={   "id":"{0}".format(parentGroupId),
                    "with_projects":"true",
                    # "per_page":"20",
                    # "page":"{0}".format(currentPage)
    }

    queryResponse = requests.get(queryUrl, verify=False, params=queryParams, headers=args.gitlabQueryHeaders)
    checkGitLabQueryAnswer(queryResponse)

    queryJson = json.loads(queryResponse.text)

    # maxPages = getMaxPagesValue(queryResponse)
    # logger.debug('New maxPages: {0}'.format(maxPages))
    # currentPage+=1

    # joinedJsons += queryJson

    return queryJson['projects']

def getProjectFromGroup(reposName, parentGroupId, args):

    logger.debug('Getting group details (projects in group, ...) for group with id {0}'.format(parentGroupId))
    allProjectsInGroupJson=getAllProjectsInGroup(reposName, parentGroupId, args)
    logger.debug('Looking for project named {0}'.format(reposName))

    for projectJsonElement in allProjectsInGroupJson:
        project = dict(projectJsonElement)
        logger.debug('Project with name {0} id {1} path {2} fullPath {3} '.format(project['name'], project['id'], project['path'], project['path_with_namespace']))
        if (project['name'] == reposName):
            logger.info('Found repos {0} ({1}). Id: {2} '.format(reposName, project['path_with_namespace'], project['id']))
            return project
        if (project['path'] == reposName):
            logger.info('Found repos {0} ({1}). Id: {2} '.format(reposName, project['path_with_namespace'], project['id']))
            return project
        
    return None

def addProjectToGroup(reposName, group, args):
    
    parentGroupId=group['id']
    project = getProjectFromGroup(reposName, parentGroupId, args)

    if (not (project is None)):
        return project

    logger.warn('Creating repository {0} in group with id {1} ({2})'.format(reposName, parentGroupId, group['full_path']))
        
    # POST /projects
    addProjectQueryUrl=args.gitlabServer + '/api/v4/projects'
    addProjectQueryParams={   "name":"{0}".format(reposName),
                              "path":"{0}".format(reposName.lower()),
                              "description":"Project {0}".format(reposName),
                              "namespace_id":"{0}".format(parentGroupId),
                              "issues_access_level":"private",
                              "repository_access_level":"enabled",
                              "merge_requests_access_level":"enabled",
                              "builds_access_level":"private",
                              "wiki_access_level":"private",
                              "snippets_access_level":"private",
                              "visibility":"private",
                              "request_access_enabled":"true",
                              "printing_merge_request_link_enabled":"true",
                              "initialize_with_readme":"true"
    }

    logger.debug(pformat(addProjectQueryParams))
    addProjectQueryResponse = requests.post(addProjectQueryUrl, verify=False, params=addProjectQueryParams,
                                            headers=args.gitlabQueryHeaders)
    
    checkGitLabQueryAnswer(addProjectQueryResponse, validCodes=[requests.codes.ok, requests.codes.created])

    addProjectQueryResponseJson = json.loads(addProjectQueryResponse.text)
    logger.debug(pformat(addProjectQueryResponseJson))

    return dict(addProjectQueryResponseJson)

def doProjectFork(project, group, args):

    sourceProjectId = project['id']
    projectName=project['name']
    targetGroupId = group['id']


    project = getProjectFromGroup(projectName, targetGroupId, args)

    if (not (project is None)):
        logger.info('Not doing fork: found {0} ({1}) in group {2}'.format(projectName, project['path_with_namespace'], group['id']))
        return project

    logger.warn('Creating repository fork {0} in group with id {1} ({2})'.format(projectName, group['id'], group['full_path']))

    
    # POST /projects/:id/fork
    queryUrl=args.gitlabServer + '/api/v4/projects/{0}/fork'.format(sourceProjectId)
    queryParams={   "id":"{0}".format(sourceProjectId),
                    "namespace":"{0}".format(targetGroupId)
    }

    logger.debug(pformat(queryParams))
    queryResponse = requests.post(queryUrl, verify=False, params=queryParams,
                                            headers=args.gitlabQueryHeaders)
    
    checkGitLabQueryAnswer(queryResponse, validCodes=[requests.codes.ok, requests.codes.created])

    queryResponseJson = json.loads(queryResponse.text)
    logger.debug(pformat(queryResponseJson))

    logger.info('Created repository fork {0} in group with id {1} ({2})'.format(projectName, group['id'], group['full_path']))

    return dict(queryResponseJson)

def getBranches(project, args):

    projectId = project['id']

    logger.info('Getting repository branches. Repo: {1} '.format(projectId))

    # GET /projects/:id/repository/branches
    queryUrl=args.gitlabServer + '/api/v4/projects/{0}/repository/branches'.format(projectId)
    # queryParams={   "id":"{0}".format(projectId)    }

    logger.debug(pformat(queryParams))
    queryResponse = requests.get(queryUrl, verify=False, 
                                            headers=args.gitlabQueryHeaders)
    
    checkGitLabQueryAnswer(queryResponse, validCodes=[requests.codes.ok, requests.codes.created])

    queryResponseJson = json.loads(queryResponse.text)
    logger.info(pformat(queryResponseJson))

    return queryResponseJson

def getBranch(branchName, branchesJson):

    for branchJson in branchesJson:
        branch = dict(branchJson)
        if (branchName == branch['name']):
            return branch

    return None

def createProjectBranch(project, sourceBranchName, targetBranchName, args):
    branches=getBranches(project, args)
    branch=getBranch(targetBranchName, branches)
    
    if (not (branch is None)):
        logger.warn('Branch named {0} exists in repos {1} ({2}). '.format(targetBranchName, project['name'], project['path_with_namespace']))
        return branch

    projectId = project['id']
    
    # POST /projects/:id/repository/branches
    queryUrl=args.gitlabServer + '/api/v4/projects/{0}/repository/branches'.format(projectId)
    queryParams={   "id":"{0}".format(projectId),
                    "branch":"{0}".format(targetBranchName),
                    "ref":"{0}".format(sourceBranchName)
    }

    logger.debug(pformat(queryParams))
    queryResponse = requests.post(queryUrl, verify=False, params=queryParams,
                                  headers=args.gitlabQueryHeaders)
    
    checkGitLabQueryAnswer(queryResponse, validCodes=[requests.codes.ok, requests.codes.created])

    queryResponseJson = json.loads(queryResponse.text)
    logger.debug(pformat(queryResponseJson))
    logger.info('Created project branch {0} from branch {1} in repository {2} '.format(targetBranchName, sourceBranchName, project['path_with_namespace']))
    
    return dict(queryResponseJson)

def removeProjectGroup(groupPath, args):
    allGroupsJson = getAllGroupsFromGitLabServer(args)
    reposNotFoundSubPath, parentGroup = findGroup('', groupPath, allGroupsJson)

    if ((reposNotFoundSubPath is None) or (reposNotFoundSubPath == os.sep) or (reposNotFoundSubPath == '')):
        logger.info('Found group {0}. Id: {1} '.format(parentGroup['name'], parentGroup['id']))

        # DELETE /groups/:id
        queryUrl=args.gitlabServer + '/api/v4/groups/{0}'.format(parentGroup['id'])
        queryParams={   "id":"{0}".format(parentGroup['id'])    }

        logger.debug(pformat(queryParams))
        queryResponse = requests.delete(queryUrl, verify=False, params=queryParams,
                                        headers=args.gitlabQueryHeaders)
    
        checkGitLabQueryAnswer(queryResponse, validCodes=[requests.codes.ok, requests.codes.accepted])

        queryResponseJson = json.loads(queryResponse.text)
        logger.debug(pformat(queryResponseJson))

        logger.warn('Removed group with id {0} and path {1} '.format(parentGroup['id'], parentGroup['full_path']))
        return parentGroup
    else:
        logger.warn('NOT removed group with path {0} '.format(groupPath))
    return None


def getGitLabUser(userName, args):

    # DELETE /groups/:id
    queryUrl=args.gitlabServer + '/api/v4/users'
    queryParams={   "username":"{0}".format(userName)    }

    logger.debug(pformat(queryParams))
    queryResponse = requests.get(queryUrl, verify=False, params=queryParams,
                                 headers=args.gitlabQueryHeaders)
    
    checkGitLabQueryAnswer(queryResponse, validCodes=[requests.codes.ok])

    queryResponseJson = json.loads(queryResponse.text)
    logger.debug(pformat(queryResponseJson))

    gitLabUser = None
    for userDetails in queryResponseJson:
        if (gitLabUser is None):
            gitLabUser = dict(userDetails)

    if (gitLabUser is None):
        return None
    
    return gitLabUser

def createGitLabUser(userName, args):
    logger.info('Creating GitLab user {0}'.format(userName))

def findOrCreateGitlabUser(userName, args):

    gitLabUser = getGitLabUser(userName, args)

    if (gitLabUser is None):
        return createGitLabUser(userName, args)

    logger.warn('NOT')
    return None
    
def addUserToGitlabExistingGroup(gitlabUser, gitlabGroup, userRole, args):

    return None

    
def addUserToGitlabGroup(userName, userRole, groupFullPath, args):

    allGroupsJson = getAllGroupsFromGitLabServer(args)
    reposNotFoundSubPath, gitlabGroup = findGroup('', groupFullPath, allGroupsJson)

    if ((not (reposNotFoundSubPath is None)) and (reposNotFoundSubPath != os.sep) and (reposNotFoundSubPath != '')):
        logger.error('NOT Found group {0} '.format(groupFullPath))
        return None
    
    logger.info('Found group {0}. Id: {1} '.format(gitlabGroup['name'], gitlabGroup['id']))

    gitlabUser = findOrCreateGitlabUser(userName, args)

    addUserToGitlabExistingGroup(gitlabUser, gitlabGroup, userRole, args)
    
    return None

def getRepository(searchString, args):

    allResultsJson = []
    currentPage = 1
    maxPages = 1
    while (currentPage <= maxPages):
        logger.debug('Getting the groups from the gitlab server ... ')

        # DELETE /groups/:id
        queryUrl=args.gitlabServer + '/api/v4/projects'
        queryParams={   "search":"{0}".format(searchString),
                        "owned":"false",
                        "per_page":"20",
                        "page":"{0}".format(currentPage)}
        
        logger.debug(pformat(queryParams))
    

        queryResponse = requests.get(queryUrl, verify=False, params=queryParams,
                                     headers=args.gitlabQueryHeaders)
    
        checkGitLabQueryAnswer(queryResponse, validCodes=[requests.codes.ok])
        
        # print 'Response: '
        logger.debug(pformat(queryResponse))

        maxPages = getMaxPagesValue(queryResponse)
        logger.debug('New maxPages: {0}'.format(maxPages))
        currentPage+=1

        queryResponseJson = json.loads(queryResponse.text)
        allResultsJson += queryResponseJson

    logger.info(pformat(allResultsJson))

    return allResultsJson

def transferRepository(reposName, sourceFullPath, targetFullPath, args):
    allGroupsJson = getAllGroupsFromGitLabServer(args)
    reposNotFoundSubPath1, sourceGroup=findGroup('', sourceFullPath, allGroupsJson)
    reposNotFoundSubPath2, targetGroup=findGroup('', targetFullPath, allGroupsJson)    

    if (not ((reposNotFoundSubPath1 is None)) and (reposNotFoundSubPath1.strip() != '')):
        raise Exception('Group not found: {0} '.format(sourceFullPath))
    if (not ((reposNotFoundSubPath2 is None)) and (reposNotFoundSubPath2.strip() != '')):
        raise Exception('Group not found: {0} '.format(targetFullPath))

    
    sourceGroupId=sourceGroup['id']
    targetGroupId=targetGroup['id']

    project=getProjectFromGroup(reposName, sourceGroupId, args)
    if (project is None):
        raise Exception('Project not found in group {0}: {1}'.format(sourceGroupId, reposName))

    projectId=project['id']


    logger.warn('Transferring repository {0} from group with id {1} to group with id {2}'.format(reposName, sourceGroupId, targetGroupId))

    queryUrl=args.gitlabServer + '/api/v4/projects/{0}/transfer'.format(projectId)
    queryParams={   "namespace":"{0}".format(targetGroupId) }
        
    logger.debug(pformat(queryParams))
    
    queryResponse = requests.put(queryUrl, verify=False, params=queryParams,
                                 headers=args.gitlabQueryHeaders)
    
    checkGitLabQueryAnswer(queryResponse, validCodes=[requests.codes.ok])
    

def protectBranch(project, branchName, args):
    
    projectId = project['id']

    logger.info('Protecting branch {0} in repository {1} ({2}, {3}, {4})'.format(branchName, project['name'], project['id'], project['path'], project['path_with_namespace']))

    protectBranchQueryUrl=args.gitlabServer + '/api/v4/projects/{0}/protected_branches'.format(projectId)
    protectBranchQueryParams={ "name":"{0}".format(branchName),
                             "push_access_level":"40",
                             "merge_access_level" : "40",
                             "unprotect_access_level" : '40' }

    logger.debug(pformat(protectBranchQueryParams))

    protectBranchQueryResponse = requests.post(
        protectBranchQueryUrl, verify=False, params=protectBranchQueryParams,
        headers=args.gitlabQueryHeaders)

    # checkGitLabQueryAnswer(protectBranchQueryResponse, validCodes=[requests.codes.ok, requests.codes.created])

    protectBranchQueryResponseJson = json.loads(protectBranchQueryResponse.text)
    logger.debug(pformat(protectBranchQueryResponseJson))



# Module global variables
logger = None
