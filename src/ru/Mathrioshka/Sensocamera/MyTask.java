package ru.Mathrioshka.Sensocamera;


import java.util.TimerTask;

public class MyTask extends TimerTask {

    ADKBridge bridge;
    public MyTask(ADKBridge bridge)
    {
        this.bridge = bridge;
    }

    @Override
    public void run() {
        bridge.win();
    }
}
