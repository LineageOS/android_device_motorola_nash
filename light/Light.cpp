/*
 * Copyright (C) 2017 The LineageOS Project
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

#define LOG_TAG "LightService"

#include <log/log.h>

#include "Light.h"

#include <fstream>

namespace android {
namespace hardware {
namespace light {
namespace V2_0 {
namespace implementation {

#define LEDS            "/sys/class/leds/"

#define LCD_LED         LEDS "lcd-backlight/"
#define WHITE_LED       LEDS "white/"

#define BRIGHTNESS      "brightness"
#define DUTY_PCTS       "duty_pcts"
#define START_IDX       "start_idx"
#define PAUSE_LO        "pause_lo"
#define PAUSE_HI        "pause_hi"
#define RAMP_STEP_MS    "ramp_step_ms"
#define BLINK           "blink"

/*
 * 8 duty percent steps.
 */
#define RAMP_STEPS 8
/*
 * Each step will stay on for 50ms by default.
 */
#define RAMP_STEP_DURATION 50
/*
 * Each value represents a duty percent (0 - 100) for the led pwm.
 */
static int32_t BRIGHTNESS_RAMP[RAMP_STEPS] = {0, 12, 25, 37, 50, 72, 85, 100};

/*
 * Write value to path and close file.
 */
static void set(std::string path, std::string value) {
    std::ofstream file(path);

    if (!file.is_open()) {
        ALOGE("failed to write %s to %s", value.c_str(), path.c_str());
        return;
    }

    file << value;
}

static void set(std::string path, int value) {
    set(path, std::to_string(value));
}

static uint32_t rgbToBrightness(const LightState& state) {
    uint32_t color = state.color & 0x00ffffff;
    return ((77 * ((color >> 16) & 0xff)) + (150 * ((color >> 8) & 0xff)) +
            (29 * (color & 0xff))) >> 8;
}

static void handleBacklight(const LightState& state) {
    uint32_t brightness = rgbToBrightness(state);
    set(LCD_LED BRIGHTNESS, brightness);
}

/*
 * Scale each value of the brightness ramp according to the
 * brightness of the color.
 */
static std::string getScaledRamp(uint32_t brightness) {
    std::string ramp, pad;

    for (auto const& step : BRIGHTNESS_RAMP) {
        int32_t scaledStep = (step * brightness) / 0xFF;
        ramp += pad + std::to_string(scaledStep);
        pad = ",";
    }

    return ramp;
}

static void handleNotification(const LightState& state) {
    uint32_t alpha, brightness;

    /*
     * Extract brightness from AARRGGBB.
     */
    alpha = (state.color >> 24) & 0xFF;
    brightness = rgbToBrightness(state);

    /*
     * Scale brightness if the Alpha brightness is not 0xFF.
     */
    if (alpha != 0xFF)
        brightness = (brightness * alpha) / 0xFF;

    /* Disable blinking. */
    set(WHITE_LED BLINK, 0);

    if (state.flashMode == Flash::TIMED) {
        /*
         * If the flashOnMs duration is not long enough to fit ramping up
         * and down at the default step duration, step duration is modified
         * to fit.
         */
        int32_t stepDuration = RAMP_STEP_DURATION;
        int32_t pauseHi = state.flashOnMs - (stepDuration * RAMP_STEPS * 2);
        int32_t pauseLo = state.flashOffMs;

        if (pauseHi < 0) {
            stepDuration = state.flashOnMs / (RAMP_STEPS * 2);
            pauseHi = 0;
        }

        /* Set LED */
        set(WHITE_LED START_IDX, 0 * RAMP_STEPS);
        set(WHITE_LED DUTY_PCTS, getScaledRamp(brightness));
        set(WHITE_LED PAUSE_LO, pauseLo);
        set(WHITE_LED PAUSE_HI, pauseHi);
        set(WHITE_LED RAMP_STEP_MS, stepDuration);

        /* Enable blinking. */
        set(WHITE_LED BLINK, 1);
    } else {
        set(WHITE_LED BRIGHTNESS, brightness);
    }
}

static std::map<Type, std::function<void(const LightState&)>> lights = {
    {Type::BACKLIGHT, handleBacklight},
    {Type::BATTERY, handleNotification},
    {Type::NOTIFICATIONS, handleNotification},
    {Type::ATTENTION, handleNotification},
};

Light::Light() {}

Return<Status> Light::setLight(Type type, const LightState& state) {
    auto it = lights.find(type);

    if (it == lights.end()) {
        return Status::LIGHT_NOT_SUPPORTED;
    }

    /*
     * Lock global mutex until light state is updated.
     */
    std::lock_guard<std::mutex> lock(globalLock);

    it->second(state);

    return Status::SUCCESS;
}

Return<void> Light::getSupportedTypes(getSupportedTypes_cb _hidl_cb) {
    std::vector<Type> types;

    for (auto const& light : lights) types.push_back(light.first);

    _hidl_cb(types);

    return Void();
}

}  // namespace implementation
}  // namespace V2_0
}  // namespace light
}  // namespace hardware
}  // namespace android
