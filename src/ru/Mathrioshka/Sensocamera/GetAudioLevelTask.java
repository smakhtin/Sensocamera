package ru.Mathrioshka.Sensocamera;

import java.util.TimerTask;

public class GetAudioLevelTask extends TimerTask{

    SoundLevel soundLevel;

    GetAudioLevelTask(SoundLevel soundLevel) {
        this.soundLevel = soundLevel;
    }

    @Override
    public void run() {
        soundLevel.getAmplitude();
    }
}
