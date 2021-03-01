'use strict';

import ItemTemplate from './ItemTemplate.mjs';

export default class Item {
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

 
