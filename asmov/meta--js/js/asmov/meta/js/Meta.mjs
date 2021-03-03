'use strict';

import MetaClass from './Class.mjs';
import MetaNamespace from './Namespace.mjs';
import MetaModel from './Model.mjs';
import MetaInterface from './Interface.mjs';
import MetaEmit from './Emit.mjs';
import MetaJSPack from './MetaPack.mjs';

export default class Meta {
    static namepath = 'asmov/Meta';

    static #dot = new Meta();
    static get dot { return this.#dot; } 

    Class = MetaClass.dot;
    Namespace = Namespace.dot;
    Model = Model.dot;
    Interface = Interface.dot;
    Emit = Emit.dot;

    constructor() {
        if (typeof Meta.dot !== 'undefined') {
            throw new Error('Meta already initialized.');
        }
    }
}

Meta.Class.link(MetaJSPack, Meta);
