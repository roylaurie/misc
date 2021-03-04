'use strict';

import MetaType from './Type.mjs';

export default class MetaSource {
    static namepath = 'asmov/meta/js/Model';

    static methodTraits = {
        context: 'context',
        store: 'store',
        get: 'get'
    }

    static #dot = new MetaSource();
    static get dot { return MetaSource.#dot; };

    #sourcetypes = new Map();

    constructor() {
        if (typeof dot !== 'undefined') {
            throw new Error('MetaSource already initialized');
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
        MetaType.conformsTrait(sourcetype, MetaType.dot.staticScopes.methodTrait, MetaSource.methodTraits.context);
        MetaType.conformsTrait(sourcetype, MetaType.dot.staticScopes.methodTrait, MetaSource.methodTraits.store);
        MetaType.conformsTrait(sourcetype, MetaType.dot.staticScopes.methodTrait, MetaSource.methodTraits.get);
        return;
    }
}

MetaType.dot.link(MetaSource);

