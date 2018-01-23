
<p align="center">
  <!-- <img src="./Assets/PresentationSettings.jpg" alt="PresentationSettings"> -->
  <br/><a href="https://cocoapods.org/pods/PresentationSettings">
  <img alt="Version" src="https://img.shields.io/badge/version-1.1.2-brightgreen.svg">
  <img alt="Author" src="https://img.shields.io/badge/author-Meniny-blue.svg">
  <img alt="Build Passing" src="https://img.shields.io/badge/build-passing-brightgreen.svg">
  <img alt="Swift" src="https://img.shields.io/badge/swift-4.0%2B-orange.svg">
  <br/>
  <img alt="Platforms" src="https://img.shields.io/badge/platform-iOS-lightgrey.svg">
  <img alt="MIT" src="https://img.shields.io/badge/license-MIT-blue.svg">
  <br/>
  <img alt="Cocoapods" src="https://img.shields.io/badge/cocoapods-compatible-brightgreen.svg">
  <img alt="Carthage" src="https://img.shields.io/badge/carthage-working%20on-red.svg">
  <img alt="SPM" src="https://img.shields.io/badge/swift%20package%20manager-compatible-brightgreen.svg">
  </a>
</p>

# Introduction

## What's this?

Configuration for `UIViewController` presentation.


## Preview

<table>
<tr>
<td><img src="./Assets/alert.gif"/></td>
<td><img src="./Assets/loading.gif"/></td>
</tr>
<tr>
<td><img src="./Assets/notification.gif"/></td>
<td><img src="./Assets/snack.gif"/></td>
</tr>
</table>


## Requirements

* iOS 8.0+
* Xcode 9 with Swift 4

## Installation

#### CocoaPods

```ruby
pod 'PresentationSettings'
```

## Contribution

You are welcome to fork and submit pull requests.

## License

`PresentationSettings` is open-sourced software, licensed under the `MIT` license.

## Usage

The simplest way:

```swift
@IBAction func showAlert(_ sender: UIButton) {
    let alert = SomeController.init()
    self.present(viewController: alert, settings: .default, animated: true, completion: nil)
}
```

Create your custom presentation settings:

```swift
let type = PresentationType.dynamic(center: .center)
let settings = PresentationSettings.init(presentationType: type)
settings.transitionType = nil
settings.dismissTransitionType = nil
settings.dismissAnimated = true
settings.dismissOnSwipe = false
settings.dismissOnTap = false
settings.keyboardTranslationType = .moveUp
....
```
