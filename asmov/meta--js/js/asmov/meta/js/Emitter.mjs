'use strict';

import MetaTrait from './Trait.mjs';
import MetaType from './Type.mjs';
import MetaModel from './Model.mjs';

export default class MetaEmitter {
    static namepath = 'asmov/meta/js/Emitter';
    static traitname = 'Emitter';

    static staticTraits = {};
    static staticMethodTraits = {};
    static methodTraits = {
        listen: 'listen'
    };
    static dataTraits = {};

    static dot = new MetaEmitter();

    #emittertypes = new Map();

    constructor() {
        if (typeof MetaEmitter.dot !== 'undefined') {
            throw new Error('MetaEmitter already initialized.');
        }
    }

    confirm(emittertype) {
        MetaType.dot.confirm(emittertype);
        MetaModel.dot.confirm(emittertype);
        MetaTrait.dot.confirmTrait(emittertype, MetaEmitter);
    }

    link(emittertype) {
        this.confirm(emittertype);
        this.#emittertypes.set(emittertype.namepath, emittertype);
    }


    linked(emittertype) {
        return this.#emittertypes.has(emittertype.namepath);
    }

    confirmLink(nametype) {
        if (!this.linked(nametype)) {
            throw new Error(`${nametype.namepath} is not link()'ed to MetaType`);
        }

        return;
    }

    conform(emittertype) {
        this.confirm(emittertype);
        this.confirmLink(emittertype);
        return;
    }

    get(namepath) {
        if (!this.#emittertypes.has(namepath)) {
            throw new Error(`${namepath} namepath unknown`);
        }

        return this.#emittertypes.get(namepath);
    }
}

MetaTrait.dot.link(MetaEmitter);
MetaType.dot.link(MetaEmitter);
