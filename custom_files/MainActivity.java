package net.smwstuff.supermariowar;

import org.libsdl.app.SDLActivity;

public class MainActivity extends SDLActivity {
    protected String[] getLibraries() {
        return new String[] {
            "SDL2",
            "SDL2_image",
            "SDL2_mixer",
            "enet",
            "yaml-cpp",
            "main"
        };
    }
}
