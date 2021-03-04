'use strict';

export default class MetaType {
    static namepath = 'asmov/meta/js/Type';

    /* singleton */
    static #dot = new MetaType();
    static get dot { return MetaType.#dot; }

    static traitScopes = {
        staticTrait: 'staticTrait',
        staticMethodTrait: 'staticMethodTrait',
        methodTrait: 'methodTrait',
        dataTrait: 'dataTrait'
    };

    /* Meta Convention: Static variables, typically immutable. e.g.; MyClass.namepath */
    static staticTraits = {
        staticTraits: 'staticTraits',
        staticMethodTraits: 'staticMethodTraits',
        methodTraits: 'methodTraits',
        namepath: 'namepath',
    };

    /* Meta Convention: Static method names. e.g.; MyClass.from() */
    static staticMethodTraits = {};

    /* Meta Convention: Method names that exist in a prototype */
    static methodTraits = {};

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
        map: 'map', // map<utf8, metatype<MyClass>>
        array: 'array', // array<metatype<MyClass>>
        metatrait: 'metatrait', // metatrait<Emitter>
        metatype: 'metatype'  // metatype<MyClass> == metatrait<Emitter<MyClass>>
    };

    #types = new Map();

    constructor() {
        if (typeof MetaType.dot !== 'undefined') {
            throw new Error('MetaType already initialized.');
        }
    }

    conforms(metatype) {
        if (typeof metatype[MetaType.staticTraits.namepath] !== 'string') {
            throw new Error(metatype, 'missing namepath');
        } 
    }

    /** Registers a class with the MetaType library. Validates basic interace. Linked against a namespace defining MetaTypePack. **/
    link(metatype) {
        this.conforms(metatype);
        if (this.linked(metatype)) {
            throw new Error(`${metatype.namepath} already linked'`);
        }

        this.#types.set(metatype.namepath, metatype);
    }

    /** Determines whethere a class has been linked to the MetaType library or not. **/
    linked(metatype) {
        return this.#types.has(metatype[MetaType.dataKeys.namepath]);
    }

    conformsLink(metatype) {
        if (!this.linked(metatype)) {
            throw new Error(`${metatype.namepath} is not link()'ed to MetaType`);
        }

        return;
    }

    /** Retrieves the class linked for the given namespace **/
    get(namepath) { 
        return this.#types[namepath]
    }

    conform(metatype) {
        this.conformsLink(metatype);
        return;
    }

    conformsTrait(metatype, traitscope, trait) {
        switch(traitscope) {
        case MetaType.traitScopes.staticTrait:
            if (typeof metatype[trait] === 'undefined') {
                throw new Error(`${metatype[MetaType.staticTraits.namepath]} + ' lacks a static ${trait}() variable`);
            }
            break;
        case MetaType.traitScopes.staticMethodTrait:
            if (typeof metatype[trait] !== 'function') {
                throw new Error(`${metatype[MetaType.staticTraits.namepath]} + ' lacks a static ${trait}() function`);
            }
            break;
        case MetaType.traitScopes.methodTrait:
            if (if typeof metatype.prototype === 'undefined' || typeof metatype.prototype.[trait] !== 'function') {
                throw new Error(`${metatype[MetaType.staticTraits.namepath]} + ' lacks a ${trait}() method`);
            }
            break;
        default:
            throw new Error(`Invalid traitscope '${traitscope}' for operation`);
        }

        return;
    }
}

MetaType.dot.link(MetaType);
