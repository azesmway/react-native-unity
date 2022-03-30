using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine.UI;
using UnityEngine;

public class NativeAPI {
    [DllImport("__Internal")]
    public static extern void sendMessageToMobileApp(string message);
}

public class ButtonBehavior : MonoBehaviour
{
    public void ButtonPressed()
    {
        NativeAPI.sendMessageToMobileApp("The button has been tapped!");
    }
}