'use strict';

import Action from './Action.mjs';
import Character from './Character.mjs';
import Inventory from './Inventory.mjs';
import Equipment from './Equipment.mjs';

export default class ActionEquip extends Action {
    #activeSlot = null;
    #inventoryItem = null;

    constructor(actor, equipmentSlot, inventoryItem) {
        super(actor);
        this.#activeSlot = activeSlot;
        this.#inventoryItem = inventoryItem;
    }

    act() {
        super.act();
        const actor = this.getActor();
        const equipment = actor.equipment();
        const inventory = actor.inventory();

        if (equipment.occupied(equipmentSlot)) {
            const equippedItem = equipment.remove(equipmentSlot);
            inventory.add(equippedItem);
        }
        
        inventory.remove(inventoryItem);
        equipment.add(equipmentSlot, inventoryItem);

        console.log(actor.getName(), 'wielded', inventoryItem.getName());
    }
}


