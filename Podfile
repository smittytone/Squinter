# Uncomment the next line to define a global platform for your project
platform :osx, '10.12'

target 'Squinter' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!

  # Pods for Squinter
  pod 'PDKeychainBindingsController', '~> 0.0'
  pod 'Sparkle', '> 1.22'

end

target 'SquirrelPreviewer' do
    pod 'Highlightr'
end

post_install do |installer|
	# Sign the Sparkle helper binaries to pass App Notarization.
	system("codesign --force -o runtime -s 'Developer ID Application: Antony Smith (Y5J3K52DNA)' Pods/Sparkle/Sparkle.framework/Resources/Autoupdate.app/Contents/MacOS/Autoupdate")
	system("codesign --force -o runtime -s 'Developer ID Application: Antony Smith (Y5J3K52DNA)' Pods/Sparkle/Sparkle.framework/Resources/Autoupdate.app/Contents/MacOS/fileop")
end
