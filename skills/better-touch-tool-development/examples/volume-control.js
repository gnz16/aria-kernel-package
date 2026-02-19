// volume-control.js
// Description: A script to adjust volume and display it on a BTT widget/HUD
// Usage: Copy this into a 'Run Real JavaScript' action in BTT.

(async () => {

    // 1. Get current volume (0-100)
    // Note: BTT might not have a direct 'get volume' function in JS without AppleScript, 
    // but let's assume we want to SET it or toggle it for this example.

    // Let's use AppleScript via JS to get the volume reliably
    let currentVolScript = `output volume of (get volume settings)`;
    let currentVol = await callBTT('runAppleScript', { script: currentVolScript });

    currentVol = parseInt(currentVol);

    // 2. Increase Volume by 10%
    let newVol = currentVol + 10;
    if (newVol > 100) newVol = 100;

    // 3. Set the new volume
    let setVolScript = `set volume output volume ${newVol}`;
    await callBTT('runAppleScript', { script: setVolScript });

    // 4. Update a Widget with the new Volume (if you have one with UUID 'YOUR-WIDGET-UUID')
    // You can find the UUID by right-clicking a trigger in BTT -> Copy UUID

    // await callBTT('update_touch_bar_widget', {
    //     uuid: 'YOUR-WIDGET-UUID',
    //     text: `Vol: ${newVol}%`,
    //     background_color: '0,122,255,255' // Blue background
    // });

    // 5. Show a HUD (Heads Up Display) notification
    // Note: 'BTTShowHUD' is a hypothetical helper, BTT often uses specific actions for this.
    // Ideally, you'd trigger a named trigger that shows a HUD, or use the 'show_hud' function if available in your version.

    return `Volume set to ${newVol}%`;

})();
