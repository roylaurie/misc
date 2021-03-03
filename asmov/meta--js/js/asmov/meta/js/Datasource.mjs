'use strict';

import MetaType from './Type.mjs';

export default class MetaDatasource {
    static namepath = 'asmov/meta/js/Model';

    static methodTraits = {
        context: 'context',
        store: 'store',
        get: 'get'
    }

    static #dot = new MetaDatasource();
    static get dot { return MetaDatasource.#dot; };

    #sourcetypes = new Map();

    constructor() {
        if (typeof dot !== 'undefined') {
            throw new Error('MetaDatasource already initialized');
        }
    }

    link(sourcetype) {
        this.conforms(sourcetype);
        MetaType.conformsLink(sourcetype);
        this.#sourcetypes.set(sourcetype.namepath, sourcetype);
    }

    linked(sourcetype) {
        return this.#sourcetypes.has([sourcetype[MetaType.staticTraits.namepath]]);
    }

    conforms(sourcetype) {
        MetaType.dot.conforms(sourcetype);
        MetaType.conformsTrait(sourcetype, MetaType.dot.staticScopes.methodTrait, MetaDatasource.methodTraits.context);
        MetaType.conformsTrait(sourcetype, MetaType.dot.staticScopes.methodTrait, MetaDatasource.methodTraits.store);
        MetaType.conformsTrait(sourcetype, MetaType.dot.staticScopes.methodTrait, MetaDatasource.methodTraits.get);
        return;
    }
}

MetaType.dot.link(MetaDatasource);

