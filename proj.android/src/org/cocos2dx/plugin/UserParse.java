package org.cocos2dx.plugin;

import java.util.Hashtable;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.parse.Parse;
import com.parse.ParseUser;
import com.parse.ParseTwitterUtils;
import com.parse.ParseException;
import com.parse.LogInCallback;

public class UserParse implements InterfaceUser {

    private static final String LOG_TAG = "UserParse";
    private static Activity mActivity = null;
    private static boolean bDebug = false;

    protected static void LogE(String msg, Exception e) {
        Log.e(LOG_TAG, msg, e);
        e.printStackTrace();
    }

    protected static void LogD(String msg) {
        if (bDebug) {
            Log.d(LOG_TAG, msg);
        }
    }

    public UserParse(Context context) {
        mActivity = (Activity)context;
    }

    @Override
    public void configDeveloperInfo(Hashtable<String, String> devInfo) {
        String appId = devInfo.get("ApplicationID");
        String clientKey = devInfo.get("ClientKey");
        String consumerKeyTw = devInfo.get("TwitterConsumerKey");
        String consumerSecretTw = devInfo.get("TwitterConsumerSecret");
        Parse.initialize(mActivity, appId, clientKey);
        ParseTwitterUtils.initialize(consumerKeyTw, consumerSecretTw);
    }

    @Override
    public void login() {
        final InterfaceUser that = this;
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                ParseTwitterUtils.logIn(mActivity, new LogInCallback() {
                    public void done(ParseUser user, ParseException e) {
                        if (e == null && user != null) {
                            UserWrapper.onActionResult(that, UserWrapper.ACTION_RET_LOGIN_SUCCEED, user.getUsername());
                        } else if (user == null) {
                            UserWrapper.onActionResult(that, UserWrapper.ACTION_RET_LOGIN_FAILED, "usernameOrPasswordIsInvalid");
                        } else {
                            UserWrapper.onActionResult(that, UserWrapper.ACTION_RET_LOGIN_FAILED, "somethingWentWrong");
                        }
                    }
                });
            }
        });
    }

    @Override
    public void logout() {
    }

    @Override
    public boolean isLogined() {
        return false;
    }

    @Override
    public String getSessionID() {
        return "";
    }

    @Override
    public void setDebugMode(boolean debug) {
        bDebug = debug;
    }

    @Override
    public String getSDKVersion() {
        return "1.5.1";
    }

    @Override
    public String getPluginVersion() {
        return "0.0.1";
    }

}
