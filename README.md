![](https://raw.githubusercontent.com/mhtvsSFrpHdE/contact-me/master/AboutIssue.svg)

# AnimeAnyK-mpv

The core idea is to send different inputs to mpv player depending on video resolution.

Automatically turn on Anime4K in mpv player depending on video resolution.  
Customize Anime4K command for early access to new Anime4K version or bug workaround.  
Remember Anime4K on/off status for other videos in the same folder.

> **Note: I do hope to preserve Linux/Unix support, but I only run Windows PC.**  
> **Please use code entry prepared in advance to test/fix error on Linux/Unix and pull your patch back.**

## How to use

### Install

Minimum recommended AnyK version is `1.1.4 release`.

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
CTRL+7 script-binding toggle-anime4k-jbgyampcwu
```

This is a custom key binding, you can replace `CTRL+7` with any customizations.  
By default, AnimeAnyK doesn't bind any key to avoid potential conflicts.

### Toggle Anime4K on/off

Open a video, press the bound key to trigger the "toggle" command,  
this will enable Anime4K, and create an indicator file in the folder where the video is stored.  
Then open any other video inside the same folder will enable Anime4K automatically.

Press the same key again, indicator file will be deleted  
and use Anime4K official command to clear GLSL shaders.

Without the indicator file,  
AnimeAnyK won't do anything to prevent enabling Anime4K on non-anime videos.

### Custom Anime4K

To customize Anime4K, use any text editor open the ".lua" file,  
change variables inside "UserInput" class.

Once `UseUserInputCommand` set to `true`,  
AnimeAnyK will use user commands to replace built-in Anime4K commands.

### Confirm Anime4K enabled by script

Open a video, then drag the same video into mpv player window,  
OSD will show "Anime4K: Scripted A/B/C" on the top left corner.

## Other

### Auto generate logic

Based on https://github.com/bloc97/Anime4K/blob/master/GLSL_Instructions.md
