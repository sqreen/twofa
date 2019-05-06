#!/usr/bin/env ruby

`swift package generate-xcodeproj`

require 'xcodeproj'
project_path = 'TwoFa.xcodeproj'
project = Xcodeproj::Project.open(project_path)

project.targets.find {|x| x.name == "TwoFa"}.build_configurations.each do |config|
    config.build_settings["CREATE_INFOPLIST_SECTION_IN_BINARY"] = "YES"
    config.build_settings["INFOPLIST_FILE"] = "Supporting/Info.plist"
    config.build_settings["SUPPORTED_PLATFORMS"] = "macosx"
    config.build_settings["CODE_SIGN_ENTITLEMENTS"] = "Supporting/twofa.entitlements"
    config.build_settings["CODE_SIGN_IDENTITY"] = "Mac Developer: Janis Kirsteins (39TW4P3R2T)"
end

project.targets.find {|x| x.name == "TwoFaCore"}.build_configurations.each do |config|
    config.build_settings["SUPPORTED_PLATFORMS"] = "macosx"
end

project.save
