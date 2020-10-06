#!/bin/bash

hostsNames=()
hostsNames+=( "des-redmine-g.scae.redsara.es" )
hostsNames+=( "des-gitlab-g.scae.redsara.es" )
hostsNames+=( "des-sonar-g.scae.redsara.es" )
hostsNames+=( "des-satis-g.scae.redsara.es" )
hostsNames+=( "des-artefactos-g.scae.redsara.es" )
hostsNames+=( "des-jenkins-g.scae.redsara.es" )
hostsNames+=( "des-jenkins-slave-g.scae.redsara.es" )

hostsNames+=( "redmine-ic-g.scae.redsara.es" )
hostsNames+=( "gitlab-ic-g.scae.redsara.es" )
hostsNames+=( "sonarqube-ic-g.scae.redsara.es" )
hostsNames+=( "satis-ic-g.scae.redsara.es" )
hostsNames+=( "artefactos-ic-g.scae.redsara.es" )
hostsNames+=( "jenkins-ic-g.scae.redsara.es" )
hostsNames+=( "jenkins-slave-1-ic-g.scae.redsara.es" )
hostsNames+=( "jenkins-slave-2-ic-g.scae.redsara.es" )

# hostsNames+=( "selenium-1-ic-g.scae.redsara.es" )

# hostsNames+=( "" )

echo ${hostsNames[@]}
