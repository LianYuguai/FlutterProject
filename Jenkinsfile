pipeline {
    agent any
    environment {
        JAVA_OPTS = "-Xms128m -Xmx256m -Xmn64m"
        DESC_IP="vm180"
    }
   parameters {
        string(name: 'INSTALL_PATH', defaultValue: '/opt/opt-data/jenkins-target', description: 'Running JAR file for server deployment directory。')
   }
    tools {
        maven 'MAVEN_HOME'
        nodejs 'nodejs'
        jdk   'JAVA_HOME'
    }
    stages {

        stage('Check ENV') {
          steps {
              echo '-------------------------------- 检查环境 --------------------------------'
              echo "$NODEJS_HOME"
              echo "$env.JAVA_HOME"
              echo "$JAVA_OPTS"
              sh 'node --version'
              sh 'npm --version'
              sh 'mvn --version'
              sh 'java -version'
          } //end steps
        }// end stage

        stage('Build project WEB') {
              steps {
                echo '-------------------------------- 编译前端 -----------------------------------'
                sh '''
                    work_dir=`pwd`
                    echo $work_dir
                    echo \'>>>>>work dir :\'$work_dir
                    export NODE_OPTIONS=--openssl-legacy-provider

                    echo '>>>>>>>>>>>>> bpm run build obpm-signon-web/sso '
                    cd ${work_dir}/obpm-signon-web/sso
                    npm install
                    npm run build

                    echo '>>>>>>>>>>>>> bpm run build obpm-runtime-web/ '
                    cd ${work_dir}/obpm-designer-web
                    npm install
                    npm run build

                    echo '>>>>>>>>>>>>> bpm run build obpm-runtime-web/portal/vue '
                    cd ${work_dir}/obpm-runtime-web/portal/vue
                    npm install
                    npm run build

                    echo '>>>>>>>>>>>>> bpm run build obpm-runtime-web/domain '
                    cd ${work_dir}/obpm-runtime-web/domain
                    npm install
                    npm run build

                    echo '>>>>>>>>>>>>> bpm run build obpm-runtime-web/custom_mobile '
                    cd ${work_dir}/obpm-runtime-web/custom_mobile
                    npm install
                    npm run build
                    rm -rf ${work_dir}/obpm-runtime-web/mobile/dist/* ; mkdir -p ${work_dir}/obpm-runtime-web/mobile/dist/

                    cp -rf ${work_dir}/obpm-runtime-web/custom_mobile/dist/*   ${work_dir}/obpm-runtime-web/mobile/dist/
                    # cp -rf ${work_dir}/obpm-runtime-web/custom_mobile/dist/static/mobile/*  ${work_dir}/obpm-runtime-web/mobile/dist/
                    echo '>>>>>>>>>>>>> 编译前端 End '
                '''
              }//end steps
        }// end stage

        stage('Build project') {
              steps {
                echo '-------------------------------- 编译后台 -----------------------------------'
                sh '''
                    work_dir=`pwd`
                    echo $work_dir
                    echo \'>>>>>work dir :\'$work_dir
                    deploy_work_dir=/opt/opt-data/jenkins-target

                    mvn clean install -Dmaven.test.skip=true
                    echo ">>>>>>>>>>>>> COPY file to  $deploy_work_dir"

                    cd $work_dir
                    \\cp $(find . -type f -name "static.war") $deploy_work_dir
                    \\cp $(find . -type f -name "*consul-5.0.sp2.jar") $deploy_work_dir
                    echo ">>>>>>>>>>>>> 编译后台  End"
                '''

              }//end steps
         }// end stage

        stage('Send remote file') {
              steps {
                echo '------------------------------- Send remote file & Clean workspace --------------------------------'

                sh '''
                deploy_work_dir=/opt/opt-data/jenkins-target
                remote_deloy_tmp_dir=/opt/opt-data/jenkins-work/temp
                tomcat_webapps_home="/usr/local/tomcat/webapps"

                echo ">>>>>>>>>>>>>  Send  ${deploy_work_dir} file to ${DESC_IP}  ${remote_deloy_tmp_dir}"
                cd $deploy_work_dir && scp * root@${DESC_IP}:${remote_deloy_tmp_dir}
                echo ">>>>>>>>>>>>>  Clean workspace  ${deploy_work_dir}"
                sleep 2
                rm -rf ${deploy_work_dir}/*
                rm -rf ${tomcat_webapps_home}/*

                '''
               }//end steps
          }// end stage

         stage('Disable old server') {
               steps {
                     echo "-------------------------------Disable  old server --------------------------------"
                     sshPublisher(publishers: [sshPublisherDesc(configName: 'vm180', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand:
                         '''
                         echo ">>>>>>>>>>>>> kill old server..."
                         ps aux|grep  "consul-5.0.sp2.jar" |grep -v grep | awk \'{print $2}\'  | xargs kill -9 >/dev/null 2>&1

                         echo ">>>>>>>>>>>>> Kill tomcat..."
                         ps aux|grep  "apache.catalina.startup.Bootstrap" |grep -v grep | awk \'{print $2}\'  | xargs kill -9 >/dev/null 2>&1
                         echo ">>>>>>>end"|grep -v grep
                         ''', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+',
                         remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: true)])

             }//end steps
        }// end stage

        stage('Prepare the environment') {
              steps {
                    echo "------------------------------- Prepare the environment --------------------------------"
                    sshPublisher(publishers: [sshPublisherDesc(configName: 'vm180', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand:
                    '''
                    work_dir="/opt/opt-data/jenkins-work"
                    desc_path="${work_dir}/temp"
                    deploy_path="${work_dir}/deploy"
                    app_file="consul-5.0.sp2.jar"
                    tomcat_webapps_home="/usr/local/tomcat/webapps"

                    echo ">>>>>>>>>>>>> Copy obpm-demo & static.war to to tomcat/webapps"
                    tar -zxvf ${desc_path}/obpm-demo*.tar.gz  -C  ${tomcat_webapps_home} >/dev/null
                    unzip -o ${desc_path}/static.war -d  ${tomcat_webapps_home}/static >/dev/null
                    \\cp  ${desc_path}/*consul-5.0.sp2.jar  ${deploy_path}/
                    echo ">>>>>>>>>>>>> Prepare the environment end"

                    ''', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+',
                    remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: true)])

               }//end steps
          }// end stage

          stage('Startup Server') {
                steps {
                  echo "------------------------------- Startup Sp2 Server --------------------------------"
                  sshPublisher(publishers: [sshPublisherDesc(configName: 'vm180', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand:
                  '''
                      work_dir=`pwd`
                      echo \'>>>>>work dir :\'$work_dir
                      work_dir="/opt/opt-data/jenkins-work"
                      app_file="consul-5.0.sp2.jar"
                      echo ">>>>>>>>>>>>> Startup Server....."
                      sh ${work_dir}/bin/startup-all.sh
                      tail -f ${work_dir}/logs/*.log | sed "/.*initialization started.*/q"

                  ''', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: true)])


                 echo "------------------------------- Startup Tomcat --------------------------------"
                 sshPublisher(publishers: [sshPublisherDesc(configName: 'vm180', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand:
                     '''
                     export JAVA_HOME=/usr/local/jdk/jdk1.8.0_341
                     echo "启动tomcat..." > /usr/local/tomcat/logs/catalina.out
                     sh /usr/local/tomcat/bin/startup.sh
                     tail -f  /usr/local/tomcat/logs/catalina.out | sed \'/.*start Server startup in.*/q\'
                     ''', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+',
                     remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: true)])


                 }//end steps
            }// end stage




	}//end stages
}