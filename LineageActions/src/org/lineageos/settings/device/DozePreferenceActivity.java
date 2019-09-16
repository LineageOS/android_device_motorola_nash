/*
 * Copyright (c) 2017 The LineageOS Project
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

package org.lineageos.settings.device;

import android.os.Bundle;
import android.preference.PreferenceActivity;
import androidx.preference.PreferenceCategory;
import androidx.preference.PreferenceFragment;
import android.view.MenuItem;

public class DozePreferenceActivity extends PreferenceActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getActionBar().setDisplayHomeAsUpEnabled(true);
        getFragmentManager().beginTransaction()
                .replace(android.R.id.content, new DozePreferenceFragment()).commit();
    }

    public static class DozePreferenceFragment extends PreferenceFragment {
        private static final String CATEGORY_AMBIENT_DISPLAY = "ambient_display_key";

        @Override
        public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
            addPreferencesFromResource(R.xml.doze_panel);
            boolean dozeEnabled = LineageActionsSettings.isDozeEnabled(getActivity());
            boolean aodEnabled = LineageActionsSettings.isAODEnabled(getActivity());
            PreferenceCategory ambientDisplayCat = (PreferenceCategory)
                    findPreference(CATEGORY_AMBIENT_DISPLAY);
            if (ambientDisplayCat != null) {
                ambientDisplayCat.setEnabled(dozeEnabled && !aodEnabled);
            }
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            onBackPressed();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }
}
