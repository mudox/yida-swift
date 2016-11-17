# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'YiDaSwift' do
  use_frameworks!

  pod 'CocoaLumberjack/Swift'

  pod 'SwiftyJSON'
  pod 'Gloss', '~> 1.0'

  pod 'SwiftMessages'

  pod 'SwiftValidators'

  pod 'PySwiftyRegex'

  pod 'RxSwift'
  pod 'RxCocoa'

  pod 'SwiftDate', '~> 4.0'
  pod 'RandomKit'

  pod 'SnapKit', '~> 3.0'

  pod 'Alamofire', '~> 4.0'

  pod 'pop', '~> 1.0'

  target 'YiDaSwiftTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'YiDaSwiftUITests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ClassRoster' do
    inherit! :complete
    pod 'CocoaLumberjack/Swift'
  end

  PROJECT_NAME = 'YiDaSwift'
  TEST_TARGET = 'EarlGreyTests'
  SCHEME_FILE = TEST_TARGET + '.xcscheme'

  target TEST_TARGET do
    inherit! :search_paths

    pod 'EarlGrey'
  end

  post_install do |installer|
    require 'earlgrey'
    configure_for_earlgrey(installer, PROJECT_NAME, TEST_TARGET, SCHEME_FILE, {swift: true})
  end

end
