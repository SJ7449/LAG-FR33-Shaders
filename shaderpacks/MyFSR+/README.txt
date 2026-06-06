MyFSR 480->1080 shaderpack
=========================

Files:
- shaders/final.fsh : fragment shader that upscales from 854x480 to 1920x1080 and applies a basic sharpen.

Usage:
1. Put this zip into your Minecraft 'shaderpacks' folder (e.g. ~/.minecraft/shaderpacks/).
2. Ensure your launcher/mod renders the game at 854x480 (render resolution ~44% of 1080p).
   - With OptiFine: adjust 'renderDistance' and 'internal resolution' via shader/mod settings or use a launcher that can force internal resolution.
   - With Iris+Sodium: use a mod/setting to set internal render scale to 0.44 (or render at 854x480).
3. In Minecraft, enable the shader and enjoy upscaled output.
4. Tweak sharpness in 'final.fsh' if needed.

Notes:
- This is a lightweight, experimental upscaler (not full AMD FSR). Quality won't match DLSS/FSR2 but is much better than simple bilinear when upscaling from 480p.
- For best results, use with Iris shader support or OptiFine-compatible shader loaders.
