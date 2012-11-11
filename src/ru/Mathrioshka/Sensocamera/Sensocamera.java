package ru.Mathrioshka.Sensocamera;

import android.app.Activity;
import android.os.Bundle;
import org.apache.cordova.*;

public class Sensocamera extends DroidGap
{
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        super.loadUrl("file:///android_asset/www/index.html");
    }
}

