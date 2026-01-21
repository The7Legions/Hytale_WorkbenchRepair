package com.the7legions.hytale.events.ecs;

import com.hypixel.hytale.component.ArchetypeChunk;
import com.hypixel.hytale.component.CommandBuffer;
import com.hypixel.hytale.component.Ref;
import com.hypixel.hytale.component.Store;
import com.hypixel.hytale.component.query.Query;
import com.hypixel.hytale.component.system.EntityEventSystem;
import com.hypixel.hytale.server.core.asset.type.blocktype.config.BlockType;
import com.hypixel.hytale.server.core.entity.entities.Player;
import com.hypixel.hytale.server.core.event.events.ecs.UseBlockEvent;
import com.hypixel.hytale.server.core.universe.PlayerRef;
import com.hypixel.hytale.server.core.universe.Universe;
import com.hypixel.hytale.server.core.universe.world.storage.EntityStore;
import org.checkerframework.checker.nullness.compatqual.NonNullDecl;

public class PlayerUseBlockEventSystem extends EntityEventSystem<EntityStore, UseBlockEvent.Pre> {

    public PlayerUseBlockEventSystem(@NonNullDecl
                           Class<UseBlockEvent.Pre> eventType) {
        super(eventType);
    }

    public Player player;
    public BlockType blockType;

    @Override
    public void handle(int index,
                       @NonNullDecl ArchetypeChunk<EntityStore> archetypeChunk,
                       @NonNullDecl Store<EntityStore> store,
                       @NonNullDecl CommandBuffer<EntityStore> commandBuffer,
                       @NonNullDecl UseBlockEvent.Pre useBlockEvent) {
        Ref<EntityStore> ref = archetypeChunk.getReferenceTo(index);
        player = store.getComponent(ref, Player.getComponentType());
        blockType = useBlockEvent.getBlockType();
        doRepair(ref, player, store);
    }

    private void doRepair(Ref<EntityStore> ref, Player player, Store<EntityStore> store) {
        var inventory = player.getInventory().getCombinedEverything();
        if (!blockType.equals(BlockType.fromString("Bench_WorkBench"))) {
            return;
        }
        for (short i=0; i<inventory.getCapacity(); i++) {
            var itemStack = inventory.getItemStack(i);
            if (itemStack != null && itemStack.getMaxDurability() > 0 && itemStack.getDurability() < itemStack.getMaxDurability()) {
                player.updateItemStackDurability(
                        ref,
                        itemStack,
                        inventory,
                        i,
                        itemStack.getMaxDurability(),
                        store
                );
            }
        }
    }

    @Override
    public Query<EntityStore> getQuery() {
        return PlayerRef.getComponentType();
    }
}