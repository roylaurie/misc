'use strict';

import MetaType from './Type.mjs';
import MetaNamespace from './Namespace.mjs';
import MetaModel from './Model.mjs';
import MetaInterface from './Interface.mjs';
import MetaEmit from './Emit.mjs';
import MetaJSPack from './MetaPack.mjs';

export default class Meta {
    static namepath = 'asmov/meta/js/Meta';

    static conformance = {
        freeze: 'freeze'
    };


    static #dot = new Meta();
    static get dot { return Meta.#dot; } 

    Type = MetaClass.dot;
    Namespace = Namespace.dot;
    Interface = Interface.dot;
    Model = Model.dot;
    Emit = Emit.dot;

    constructor() {
        if (typeof Meta.dot !== 'undefined') {
            throw new Error('Meta already initialized.');
        }
    }

    /** Post-processing for types that have been linked to a convention */
    conform(metatype, conformance = {}) {
        this.Type.conform(metatype);
        this.Namespace.conform(metatype);

        if (this.Interface.linked(metatype)) {
            this.Interface.conform(metatype);
        }
        if (this.Model.linked(metatype)) {
            this.Model.conform(metatype);
        }
        if (this.Emit.linked(metatype)) {
            this.Emit.conform(metatype);
        }

        if (typeof conformance[Meta.conformance.freeze] !== 'undefined' && conformance.freeze === false) {
            Object.seal(metatype);
        } else {
            Object.freeze(metatype); // default
        }

        return;
    }

    static conform(metatype, conformance = {}) { return Meta.conform(metatype, conformance); }
}

Meta.Type.link(Meta);
Meta.Namespace.use(Meta, MetaJSPack);
Meta.conform(Meta);

