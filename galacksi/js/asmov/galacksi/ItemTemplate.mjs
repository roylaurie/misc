'use strict';

import Item from './Item.mjs';
import WeaponItem from './WeaponItem.mjs';
import RechargeItem from './RechargeItem.mjs';

export default class ItemTemplate {
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
            return new WeaponItem(this.#name);
        case RechargeItem:
            return new RechargeItem(this.#name);
        default:
            return new Item(this.#name);
        }
    }
}

 
