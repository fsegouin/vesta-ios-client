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
