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

play any video and the script should work properly.  
To customize, use any text editor change variables inside "User input" section.

### Confirm script is working

Open a video, then drag the same video into mpv player window,  
OSD will show "Anime4K: Scripted A/B/C" on the top left corner.

## Features

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
