'use strict';

export default class MetaTrait {
    static namepath = 'asmov/meta/js/Trait';
    static traitname = 'Trait';

    /* singleton */
    static #dot = new MetaTrait();
    static get dot { return MetaTrait.#dot; }

    static schemas = {
        staticTrait: 'staticTrait',
        staticMethodTrait: 'staticMethodTrait',
        methodTrait: 'methodTrait',
        dataTrait: 'dataTrait'
    };

    /* Meta Convention: Static variables, typically immutable. e.g.; MyClass.namepath */
    static staticTraits = {
        namepath: 'namepath',
        traitname: 'traitname',
        staticTraits: 'staticTraits',
        staticMethodTraits: 'staticMethodTraits',
        methodTraits: 'methodTraits',
    };

    /* Meta Convention: Static method names. e.g.; MyClass.from() */
    static staticMethodTraits = {
        dot: 'dot',
    };

    /* Meta Convention: Method names that exist in a prototype */
    static methodTraits = {
        link: 'link',
        linked: 'linked',
        conforms: 'conforms',
        conformsLink: 'conformsLink'
        conform: 'conform',
        get: 'get'
    };

    /* Meta Convention: Variable names given to data as described by MetaModel */
    static dataTraits = {};

    /* Portable type names */
    static type = {
        bool: 'bool',
        byte: 'byte',
        uint16: 'uint16',
        uint32: 'uint32',
        uint64: 'uint64',
        uint128: 'uint128',
        int16: 'int16',
        int32: 'int32',
        int64: 'int64',
        int128: 'int128',
        ufloat16: 'ufloat16',
        ufloat32: 'ufloat32',
        ufloat64: 'ufloat64',
        ufloat128: 'ufloat128',
        float16: 'float16',
        float32: 'float32',
        float64: 'float64',
        float128: 'float128',
        utf8: 'utf8',
        utf16: 'utf16',
        utf32: 'utf32',
        map: 'map', // map<utf8, metatrait<MyClass>>
        array: 'array', // array<metatrait<MyClass>>
        metatrait: 'metatrait', // metatrait<Emitter>
        metatype: 'metatype'  // metatrait<MyClass> == metatrait<Emitter<MyClass>>
        metamodel: 'metamodel'  
    };

    #traits = new Map();

    constructor() {
        if (typeof MetaTrait.dot !== 'undefined') {
            throw new Error('MetaTrait already initialized.');
        }
    }

    conforms(metatrait) {
        for (let schema in MetaTrait.schemas) {
            if (typeof metatrait[schema] !== 'object') {
                throw new Error(`Trait schema '${schema}' missing in ${metatrait.namepath}`);
            }
        }

        for (let staticTrait in MetaTrait.staticTraits) {
            if (typeof metatrait[staticTrait] === 'undefined') {
                throw new Error(`Static trait '${staticTrait}' missing in ${metatrait.namepath}`);
            }
        }

        for (let staticMethodTrait in MetaTrait.staticMethodTraits) {
            if (typeof metatrait[staticMethodTrait] !== 'function') {
                throw new Error(`Static method trait '${staticMethodTrait}' missing in ${metatrait.namepath}`);
            }
        }

        for (let methodTrait in MetaTrait.methodTraits) {
            if (typeof metatrait.prototype[methodTrait] !== 'function) {
                throw new Error(`Method trait '${methodTrait}' missing in ${metatrait.namepath}`);
            }
        }
    }

    /** Registers a class with the MetaTrait library. Validates basic interace. Linked against a namespace defining MetaTraitPack. **/
    link(metatrait) {
        this.conforms(metatrait);
        if (this.linked(metatrait)) {
            throw new Error(`${metatrait.namepath} already linked'`);
        }

        this.#traits.set(metatrait.namepath, metatrait);
    }

    /** Determines whethere a class has been linked to the MetaTrait library or not. **/
    linked(metatrait) {
        return this.#traits.has(metatrait[MetaTrait.staticTraits.namepath]);
    }

    conformsLink(metatrait) {
        if (!this.linked(metatrait)) {
            throw new Error(`${metatrait.namepath} is not link()'ed to MetaTrait`);
        }

        return;
    }

    /** Retrieves the class linked for the given namespace **/
    get(namepath) { 
        return this.#traits[namepath]
    }

    conform(metatrait) {
        this.conformsLink(metatrait);
        return;
    }

    conformsTrait(metatrait, traitschema, trait) {
        switch(traitschema) {
        case MetaTrait.schemas.staticTrait:
            if (typeof metatrait[trait] === 'undefined') {
                throw new Error(`${metatrait[MetaTrait.staticTraits.namepath]} + ' lacks a static ${trait}() variable`);
            }
            break;
        case MetaTrait.schemas.staticMethodTrait:
            if (typeof metatrait[trait] !== 'function') {
                throw new Error(`${metatrait[MetaTrait.staticTraits.namepath]} + ' lacks a static ${trait}() function`);
            }
            break;
        case MetaTrait.schemas.methodTrait:
            if (if typeof metatrait.prototype === 'undefined' || typeof metatrait.prototype.[trait] !== 'function') {
                throw new Error(`${metatrait[MetaTrait.staticTraits.namepath]} + ' lacks a ${trait}() method`);
            }
            break;
        default:
            throw new Error(`Invalid traitschema '${traitschema}' for operation`);
        }

        return;
    }
}

MetaTrait.dot.link(MetaTrait);

