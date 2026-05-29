# LAG-FR33 Shaders
## For Minecraft Java Fabric 1.21.1+
### Short Description:
I decided to make lightweight shaders for my budget laptop and it went fantastic.
Using any other "lightweight" shader nowadays leads to ~30-40 FPS averages maybe.
The only decent shader I have found is Miniature Shader 2.18.11 with ~80 FPS idle averages.
So I started making my own shaders with the help of Claude Sonnet 4.6.

### Backstory:

I ended up making my first shader called "MyFSR+" built off of fsrmine by BobbyDeveloper on CurseForge. Yet the upscaling didn't work. The first like 30 editions looked horrible, but the final product was worth it. I ended up getting quality similar to MakeUp-UltraFast but way faster in performance. It ended up recieving 118 FPS averages when idle, compared to the 23 FPS averages when idle that MakeUp-UltraFast had is insane.
Then I tried making another shaderpack without the "upscaling," called "MyFSR" and it went swimmingly compared to the "upscaling" version, achieving better quality and way better performance. MyFSR ended up hitting ~162 FPS when idle.
However I decided to make more shaders, chasing now explicit performance increases. I ended up optimizing a very early version of MyFSR+ and stripping it of it's "upscaling." I then tweaked and messed with the .fsh code. I named this "UND3RV0LT," it hit ~175 FPS averages when idle. This wasn't a part of the FSR series so it had less quality but favored performance, this I wouldn't group into a series yet but it's very similar to the next series.
I started a new series, the D4Y series. It is a performance-first focussed shader. It started with with "Y3ST3RD4Y," this shader hit better than UND3RV0LT in performance, but quality is similar. This one shader breaks barely just ~1 FPS higher with ~176 FPS idle averages. However this next one is better, the shader's name is "T0D4Y." This shader single-handedly breaks the invisible 180 FPS barrier, hitting ~180 FPS averages while idle. Lastly, my personal least favorite being "T0M0RR0W." This sacrifices all-quality you could've thought of. Even though looking not that bad, noticable bugs break the fun experience shaders provide. It performs at a whopping ~190 FPS averages when idle. Considering my vanilla idle when testing was ~310 FPS, this is way more close to vanilla FPS than the lightest commercial shader I could find (Miniature Shader 2.18.11.) However there is one more addition I recently made, and it's to the FSR series (although missing the "upscaling" like MyFSR.) You'd think a performance focused shader that also requires quality, couldn't dare come up to D4Y series level performance. I thought that too, especially when I was making this copy of MyFSR. But we're both wrong apparently. I made a copy of MyFSR with code slightly tweaked over 3 versions, the resulting version shockingly performs at ~183 FPS averages while idle. Considering it looks better than any of the shaders I made, yet it is the second best shader I benchmarked out of 20 shaders (with 7 being mine.)

## Benchmarks

I benchmarked 20 shaders to measure performance on my laptop with a Ryzen 5 7520U, 16GB LPDDR5, and the Radeon 610M iGPU for Minecraft Java Fabric 1.21.1 on Prism Launcher.
 This was made inside of google spreadsheets to track the data easily. Below is an image of the data found among popular shaders, performance shaders, and my shaders when benchmarked in the same area idle with the game's tick speed frozen.

![Benchmarking Chart of Shaders](/assets/images/chart9.png)


# Recommendations
## What I Recommend to Use:

### Best Performance:
#### T0M0RR0W

### Best Quality:
#### MyFSR+

### Best Quality & Performance
#### LightFSR

### My Personal Recommendation
#### LightFSR

## Thanks for reading!
