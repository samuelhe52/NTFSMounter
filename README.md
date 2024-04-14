# NTFSMounter for macOS
This is a command line tool for mounting Windows/Microsoft NTFS Volumes on macOS with read/write support.

## Installation

**Important**
If you are a non-developer, you may need to install Xcode Command Line Tool first:
```shell
xcode-select --install 
```

This tool requires ntfs-3g and macFUSE be installed. You can install them with brew:

```shell
brew tap gromgit/homebrew-fuse
brew install --cask macfuse
brew install ntfs-3g-mac
```
Or alternatively install them manually.

For macFUSE: [macFUSE](https://osxfuse.github.io)

For ntfs-3g: [ntfs-3g](https://github.com/tuxera/ntfs-3g)

## Usage

Download the latest release from the Releases Page, then copy the executable file to `usr/local/bin` with this command:

```shell
sudo cp /path/to/executable/downloaded /usr/local/bin
```

Then you would be able to run the command `ntfsmounter` to start mounting all NTFS Volumes found connected to your Mac in your preferred terminal from any directories.

```shell
ntfsmounter
```

Since mounting volumes with ntfs-3g requires admin privileges, you have to provide the tool with your machine's admin password for this tool to work.

You have the option to enter your password mannually everytime you use this tool, or you may also enter you password once on fisrt run, and your password will be safely stored in your system's keychain, accessible only by admins and this tool itself.

If you would like to change your preferred way of providing the password, or if you have changed your admin password and would like to update the password stored in keychain, you may run the tool with the argument `--config` .

```shell
ntfsmounter --config
```

## Build
To build and run this project youself, first clone this repo.
```shell
https://github.com/samuelhe52/NTFSMounter.git
```
Open the project in Xcode. In the "Signing & Capabilities" page in the project settings, change Signing Certificate to your own or select 'Sign to Run Locally'. Then you may be able to build & run the project.

