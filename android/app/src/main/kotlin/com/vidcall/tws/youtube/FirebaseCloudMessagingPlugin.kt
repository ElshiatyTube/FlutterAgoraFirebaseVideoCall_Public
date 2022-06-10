package com.vidcall.tws.youtube

import io.flutter.plugin.common.PluginRegistry

object FirebaseCloudMessagingPlugin {
    fun registerWith(pluginRegistry: PluginRegistry)
    {
        if(alreadyRegisterWith(pluginRegistry)) return
        registerWith(pluginRegistry)
    }

    private fun alreadyRegisterWith(pluginRegistry: PluginRegistry): Boolean {
        val key = FirebaseCloudMessagingPlugin::class.java.canonicalName
        if(pluginRegistry.hasPlugin(key)) return  true;
        pluginRegistry.registrarFor(key)
        return  false;
    }
}