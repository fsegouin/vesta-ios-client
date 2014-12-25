![vesta logo](http://oi61.tinypic.com/35iapzp.jpg)

# Vesta iOS

Client iOS pour le projet VESTA

## Releases

Still under development. ETA: January 2015.

## Installation

### Step 1 : Download Xcode
<https://developer.apple.com/xcode/>

### Step 2 : Clone this repo
Run the following command line in Terminal (Protip: use [iTerm2](http://www.iterm2.com/#/section/home)):

	$ git clone git@github.com:fsegouin/vesta-ios-client.git

### Step 3 : Install [CocoaPods](http://cocoapods.org/)

Important : if you don't have Ruby installed:

	$ curl -sSL https://get.rvm.io | bash -s stable --ruby
	$ rvm install ruby

In your clone directory, run the following:

	$ gem install cocoapods
	$ pod install

### Final Step

Open the vesta.xcworkspace file that Cocoapods generates in your project directory.

## Install and debug the app on a real device (Xcode 6.1.1)

Testing the app in iOS simulator is nice. Testing it on your device is much better though.
To launch the app on your device, you need to do the following:

### Step 1

On your jailbroken device, install AppSync Unified from [Karen's Pineapple Repo] (http://cydia.angelxwind.net).
Don’t use any other AppSync version, and if you have others, be sure to remove them (no PPsync crap).

### Step 2

Open /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/SDKSettings.plist and change AD_HOC_CODE_SIGNING_ALLOWED value to YES. OS X won't let you edit the file in the same folder (and vim can't help you  with plist files anyway). You need to make a copy of the file to the desktop, change it, save it, then drag and drop back into the original folder.

### Step 3

If Xcode was running (are you insane?), restart Xcode.
Change your Project AND Target settings to “Ad Hoc Code Sign” in Build Settings. It's really important you do it for both projet and target settings (also check tests targets).

### Step 4

Tell Xcode to run app on iPhone. At this point, Xcode will put app on your iDevice, but can’t debug because it can’t attach to the process. The app will start then close immediately. You can now manually start the app on the phone though.

### Step 5
To enable debugging: In your project select File > New File > Property List and create a file called “Entitlements.plist”.
Add a boolean value called "Can be debugged" and set the value to YES.
Now change your Project and Target Code Signing Entitlements (In Build Settings) to “Entitlements.plist” (you have to type it in).

### Step 6
To use system Keychain while using Ad Hoc Code Sign, you need to add the following key to your Entitlements.plist:

	<key>application-identifier</key>
	<string>com.utt.vesta</string>

Please notice that any app using a wildcard instead of its own application-identifier could grant itself access to every other app’s keychain data which is a real security breach.
Once again, do not install apps from sources outside of the App Store for your own security!

Thanks to [Graeme Robinson] (http://www.grobinson.me/developing-and-debugging-my-own-apps-on-jailbroken-ios8-1-using-xcode-6-1-without-paying-apple/)
