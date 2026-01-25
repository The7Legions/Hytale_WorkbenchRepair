package com.the7legions.hytale;

import com.hypixel.hytale.codec.Codec;
import com.hypixel.hytale.codec.KeyedCodec;
import com.hypixel.hytale.codec.builder.BuilderCodec;

public class WorkbenchRepairConfig {
    public static final BuilderCodec<WorkbenchRepairConfig> CODEC = BuilderCodec.builder(WorkbenchRepairConfig.class, WorkbenchRepairConfig::new)
            .append(new KeyedCodec<Boolean>("AllowT1Workbench", Codec.BOOLEAN),
                    (config, value) -> config.allowT1Workbench = value, // setter
                    (config) -> config.allowT1Workbench).add()  // getter
            .append(new KeyedCodec<String[]>("Blacklist", Codec.STRING_ARRAY),
                    (config, value) -> config.blacklist = value,
                    (config) -> config.blacklist).add()
            .build();

    private boolean allowT1Workbench = false;
    private String[] blacklist = new String[0];

    public WorkbenchRepairConfig() {

    }

    public boolean getAllowT1Workbench() {
        return allowT1Workbench;
    }

    public String[] getBlacklist() {
        return blacklist;
    }

    public void setAllowT1Workbench(boolean allowT1Workbench) {
        this.allowT1Workbench = allowT1Workbench;
    }

    public void setBlacklist(String[] blacklist) {
        this.blacklist = blacklist;
    }
}
