package com.the7legions.hytale;

import com.hypixel.hytale.server.core.event.events.ecs.UseBlockEvent;
import com.hypixel.hytale.server.core.plugin.JavaPlugin;
import com.hypixel.hytale.server.core.plugin.JavaPluginInit;
import com.hypixel.hytale.server.core.util.Config;
import com.the7legions.hytale.events.ecs.PlayerUseBlockEventSystem;

import javax.annotation.Nonnull;

public class WorkbenchRepair extends JavaPlugin {

    private final Config<WorkbenchRepairConfig> config;

    public WorkbenchRepair(@Nonnull JavaPluginInit init) {
        super(init);

        config = this.withConfig("WorkbenchRepairConfig", WorkbenchRepairConfig.CODEC);
    }

    public Config<WorkbenchRepairConfig> getConfig() {
        return this.config;
    }

    @Override
    protected void setup() {
        this.getEntityStoreRegistry().registerSystem(new PlayerUseBlockEventSystem(UseBlockEvent.Pre.class, this));
        config.save();
    }
}