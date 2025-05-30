# mozeidon-macos-ui

A simple window ala `spotlight` to list and select Firefox or Chrome tabs, history and bookmarks via [mozeidon](https://github.com/egovelox/mozeidon).

⚠️ This app does not run in `sandbox` mode, because the app relies on the [mozeidon CLI](https://github.com/egovelox/mozeidon/tree/main?tab=readme-ov-file#mozeidon-cli) executable.

<img width="640" alt="mozeidon-macos-ui" src="https://github.com/user-attachments/assets/5d3b84dd-9ef3-46be-83cc-49bf30adeef7" />

## Installation 

You can use [homebrew](https://github.com/egovelox/mozeidon-macos-ui#homebrew) or a [manual installation](https://github.com/egovelox/mozeidon-macos-ui#manual-installation).

Requirements : 
- requires macOS >= `13.5` ( Ventura ).
- install in your web-browser (Firefox or Chromium) one (or both) of these browser-extensions :
    - [Firefox addon mozeidon](https://addons.mozilla.org/en-US/firefox/addon/mozeidon/)
    - [Chrome addon mozeidon](https://chromewebstore.google.com/detail/mozeidon/lipjcjopdojfmfjmnponpjkkccbjoipe)
- ( for a manual installation only )
    - the required dependency [mozeidon CLI](https://github.com/egovelox/mozeidon/tree/main?tab=readme-ov-file#mozeidon-cli)
    - the required dependency [mozeidon-native-app](https://github.com/egovelox/mozeidon/tree/main?tab=readme-ov-file#mozeidon-native-app)


### Homebrew

```bash
brew tap egovelox/homebrew-mozeidon
```

```bash
brew install --cask egovelox/mozeidon/mozeidon-macos-ui
```
Running the above commands, `brew` will install 
- the mozeidon-macos-ui app in `/Applications/mozeidon` :
- the required dependency [mozeidon CLI](https://github.com/egovelox/mozeidon/tree/main?tab=readme-ov-file#mozeidon-cli) in `/opt/homebrew/bin/mozeidon`
- the required dependency [mozeidon-native-app](https://github.com/egovelox/mozeidon/tree/main?tab=readme-ov-file#mozeidon-native-app) in `/opt/homebrew/bin/mozeidon-native-app`

Then you should be able to launch the `mozeidon` app from your macOS Applications, 
a trident 🔱 should appear in your macOS menu-bar ( this is where you may adapt your shortcuts and setup ).

In case you need to bypass some OS security, you may run ( at your own risk ) : 
```bash
xattr -r -d com.apple.quarantine /Applications/mozeidon/mozeidon.app
```
Last but not least, don't forget 
- to install and activate the mozeidon browser-extension in your favorite browser, 
- [to reference the mozeidon-native-app in your browser configuration](https://github.com/egovelox/mozeidon/tree/main?tab=readme-ov-file#referencing-the-native-app-into-your-firefox-configuration)


### Manual installation

This is a bit more complex because of dependencies : you first have to install yourself the `mozeidon` CLI and `mozeidon-native-app` components.
See [mozeidon](https://github.com/egovelox/mozeidon) and follow the [installation process](https://github.com/egovelox/mozeidon/tree/main?tab=readme-ov-file#installation).

Then please find the latest release [here](https://github.com/egovelox/mozeidon-macos-ui/releases).
Then unzip, and paste into your Applications folder.

You can also clone this repository, you'll always find the latest app release in the `release` directory ( to be pasted into your Applications folder ).

## Usage

| Keybinding    | Action |
| -------- | ------- |
| user setting  | list tabs    |
| user setting | list bookmarks     |
| user setting | list history     |
| Enter | open element in browser    |
| ctrl-L | close element in browser    |

## Settings

### CLI Settings


