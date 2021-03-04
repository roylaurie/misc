'use strict';

import MetaType from './Type.mjs';

export default class MetaCodebase {
    static namepath = 'asmov/meta/js/Codebase';

    static staticTraits = {
        namespace: 'namespace'
    };

    static methodTraits = {
        parent: 'parent'
    };

    static #dot = new MetaCodebase();
    static get dot { return Metacodebase.#dot; } 

    #codebases = new Map();
    #metatypes = new Map();

    constructor() {
        if (typeof MetaCodebase.dot !== 'undefined') {
            throw new Error('MetaCodebase already initialized.');
        }
    }

    link(codebase) {
        this.conforms(codebase);
        if (this.linked(codebase)) {
            throw new Error(`${codebase.namepath} already has link() to MetaCodebase`);
        } else if (this.scoped(codebase)) {
            throw new Error(`${codebase.namepath} already join()'ed to a codebase`);
        }


        this.#codebases.set(codebase.namespace, codebase);
        this.#metatypes.set(codebase.namepath, codebase);
    }

    linked(codebase) {
        return this.#codebases.has(codebase[MetaType.staticTraits.namepath]);
    }

    conformsLink(codebase) {
        if (!this.linked(codebase)) {
            throw new Error(`${codebase.namepath} is not link()'ed to MetaType`);
        }

        return;
    }

    conforms(codebase) {
        MetaType.dot.conforms(codebase);
        MetaType.dot.conformsTrait(codebase, MetaType.dot.traitScopes.staticTrait, MetaCodebase.staticTraits.namespace);
        MetaType.dot.conformsTrait(codebase, MetaType.dot.traitScopes.methodTrait, MetaCodebase.methodTraits.parent);
        return;
    }

    get(namespace) {
        if (!this.#codebases.has(namespace)) {
            throw new Error(`${codebase} codebase unknown`);
        }

        return this.#codebases.get(namespace);
    }

    use(metatype, codebase) {
        MetaType.dot.conformsLink(metatype);
        this.conformsLink(codebase);
            
        if (this.scoped(metatype, codebase)) {
            throw new Error(`${metatype.namepath} already has link() to MetaCodebase`);
        }

        this.#metatypes.set(metatype.namepath, codebase); 
    }

    scoped(metatype) {
        return this.#metatypes.has(metatype[MetaType.staticTraits.namepath]);
    }

    codebase(metatype) {
        if(!this.#metatypes.has(metatype[MetaType.staticTraits.namepath])) {
            throw new Error(`${metatype[MetaType.staticTraits.namepath]} does not use() a codebase`);
        }

        return this.#metatypes.get(metatype[MetaType.staticTraits.namepath]);
    }

    conform(codebase) {
        this.conformsLink(codebase);
        return;
    }
}

MetaType.dot.link(Meta);

