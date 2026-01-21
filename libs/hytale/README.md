# HytaleServer_DevUpdateScripts
A Windows Powershell script which is used to update the Hytale Server components that are used for mod development.

These scripts were created to support easy updating of HytaleServer.jar and Assets.zip. They are also useful for creating automated build processes for plugins with code as they can be used to download the Hytale server, retrieve the needed files, and clean up all temporary storage *in process*--so you don't have to commit HytaleServer.jar or Assets.zip to your plugin repository to support your build process.

These scripts automatically clean up all temporary storage, so there is no problem using these in development environments.

## Windows
Run `update_windows.ps1`.

```
update.ps1

  Retrieves the latest versions of HytaleServer.jar and Assets.zip.

  Use:
    ./update.ps1 [-Destination path]
  
    Destination   Specify a path to write HytaleServer.jar and Assets.zip.
	                Optional. Default value is script_directory\win-server.
```

## Linux (Bash)
Run `update_linux.sh`.

```
update_linux.sh

  Retrieves the latest versions of HytaleServer.jar and Assets.zip.

  Use:
    ./update.sh [destination]
  
    destination   Specify a path to write HytaleServer.jar and Assets.zip.
	                Optional. Default value is script_directory\nix-server.
```