/*
 * Copyright (C) 2016 The CyanogenMod Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.lineageos.settings.device;

import java.util.HashMap;
import java.util.Map;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

public class Constants {

    // Swap keys
    public static final String FP_HOME_KEY = "fp_home";

    // List of keys
    public static final String FP_KEYS = "fp_keys";

    // Wakeup key
    public static final String FP_HOME_WAKEUP_KEY = "fp_home_wakeup";

    // Swap nodes
    public static final String FP_HOME_NODE = "/sys/homebutton/enable";

    // Keys nodes
    public static final String FP_KEYS_NODE = "/sys/homebutton/key";

    // Wakeup node
    public static final String FP_HOME_WAKEUP_NODE = "/sys/homebutton/enable_wakeup";

    // Holds <preference_key> -> <proc_node> mapping
    public static final Map<String, String> sBooleanNodePreferenceMap = new HashMap<>();

    // Holds <preference_key> -> <default_values> mapping
    public static final Map<String, Object> sNodeDefaultMap = new HashMap<>();

    public static final String[] sButtonPrefKeys = {
        FP_HOME_KEY,
        FP_HOME_WAKEUP_KEY,
        FP_KEYS,
    };

    static {
        sBooleanNodePreferenceMap.put(FP_HOME_KEY, FP_HOME_NODE);
        sBooleanNodePreferenceMap.put(FP_KEYS, FP_KEYS_NODE);
        sBooleanNodePreferenceMap.put(FP_HOME_WAKEUP_KEY, FP_HOME_WAKEUP_NODE);
        sNodeDefaultMap.put(FP_HOME_KEY, false);
        sNodeDefaultMap.put(FP_KEYS, "102");
        sNodeDefaultMap.put(FP_HOME_WAKEUP_KEY, false);
    }

    public static boolean isPreferenceEnabled(Context context, String key) {
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(context);
        return preferences.getBoolean(key, (Boolean) sNodeDefaultMap.get(key));
    }

    public static String GetPreference(Context context, String key) {
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(context);
        return preferences.getString(key, (String) sNodeDefaultMap.get(key));
    }
}
