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

    getCharactersAlive() {
        const aliveCharacters = [];
        for (let i = 0; i < this.#characters.length; ++i) {
            if (this.#characters[i].alive()) {
                aliveCharacters.push(this.#characters[i]);
            }
        }

        return aliveCharacters;
    }

    getNumCharactersAlive() {
        let alive = 0;
        for (let i = 0; i < this.#characters.length; ++i) {
            if (this.#characters[i].alive()) {
                ++alive; 
            }
        }

        return alive;
    }

    start() {
        while (this.getNumCharactersAlive() > 1) {
            this.#currentRound = new Round(this);
            this.#rounds.push(this.#currentRound);

            console.log('Round starting ...');
            for (let i = 0; i < this.#characters.length; ++i) {
                const c = this.#characters[i];
                c.initRound(this.#currentRound);

                const o = { omega: c.getOmegaPoints(), energy: { gamma: c.getEnergy(Energy.types.gamma), chi: c.getEnergy(Energy.types.chi) } };
                console.log(c.getName(), o);
            }

            this.#currentRound.start();
        }
    }
};

class Energy {
    static types = {
        gamma: 0,
        chi: 1
    };
}

class Character {
    #name = null;
    #omegaPoints = 4;
    #numActions = 2;
    #itemsUsed = [];
    #energy = {};
    #inventory = new Inventory();
    #activeInventory = new ActiveInventory();
    #targetCharacter = null;

    constructor(name) {
        this.#name = name;
        this.#energy[Energy.types.gamma] = 6;
        this.#energy[Energy.types.chi] = 6;
        this.#activeInventory.add(ActiveInventory.places.leftHand, new Item(Assets.items.pistol));
        this.#activeInventory.add(ActiveInventory.places.rightHand, new Item(Assets.items.pistol));
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

    setTarget(character) {
        this.#targetCharacter = character;
    }

    getTarget() {
        return this.#targetCharacter;
    }

    itemUsed(item) {
        return ( typeof this.#itemsUsed[item] !== 'undefined' && this.#itemsUsed[item] > 0 );
    }

    inputAction() {
        const leftHand = this.#activeInventory.get(ActiveInventory.places.leftHand);
        const rightHand = this.#activeInventory.get(ActiveInventory.places.rightHand);

        let item = null;
        if (!this.itemUsed(leftHand)) {
            item = leftHand;
        } else if (!this.itemUsed(rightHand)) {
            item = rightHand;
        } else {
            return new ActionPass(this);
        }


        let energyType = null;
        if (this.#energy[Energy.types.gamma] > 0) {
            energyType = Energy.types.gamma;
        } else if (this.#energy[Energy.types.chi] > 0) {
            energyType = Energy.types.chi;
        } else {
            return new ActionPass(this);
        }

        return new ActionAttack(this, this.getTarget(), this.#activeInventory.get(ActiveInventory.places.leftHand), energyType);
    }

    inputReaction(action) {
        let shieldEnergyType = null;
        if (this.#energy[Energy.types.gamma] > 0) {
            shieldEnergyType = Energy.types.gamma;
        } else if (this.#energy[Energy.types.chi] > 0) {
            shieldEnergyType = Energy.types.chi;
        } else {
            return new ReactionPass(action, this);
        }

        return new ReactionShield(action, this, shieldEnergyType);
    }

    consumeEnergy(energyType, amount) {
        if (this.#energy[energyType] < amount) {
            throw new Error('Not enough energy.');
        }

        this.#energy[energyType] -= amount;
    }

    consumeItemUse(item) {
        if (typeof this.#itemsUsed[item] !== 'undefined' || this.#itemsUsed[item] > 0) {
            throw new Error('Item already used this round.');
        }

        this.#itemsUsed[item] = 1;
    }

    consumeAction() {
        this.#numActions--;
    }

    initRound(round) {
        this.#itemsUsed = [];
        this.#numActions = 2;
    }

    damage(amount) {
        if (this.dead()) {
            throw new Error('Character is already dead.');
        }

        this.#omegaPoints = ( this.#omegaPoints - amount < 0 ? 0 : this.#omegaPoints - amount );
    }

    alive() {
        return this.#omegaPoints > 0;
    }

    dead() {
        return this.#omegaPoints < 1;
    }
}

class ItemType {
    #name = null;

    constructor(name) {
        this.#name = name;
    }

    getName() {
        return this.#name;
    }
}

class Item {
    #itemType = null;

    constructor(itemType) {
        this.#itemType = itemType;
    }

    getName() {
        return this.#itemType.getName();
    }
}

class Inventory {
    #items = [];

    add(item) {
        this.#items.push(item);
    }

    getItems() {
        return this.#items;
    }
}

class ActiveInventory {
    static places = {
        leftHand: 0,
        rightHand: 1
    };

    #items = [];

    constructor() {
        for (const place in ActiveInventory.places) {
            this.#items[ActiveInventory.places[place]] = null;
        }
    }

    add(place, item) {
        if (this.#items[place] !== null) {
            throw new Error('Item already in place.');
        }

        this.#items[place] = item; 
    }

    remove(place) {
        if (this.#items[place] === null) {
            throw new Error('No item in place.');
        }

        const item = this.#items[place];
        this.#items[place] = null;
        return item;
    }

    get(place) {
        if (this.#items[place] === null) {
            throw new Error('No item in place.');
        }

        return this.#items[place];
    }
}

class Weapon extends Item {
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
            if (!character.alive()) {
                continue;
            }

            const action1 = character.inputAction();
            const action2 = character.inputAction();

            action1.act();

            if (this.#game.getNumCharactersAlive() == 1) {
                this.end();
                return;
            }

            action2.act();

            if (this.#game.getNumCharactersAlive() == 1) {
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
    #actionCharacter = null;

    constructor(actionCharacter) {
        this.#actionCharacter = actionCharacter;
    }

    getActionCharacter() {
        return this.#actionCharacter;
    }

    act() {
    }
}

class Reaction {
    #action = null;
    #reactionCharacter = null;

    constructor(action, reactionCharacter) {
        this.#action = action;
        this.#reactionCharacter = reactionCharacter;
    }

    getReactionCharacter() {
        return this.#reactionCharacter;
    }
    
    getAction() {
        return this.#action;
    }

    react() {
    }
}

class ReactionPass extends Reaction {
    constructor(action, reactionCharacter) {
        super(action, reactionCharacter);
    }

    react() {
        super.react();
        const action = this.getAction();
        const reactor = this.getReactionCharacter();

        if (action instanceof ActionAttack) {
            reactor.damage(1, action.getWeaponItem(), action.getActionCharacter());
            console.log(reactor.getName(), 'was hit!');
        }
    }
}

class ReactionShield extends Reaction {
    #shieldEnergyType = null;

    constructor(action, reactionCharacter, shieldEnergyType) {
        super(action, reactionCharacter);
        this.#shieldEnergyType = shieldEnergyType;
    }

    react() {
        super.react();
        const action = this.getAction();
        const reactor = this.getReactionCharacter();

        if (action instanceof ActionAttack) {
            if (this.#shieldEnergyType === action.getEnergyType()) {
                try {
                    reactor.consumeEnergy(this.#shieldEnergyType, 1);
                    console.log(reactor.getName(), 'blocked the shot.');
                } catch(e) {
                    reactor.damage(1, action.getWeaponItem(), action.getActionCharacter());
                    console.log(reactor.getName(), 'was hit!');
                }
            } else {
                reactor.damage(1, action.getWeaponItem(), action.getActionCharacter());
                console.log(reactor.getName(), 'was hit!');
            }
        }
    }
}

class ActionAttack extends Action {
    #targetCharacter = null;
    #weaponItem = null;
    #energyType = null;

    constructor(actionCharacter, targetCharacter, weaponItem, energyType) {
        super(actionCharacter);

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
        const actor = this.getActionCharacter();

        actor.consumeAction();
        actor.consumeEnergy(this.#energyType, 1);

        console.log(actor.getName(), 'fires', this.#weaponItem.getName(), 'at', this.#targetCharacter.getName());

        const targetReaction = this.#targetCharacter.inputReaction(this);
        targetReaction.react();
    }
}

class ActionPass extends Action {
    constructor(actionCharacter) {
        super(actionCharacter);
    }

    act() {
    }
}

class GamePhase {
}

class Assets {
    static items = {
        pistol: new ItemType('pistol')
    }
}


const game = new Game();
game.start();
