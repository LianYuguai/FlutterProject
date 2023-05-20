#!/bin/sh
export LANG=en_US.UTF-8
USERNAME="yulong"
# 1.设置配置标识,编译环境(根据需要自行填写 release ｜debug )
configuration="release"

CURRENT_DIR=$(cd $(dirname $0); pwd)

# 工程名(根据项目自行填写)
APP_NAME="Runner"

# TARGET名称（根据项目自行填写）
TARGET_NAME="Runner"

# ipa前缀（根据项目自行填写）
IPA_NAME="易办公"

# info.plist路径
#project_infoplist_path="./${TARGET_NAME}/Info.plist"
# 取版本号
#bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" "${project_infoplist_path}")

#bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" "${project_infoplist_path}")

# 日期
DATE=$(date +%Y%m%d-%H-%M-%S)
# 工程文件路径
ARCHIVE_NAME="${APP_NAME}_${DATE}.xcarchive"
# 存放ipa的文件夹名称（根据自己的喜好自行修改）
IPANAME="${APP_NAME}_${DATE}_IPA"

# 工程根目录#工程源码目录(这里的${WORKSPACE}是jenkins的内置变量表示(jenkins job的路径):/Users/xxx/.jenkins/workspace/TestDemo/)
# ${WORKSPACE}/TestDemo/ 中的TestDemo根据你的项目自行修改
CODE_PATH="${CURRENT_DIR}/ios"
FLUTTER_CODE_PATH=${CURRENT_DIR}

echo "****************CODE_PATH: ${CODE_PATH}****************"


# 要上传的ipa文件路径 ${username} 需要换成自己的用户名
ROOT_PATH="/Users/${USERNAME}/Desktop/Jenkins"
ARCHIVE_PATH="${ROOT_PATH}/Archive/${ARCHIVE_NAME}"
IPA_PATH="${ROOT_PATH}/Export/${IPANAME}"
echo "ARCHIVE_PATH: ${ARCHIVE_PATH}"
echo "IPA_PATH: ${IPA_PATH}"
echo "IPA_PATH:\n${IPA_PATH}">> export_history.txt

# 导包方式(这里需要根据需要手动配置:AdHoc/AppStore/Enterprise/Development)
EXPORT_METHOD="AdHoc"
# 导包方式配置文件路径(这里需要手动创建对应的XXXExportOptionsPlist.plist文件，并将文件复制到根目录下[我这里在源项目的根目录下又新建了ExportPlist文件夹专门放ExportPlist文件])
if test "$EXPORT_METHOD" = "AdHoc"; then
    EXPORT_METHOD_PLIST_PATH=${CODE_PATH}/ExportOptions/AdHocExportOptions.plist
elif test "$EXPORT_METHOD" = "AppStore"; then
    EXPORT_METHOD_PLIST_PATH=${CODE_PATH}/ExportOptions/AppStoreExportOptios.plist
elif test "$EXPORT_METHOD" = "Enterprise"; then
    EXPORT_METHOD_PLIST_PATH=${CODE_PATH}/ExportOptions/EnterpriseExportOptions.plist
else
    EXPORT_METHOD_PLIST_PATH=${CODE_PATH}/ExportOptions/DevelopmentExportOptions.plist
fi

# 指ipa定输出文件夹,如果有删除后再创建，如果没有就直接创建
if test -d ${IPA_PATH}; then
    rm -rf ${IPA_PATH}
    mkdir -pv ${IPA_PATH}
     echo ${IPA_PATH}
else
     mkdir -pv ${IPA_PATH}
fi

# 进入工程源码根目录
cd "${FLUTTER_CODE_PATH}"

# 执行pub get
flutter pub get

# 进入工程源码根目录
cd "${CODE_PATH}"

# 执行pod
pod install

#mkdir -p build

# 清除工程
echo "++++++++++++++++clean++++++++++++++++"
xcodebuild clean -workspace ${APP_NAME}.xcworkspace -scheme ${APP_NAME} -configuration ${configuration}

# 将app打包成xcarchive格式文件
echo "+++++++++++++++++archive+++++++++++++++++"
xcodebuild archive -workspace ${APP_NAME}.xcworkspace -scheme ${APP_NAME} -configuration ${configuration} -archivePath ${ARCHIVE_PATH}

# 将xcarchive格式文件打包成ipa
echo "+++++++++++++++++ipa+++++++++++++++++"
xcodebuild -exportArchive -archivePath ${ARCHIVE_PATH} -exportPath "${IPA_PATH}" -exportOptionsPlist ${EXPORT_METHOD_PLIST_PATH} -allowProvisioningUpdates

# 删除工程文件
# echo "+++++++++删除工程文件+++++++++"
# rm -rf $ARCHIVE_PATH

# 蒲公英上传结果日志文件路径
# PGYERLOG_PATH="${IPA_PATH}/upload_pgyer_log"
# 创建蒲公英上传结果日志文件夹
# mkdir -p ${PGYERLOG_PATH}
# 创建蒲公英上传结果日志文
# touch "${PGYERLOG_PATH}/log.txt"

# 上传IPA到蒲公英 根据蒲公英官方文档编写
# file_path="${IPA_PATH}/${IPA_NAME}.ipa"
# echo "🚀🚀🚀🚀🚀🚀正在上传文件🚀🚀🚀🚀🚀🚀"
# echo $file_path
# curl -F "file=@${file_path}" -F "uKey=蒲公英的userKey" -F "_api_key=蒲公英的apiKey" https://upload.pgyer.com/apiv1/app/upload