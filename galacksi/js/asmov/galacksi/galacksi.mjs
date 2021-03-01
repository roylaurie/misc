'use strict';

export default class Game {
    #characters = [];
    #rounds = [];
    #currentRound = null;

    constructor() {
        const p1 = new Character('Player 1');
        const p2 = new Character('Player 2');

        this.#characters.push(p1);
        this.#characters.push(p2);

        p1.setTarget(p2);
        p2.setTarget(p1);
    }

    getCharacters() {
        return this.#characters;
    }

    getConsciousCharacters() {
        const consciousCharacters = [];
        for (let i = 0; i < this.#characters.length; ++i) {
            if (this.#characters[i].conscious()) {
                consciousCharacters.push(this.#characters[i]);
            }
        }

        return consciousCharacters;
    }

    numConscious() {
        let conscious = 0;
        for (let i = 0; i < this.#characters.length; ++i) {
            if (this.#characters[i].conscious()) {
                ++conscious; 
            }
        }

        return conscious;
    }

    start() {
        let roundNum = 0;
        while (this.numConscious() > 1) {
            this.#currentRound = new Round(this);
            this.#rounds.push(this.#currentRound);

            console.log('Round #' + ++roundNum + ' starting ...');
            for (let i = 0; i < this.#characters.length; ++i) {
                const c = this.#characters[i];
                c.initRound(this.#currentRound);

                const o = { omega: c.getOmegaPoints(), energy: { gamma: c.getEnergy(Energy.types.gamma), chi: c.getEnergy(Energy.types.chi) } };
                console.log(c.getName(), o);
            }

            this.#currentRound.start();
        }

        console.log(this.getConsciousCharacters()[0].getName(), 'wins!');
        console.log('Game over');
    }
};

class Energy {
    static types = {
        gamma: 0,
        chi: 1
    };

    static names = {
        0: 'gamma',
        1: 'chi'
    };
}

class Character {
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
                    return new EquipAction(this, Equipment.slots.left, this.#inventory.findTemplate(ItemTemplate.rechargers.energy)[0]);
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

class Item {
    #itemTemplate = null;
    #exhausted = false;

    constructor(itemTemplate) {
        this.#itemTemplate = itemTemplate;
    }

    getTemplate() {
        return this.#itemTemplate;
    }

    getName() {
        return this.#itemTemplate.getName();
    }

    exhaust() {
        this.#exhausted = true;
    }

    restore() {
        this.#exhausted = false;
    }

    isExhausted() {
        return this.#exhausted;
    }
}

class WeaponItem extends Item {
    constructor(itemTemplate) {
        super(itemTemplate);
    }
}

class RechargeItem extends Item {
    constructor(itemTemplate) {
        super(itemTemplate);
    }
}

class ItemTemplate {
    static weapons = {
        pistol: new ItemTemplate(WeaponItem, 'pistol')
    };

    static rechargers = {
        energy: new ItemTemplate(RechargeItem, 'energy recharger'),
        omega: new ItemTemplate(RechargeItem, 'omega recharger')
    };

    #itemClass = null;
    #name = null;

    constructor(itemClass, name) {
        this.#itemClass = itemClass;
        this.#name = name;
    }

    getName() {
        return this.#name;
    }

    getItemClass() {
        return this.#itemClass;
    }

    create() {
        switch(this.#itemClass) {
        case WeaponItem:
            return new WeaponItem(this);
        case RechargeItem:
            return new RechargeItem(this);
        default:
            return new Item(this);
        }
    }
}

class Inventory {
    #items = [];

    add(item) {
        this.#items.push(item);
    }

    remove(item) {
        const i = this.#items.indexOf(item);
        this.#items.splice(i, 1);
        return item;
    }

    items() {
        return this.#items;
    }

    findTemplate(itemTemplate) {
        return this.#items.filter(item => { item.getTemplate() === itemTemplate });
    }
}

class Equipment {
    static slots = {
        left:   0x00,
        right:  0x01
    };

    #items = [];

    constructor() {
        for (const slot in Equipment.slots) {
            this.#items[Equipment.slots[slot]] = null;
        }
    }

    add(slot, item) {
        if (this.#items[slot] !== null) {
            throw new Error('Item already in slot.');
        }

        this.#items[slot] = item; 
    }

    remove(slot) {
        if (this.#items[slot] === null) {
            throw new Error('No item in slot.');
        }

        const item = this.#items[slot];
        this.#items[slot] = null;
        return item;
    }

    get(slot) {
        if (this.#items[slot] === null) {
            throw new Error('No item in slot.');
        }

        return this.#items[slot];
    }

    occupied(slot) {
        return this.#items[slot] === null;
    }

    initRound() {
        for (let i = 0; i < this.#items.length; ++i) {
            this.#items[i].restore();
        }
    }
}

class Position {
}

class Orientation {
}

class Round {
    #game = null;

    constructor(game) {
        this.#game = game;
    }

    start() {
        const characters = this.#game.getCharacters();
        for (let i = 0; i < characters.length; ++i) {
            const character = characters[i];
            if (!character.conscious()) {
                continue;
            }

            const action1 = character.inputAction();

            action1.act();

            if (this.#game.numConscious() == 1) {
                this.end();
                return;
            }

            const action2 = character.inputAction();
            action2.act();

            if (this.#game.numConscious() == 1) {
                this.end();
                return;
            }
        }

        this.end();
        return;
    }

    end() {
    }
}

class Turn {
}

class Action {
    #actor = null;

    constructor(actor) {
        this.#actor = actor;
    }

    getActor() {
        return this.#actor;
    }

    act() {
    }
}

class Reaction {
    #action = null;
    #reactor = null;

    constructor(action, reactor) {
        this.#action = action;
        this.#reactor = reactor;
    }

    getReactor() {
        return this.#reactor;
    }
    
    getAction() {
        return this.#action;
    }

    react() {
    }
}

class ReactionPass extends Reaction {
    constructor(action, reactor) {
        super(action, reactor);
    }

    react() {
        super.react();
        const action = this.getAction();
        const reactor = this.getReactor();

        if (action instanceof ActionAttack) {
            reactor.damage(1, action.getWeaponItem(), action.getActor());

            if (reactor.unconscious()) {
                console.log(reactor.getName(), 'passed and was knocked unconscious');
            } else {
                console.log(reactor.getName(), 'passed and was hit');
            }
        }
    }
}

class ReactionShield extends Reaction {
    #shieldEnergyType = null;

    constructor(action, reactor, shieldEnergyType) {
        super(action, reactor);
        this.#shieldEnergyType = shieldEnergyType;
    }

    react() {
        super.react();
        const action = this.getAction();
        const reactor = this.getReactor();

        if (action instanceof ActionAttack) {
            if (this.#shieldEnergyType === action.getEnergyType()) {
                try {
                    reactor.consumeEnergy(this.#shieldEnergyType, 1);
                    console.log(reactor.getName(), 'blocked the shot with a', Energy.names[this.#shieldEnergyType], 'shield');
                } catch(e) {
                    reactor.damage(1, action.getWeaponItem(), action.getActor());
                    console.log(reactor.getName(), 'was hit, failing to raise a', Energy.names[this.#shieldEnergyType], 'shield');
                }
            } else {
                reactor.damage(1, action.getWeaponItem(), action.getActor());
                console.log(reactor.getName(), 'was hit, penetrating a', Energy.names[this.#shieldEnergyType], 'shield');
            }

            if (reactor.unconscious()) {
                console.log(reactor.getName(), 'was knocked unconscious');
            }
        }
    }
}

class ActionAttack extends Action {
    #targetCharacter = null;
    #weaponItem = null;
    #energyType = null;

    constructor(actor, targetCharacter, weaponItem, energyType) {
        super(actor);

        this.#targetCharacter = targetCharacter;
        this.#weaponItem = weaponItem;
        this.#energyType = energyType;
    }

    getWeaponItem() {
        return this.#weaponItem;
    }

    getEnergyType() {
        return this.#energyType;
    }

    act() {
        super.act();
        const actor = this.getActor();

        actor.consumeAction();
        this.#weaponItem.exhaust();
        actor.consumeEnergy(this.#energyType, 1);

        console.log(actor.getName(), 'fires', this.#weaponItem.getName(), 'at', this.#targetCharacter.getName(), 'with', Energy.names[this.#energyType], 'energy');

        const targetReaction = this.#targetCharacter.inputReaction(this);
        targetReaction.react();
    }
}

class ActionRecharge extends Action {
    #rechargeItem = null;
    #energyType = null;

    constructor(actor, rechargeItem, energyType) {
        super(actor);
        this.#rechargeItem = rechargeItem;
        this.#energyType = energyType;
    }

    act() {
        if (this.#rechargeItem.isExhausted()) {
            throw new Error('Item is exhausted');
        }

        this.#rechargeItem.exhaust();
        const actor = this.getActor();
        actor.rechargeEnergy(this.#energyType, 1);
        console.log(actor.getName(), 'recharged 1', Energy.names[this.#energyType]);
    }
}

class ActionEquip extends Action {
    #activeSlot = null;
    #inventoryItem = null;

    constructor(actor, equipmentSlot, inventoryItem) {
        super(actor);
        this.#activeSlot = activeSlot;
        this.#inventoryItem = inventoryItem;
    }

    act() {
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

class ActionPass extends Action {
    constructor(actor) {
        super(actor);
    }

    act() {
        console.log(this.getActor().getName(), 'passes');
    }
}

class GamePhase {
}

class Shuffle {
    static randomOption(options) {
        if (options.length === 1) {
            return options[0];
        }

        return options[Math.floor(Math.random() * Math.floor(options.length))];
    }
}


const game = new Game();
game.start();
