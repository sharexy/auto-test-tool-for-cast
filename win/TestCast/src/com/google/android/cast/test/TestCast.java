
package com.google.android.cast.test;

import java.io.IOException;
import com.android.uiautomator.core.*;
import com.android.uiautomator.testrunner.UiAutomatorTestCase;
import android.os.Bundle;
import android.util.Log;

public class TestCast extends UiAutomatorTestCase
{

	public void youtubeTestDemo() throws UiObjectNotFoundException
	{

		/* initialize variables */
		/*---------------------------------------------------------------------------*/

		Bundle deviceName = getParams();
		String deviceNameValue = null;

		String tag = new String("com.google.android.cast.test");
		String packageName = new String("com.google.android.youtube");
		String activity = new String("com.google.android.apps.youtube.app.WatchWhileActivity");
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

		/*---------------------------------------------------------------------------*/

		

		/* start the activity */
		/*---------------------------------------------------------------------------*/
		UiObject packageUiObject = new UiObject(new UiSelector().className("android.widget.FrameLayout").packageName(packageName));

		if (!packageUiObject.exists()) {
			try {
				Log.d(tag, "start " + packageName);
				Runtime.getRuntime().exec("am start -n " + component);

				sleep(5000);

			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();

			}
			
		}
		/*---------------------------------------------------------------------------*/

		/* casting */
		/*---------------------------------------------------------------------------*/
		UiObject castIcon = new UiObject(new UiSelector().className("android.view.View").description("Cast"));

		if (true == castIcon.clickAndWaitForNewWindow()) {
			sleep(5000);

			UiObject deviceNameItem = new UiObject(new UiSelector().className("android.widget.TextView").text(deviceNameValue));
			UiObject stopCastButton = new UiObject(new UiSelector().className("android.widget.Button").resourceId("android:id/button1"));

			if (deviceNameItem.exists()) {
				if (stopCastButton.exists()) {
					/* do nothing, casting works */
					getUiDevice().pressBack();
					sleep(5000);

				} else {
					/* select device name, casting */
					deviceNameItem.longClick();
					sleep(10000);

				}

			} else {
				if (stopCastButton.exists()) {
					/* stop casting */
					stopCastButton.click();
					sleep(5000);

					castIcon.clickAndWaitForNewWindow();
					sleep(5000);

					deviceNameItem.longClick();
					sleep(10000);

				} else {
					System.out.println("end test. fail::did not get device name!");
					Log.e(tag, "fail::did not get device name!");
					System.exit(0);

				}

			}

		} else {
			System.out.println("end test. fail::did not get CastTo window!");
			Log.e(tag, "fail::did not get CastTo window!");
			System.exit(0);

		}

		/*---------------------------------------------------------------------------*/

		/* play video */
		/*---------------------------------------------------------------------------*/
		Log.d(tag, "play video");

		/*
		 * once video is playing in framework on the top position, play
		 */
		UiObject player = new UiObject(new UiSelector().className("android.widget.FrameLayout").index(0).childSelector(new UiSelector().className("android.view.View").description("Expand Mini Player")));
		if (player.exists()) {

		} else {/* play promoted video */
			UiObject promoted = new UiObject(new UiSelector().className("android.widget.LinearLayout").resourceId("com.google.android.youtube:id/promoted_video"));
			UiObject video = promoted.getChild(new UiSelector().className("android.widget.ImageView").resourceId("com.google.android.youtube:id/thumbnail"));

			video.longClick();
			sleep(5000);

			UiObject popup = new UiObject(new UiSelector().className("android.widget.FrameLayout").resourceId("android:id/content"));
			UiObject playIcon = popup.getChild(new UiSelector().className("android.widget.LinearLayout").resourceId("com.google.android.youtube:id/play"));

			playIcon.longClick();

		}
		sleep(5000);
		/*---------------------------------------------------------------------------*/

		/* exit the app */
		/*---------------------------------------------------------------------------*/
		Log.d(tag, "exit " + packageName);

		getUiDevice().pressBack();
		sleep(5000);
		getUiDevice().pressBack();
		sleep(5000);

		/*---------------------------------------------------------------------------*/

		System.out.println("end test");
		Log.d(tag, "end test");
	}
}
