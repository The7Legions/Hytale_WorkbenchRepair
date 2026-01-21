package com.the7legions.hytale;

import com.hypixel.hytale.server.core.event.events.ecs.UseBlockEvent;
import com.hypixel.hytale.server.core.plugin.JavaPlugin;
import com.hypixel.hytale.server.core.plugin.JavaPluginInit;
import com.the7legions.hytale.events.ecs.PlayerUseBlockEventSystem;

import javax.annotation.Nonnull;

public class WorkbenchRepair extends JavaPlugin {

    public WorkbenchRepair(@Nonnull JavaPluginInit init) {
        super(init);
    }

    @Override
    protected void setup() {
        this.getEntityStoreRegistry().registerSystem(new PlayerUseBlockEventSystem(UseBlockEvent.Pre.class));
    }
}