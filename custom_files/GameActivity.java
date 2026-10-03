package net.smwstuff.supermariowar;

import org.libsdl.app.SDLActivity;

public final class GameActivity extends SDLActivity {
    @Override protected String[] getLibraries() {
        return new String[] { "SDL3", "SDL3_image", "SDL3_mixer", "main" };
    }
}
