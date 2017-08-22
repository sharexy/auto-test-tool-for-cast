package com.vizio.vue.launcher.test;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import com.android.uiautomator.core.*;
import com.android.uiautomator.testrunner.UiAutomatorTestCase;

import android.os.Bundle;
import android.util.Log;

public class TestSmartCast extends UiAutomatorTestCase
{
	public void powerTestDemo() throws UiObjectNotFoundException
	{

		/* initialize variables */
		/*---------------------------------------------------------------------------*/
		Bundle deviceName = getParams();
		String deviceNameValue = null;
		Bundle restURL = getParams();
		String restURLValue = null;
		// Bundle status = getParams();
		// String statusValue = null;

		String tag = new String("com.vizio.vue.launcher.test");
		String packageName = new String("com.vizio.vue.launcher");
		String activity = new String(".activities.InitializationActivity");
		String component = packageName + "/" + activity;

		System.out.println("begin test");
		Log.d(tag, "begin test");

		/* get device name from the arguments */
		if (deviceName.getString("deviceName") != null) {
			deviceNameValue = deviceName.getString("deviceName");

		} else {
			System.out.println("end test. fail::did not get the device name!");
			Log.e(tag, "fail::did not get the device name!");
			System.exit(0);

		}

		/* get rest URI from the arguments */
		if (restURL.getString("restURL") != null) {
			restURLValue = restURL.getString("restURL");

		} else {
			System.out.println("end test. fail::did not get the rest URL!");
			Log.e(tag, "fail::did not get the rest URL!");
			System.exit(0);

		}

		/*---------------------------------------------------------------------------*/

		/* start the activity */
		/*---------------------------------------------------------------------------*/
		UiObject packageUiObject = new UiObject(new UiSelector().className("android.widget.FrameLayout").packageName(packageName));

		if (packageUiObject.exists()) {
			try {
				Log.d(tag, "stop " + packageName);
				Runtime.getRuntime().exec("am force-stop " + packageName);

				sleep(5000);

			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();

			}

		}

		try {
			Log.d(tag, "start " + packageName);
			Runtime.getRuntime().exec("am start -n " + component);

			sleep(5000);

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();

		}

		/*---------------------------------------------------------------------------*/

		/* choose device to control */
		/*---------------------------------------------------------------------------*/
		UiObject deviceControl = new UiObject(new UiSelector().className("android.widget.Button").resourceId("com.vizio.vue.launcher:id/button_castabledevices"));
		// Log.d(tag, "device control=" + deviceControl.getText());

		deviceControl.clickAndWaitForNewWindow();

		UiObject deviceNameItem = new UiObject(new UiSelector().className("android.widget.TextView").resourceId("com.vizio.vue.launcher:id/text").text(deviceNameValue));
		if (deviceNameItem.exists()) {
			deviceNameItem.longClick();
			sleep(5000);

			UiObject pairingTitle = new UiObject(new UiSelector().className("android.widget.TextView").resourceId("com.vizio.vue.launcher:id/title"));

			/* pairing */
			/*---------------------------------------------------------------------------*/
			if (pairingTitle.exists()) {
				if ("Device Pairing".equals(pairingTitle.getText())) {
					UiObject yesButton = new UiObject(new UiSelector().className("android.widget.FrameLayout").resourceId("com.vizio.vue.launcher:id/buttonDefaultPositive"));
					yesButton.click();

					while ("Device Pairing".equals(pairingTitle.getText())) {
						sleep(5000);

					}

				}

				/* get pin code */
				/*---------------------------------------------------------------------------*/
				Process process = null;
				BufferedReader reader = null;
				String line = null;
				String pin = null;

				try {
					process = Runtime.getRuntime().exec("curl --request GET --url " + restURLValue + " --insecure ");
					sleep(10000);
					process = Runtime.getRuntime().exec("curl --request GET --url " + restURLValue + " --insecure ");
					sleep(50000);

					reader = new BufferedReader(new InputStreamReader(process.getInputStream()));

					while ((line = reader.readLine()) != null) {
						Log.d(tag, line);
						if (line.indexOf("***** PIN =") >= 0) {
							pin = line.substring(line.indexOf("=") + 1, line.indexOf("=") + 1 + 4);

						}
					}

					reader.close();

					if (pin == null) {
						System.out.println("end test. fail::did not get pin code!");
						Log.e(tag, "fail::did not get pin code!");
						System.exit(0);

					} else {
						Log.d(tag, "pin=" + pin);

					}

				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

				if ("Pair Process".equals(pairingTitle.getText())) {
					UiObject text = new UiObject(new UiSelector().className("android.widget.EditText").resourceId("com.vizio.vue.launcher:id/popup_edittext"));
					text.setText(pin);
					sleep(5000);

					UiObject yesButton = new UiObject(new UiSelector().className("android.widget.FrameLayout").resourceId("com.vizio.vue.launcher:id/buttonDefaultPositive"));
					yesButton.click();
					sleep(5000);

				}

			}

		} else {
			System.out.println("end test. fail::did not get device name!");
			Log.e(tag, "fail::did not get device name!");
			System.exit(0);

		}

		/* test */
		/*---------------------------------------------------------------------------*/

		sleep(30000);

		UiObject power = new UiObject(new UiSelector().className("android.widget.FrameLayout").resourceId("com.vizio.vue.launcher:id/button_power").childSelector(new UiSelector().className("android.widget.RelativeLayout").resourceId("com.vizio.vue.launcher:id/button_root_layout")));

		power.longClick();

		System.out.println("end test");
		Log.d(tag, "end test");

	}
}
