'use strict';

import Meta from '../asmov/meta/Meta.mjs';
import MetaModel from '../asmov/meta/Model.mjs';
import GalacksiPack from '../asmov/galacksi/MetaPack.mjs';

export default class Event {
    static namepath = 'asmov/galacksi/Event';

    static dataKeys = {
        timestamp: 'timestamp'
    };

    #timestamp = null;
    #id = null;

    constructor(timestamp, id) {
        this.#timestamp = timestamp || Date.UTC();
        this.#id = id || ModelMeta.id32(this, [ this.#timestamp ]);
    }

    id() {
        return this.#id;
    }

    getTimestamp() {
        return this.#timestamp;
    }

    data() {
        return {
            ModelMeta.dataKeys.namepath: this.constructor.namepath,
            Event.dataKeys.timestamp: this.#timestamp
        };
    }
}

Meta.link(GalacksiPack, Event);
