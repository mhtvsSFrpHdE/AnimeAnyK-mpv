![](https://raw.githubusercontent.com/mhtvsSFrpHdE/contact-me/master/AboutIssue.svg)

# AnimeAnyK-mpv

Automatically enable Anime4K in mpv player depending on video resolution.

## How to use

### Install

Download and put Lua script into your mpv script folder,  
put Anime4K files to your mpv shader folder like this:

```
mpv\mpv.conf
mpv\scripts\AnimeAnyK.lua
mpv\shaders\Anime4K_AutoDownscalePre_x2.glsl
mpv\shaders\Anime4K_AutoDownscalePre_x4.glsl
...and many other
```

Add the following line to `mpv\input.conf`:

```
CTRL+7 script-binding create-anyk-indicator-file
```

This is a custom key binding, you can replace `CTRL+7` with any customizations.  
By default, anyK doesn't bind any key to avoid potential conflicts.

### Run script

There are many types of videos and Anime4K only works good on anime videos.  
You may already save all your anime videos in the same folder.  
Press binded key to trigger "create-anyk-indicator-file" command,  
this will generate a indicator file in folder where video is stored.  
After this file is created, any video inside same folder will automatically enable Anime4K.

To customize Anime4K, use any text editor change variables inside "User input" section.

### Confirm Anime4K enabled by script

Open a video, then drag the same video into mpv player window,  
OSD will show "Anime4K: Scripted A/B/C" on the top left corner.

## Features

### Indicator file

The script uses a dummy file to decide Anime4K should be enabled or not.  
So it won't enable Anime4K on non-anime videos wrongly.  
It's kinda similar to "remember password."

### From 1440P to 480P

The script can send the auto-generated command to enable Anime4K.  
It's possible to customize shader quality (S, M, L, etc).  
If video is greater than or equal to 2160P it's ignored, Anime4K won't enable.

### From 2160P to 480P

The script can send user-specified commands to mpv depending on video resolution.  
This command string is fully under user control,  
so it's possible to customize Anime4K or even any mpv commands.

### Auto generate logic

Based on https://github.com/bloc97/Anime4K/blob/master/GLSL_Instructions.md
