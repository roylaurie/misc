'use strict';

import Item from './Item.mjs';
import Energy from './Energy.mjs';
import WeaponItem from './WeaponItem.mjs';
import RechargeItem from './RechargeItem.mjs';
import ItemTemplate from './ItemTemplate.mjs';
import Inventory from './Inventory.mjs';
import Equipment from './Equipment.mjs';
import ActionAttack from './ActionAttack.mjs';
import ActionEquip from './ActionEquip.mjs';
import ActionRecharge from './ActionRecharge.mjs';
import ActionPass from './ActionPass.mjs';
import ReactionShield from './ReactionShield.mjs';
import ReactionPass from './ReactionPass.mjs';
import Shuffle from './Shuffle.mjs';

export default class Character {
    #name = null;
    #omegaPoints = 4;
    #numActions = 2;
    #energy = {};
    #inventory = new Inventory();
    #equipment = new Equipment();
    #targetCharacter = null;

    constructor(name) {
        this.#name = name;

        this.#energy[Energy.types.gamma] = 6;
        this.#energy[Energy.types.chi] = 6;

        this.#equipment.add(Equipment.slots.left, ItemTemplate.weapons.pistol.create());
        this.#equipment.add(Equipment.slots.right, ItemTemplate.weapons.pistol.create());

        this.#inventory.add(ItemTemplate.rechargers.energy.create());
    }

    getName() {
        return this.#name;
    }

    getOmegaPoints() {
        return this.#omegaPoints;
    }

    getEnergy(energyType) {
        return this.#energy[energyType];
    }

    hasEnergy(energyType, minimum) {
        return this.#energy[energyType] >= minimum;
    }

    setTarget(character) {
        this.#targetCharacter = character;
    }

    getTarget() {
        return this.#targetCharacter;
    }

    inputAction() {
        const left = this.#equipment.get(Equipment.slots.left);
        const right = this.#equipment.get(Equipment.slots.right);

        let energyOptions = [];
        if (this.hasEnergy(Energy.types.gamma, 1)) {
            energyOptions.push(Energy.types.gamma);
        }
        if (this.hasEnergy(Energy.types.chi, 1)) {
            energyOptions.push(Energy.types.chi);
        }
    
        let hasEnergy = (energyOptions.length > 0);

        let itemOptions = [];
        if (!left.isExhausted() && ( (hasEnergy && left instanceof WeaponItem) || (!hasEnergy && left instanceof RechargeItem)) ) {
            itemOptions.push(left);
        }
        if (!right.isExhausted() && ( (hasEnergy && right instanceof WeaponItem) || (!hasEnergy && right instanceof RechargeItem)) ) {
            itemOptions.push(right);
        }

        let hasItem = (itemOptions.length > 0);

        if (!hasItem) {
            if (!hasEnergy) {
                if (!(left instanceof WeaponItem || right instanceof WeaponItem)) {
                    return new ActionEquip(this, Equipment.slots.left, this.#inventory.findTemplate(ItemTemplate.rechargers.energy)[0]);
                }
            }

            return new ActionPass(this);
        }

        const item = Shuffle.randomOption(itemOptions);

        if (item instanceof WeaponItem) {
            const energyType = Shuffle.randomOption(energyOptions);
            return new ActionAttack(this, this.getTarget(), item, energyType);
        } else if (item instanceof RechargeItem) {
            return new RechargeAction(this, item, Shuffle.randomOption([Energy.types.gamma, Energy.types.chi]));
        } else {
            return new ActionPass(this);
        }
    }

    inputReaction(action) {
        let energyOptions = [];
        if (this.hasEnergy(Energy.types.gamma, 1)) {
            energyOptions.push(Energy.types.gamma);
        }
        if (this.hasEnergy(Energy.types.chi, 1)) {
            energyOptions.push(Energy.types.chi);
        }
        if (energyOptions.length === 0) {
            return new ReactionPass(action, this);
        }

        const energyType = Shuffle.randomOption(energyOptions);

        return new ReactionShield(action, this, energyType);
    }

    consumeEnergy(energyType, amount) {
        if (!this.hasEnergy(energyType, amount)) {
            throw new Error('Not enough energy.');
        }

        this.#energy[energyType] -= amount;
    }

    consumeAction() {
        this.#numActions--;
    }

    initRound(round) {
        this.#numActions = 2;
        this.#equipment.initRound();
    }

    damage(amount) {
        if (this.unconscious()) {
            throw new Error('Character is already unconscious.');
        }

        this.#omegaPoints = ( this.#omegaPoints - amount < 0 ? 0 : this.#omegaPoints - amount );
    }

    conscious() {
        return this.#omegaPoints > 0;
    }

    unconscious() {
        return this.#omegaPoints < 1;
    }

    inventory() {
        return this.#inventory;
    }

    equipment() {
        return this.#equipment;
    }
}

 
