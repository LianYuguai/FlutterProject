.PHONY: test

CommitId=`git rev-parse --short HEAD`
CurrentTime=`date "+%Y%m%d%H%M%S"`
BuildCount=`git rev-list HEAD --first-parent --count`

test:
	echo "hello,world"

rename_apk:
	mv build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/emp-mobile-$(CurrentTime)-$(CommitId)-release.apk

organization:
	flutter create --org package_name .

build_runner:
	flutter pub run build_runner build --delete-conflicting-outputs

release_apk:
	flutter build apk --release --build-name=${CommitId} --build-number=${BuildCount}
	rm -rf build/app/outputs/flutter-apk/emp-mobile-*.apk
	cp build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/emp-mobile-$(CurrentTime)-$(CommitId)-release.apk

release_aab:
	flutter build appbundle --release --build-name=${CommitId} --build-number=${BuildCount}

release_ios:
	flutter build ios --release --build-name=${CommitId} --build-number=${BuildCount}

release_ipa:
	flutter build ipa --release --build-name=${CommitId} --build-number=${BuildCount}

release_ipa_adhoc:
	flutter build ipa --release --export-method=ad-hoc --build-name=${CommitId} --build-number=${BuildCount}
	rm -rf build/ios/ipa/emp-mobile-*.ipa
	cp build/ios/ipa/易办公.ipa build/ios/ipa/emp-mobile-$(CurrentTime)-$(CommitId)-release.ipa

release_macos:
	flutter build macos --release --build-name=${CommitId} --build-number=${BuildCount}

release_windows:
	flutter build windows --release --build-name=${CommitId} --build-number=${BuildCount}

release_linux:
	flutter build linux --release --build-name=${CommitId} --build-number=${BuildCount}

release_web:
	flutter build web --release --build-name=${CommitId} --build-number=${BuildCount}