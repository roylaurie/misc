'use strict';

export default class MetaClass {
    static namepath = 'asmov/MetaClass';

    /* singleton */
    static dot = new MetaClass();

    /* Static variables, typically immutable. e.g.; MyClass.namepath */
    static staticKeys = {
        namepath: 'namepath',
        namespace: 'namespace', // Pack
    };

    /* Static method names. e.g.; MyClass.from() */
    static staticMethodKeys = {
        from: 'from' // Model
    };

    /* Prototype method names. e.g.; new MyClass().data() */ 
    static methodKeys = {
        id: 'id', // Model
        identify: 'identify', // Model
        data: 'data' // Model
    };

    /* Keys passed between data() and from(). e.g.; new MyClass().data().id */
    static dataKeys = {
        namepath: 'namepath',
        id: 'id' // Model
    };

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
        map: 'map',
        array: 'array'
    };

    #packs = {};
    #packNamepaths = {};
    #classes = {};

    constructor() {
        // singleton enforcement
        if (typeof MetaClass.dot !== 'undefined') {
            throw new Error('MetaClass already initialized.');
        }
    }

    /** Registers a class with the MetaClass library. Validates basic interace. Linked against a namespace defining MetaClassPack. **/
    link(packClass, metaclass) {
        if (typeof metaclass.namepath !== 'string') {
            throw new Error(metaclass, 'missing namepath');
        } else if (this.linked(metaclass)) {
            throw new Error(metaclass, 'already linked');
        }

        if (typeof metaclass.namespace === 'string' && packClass === metaclass) {
            this.#packs[packClass.namespace] = new packClass();
        }

        this.#classes[metaclass.namepath] = metaclass;
        this.#packNamepaths[packClass.namespace].push(metaclass.namepath);
    }

    static link(metaclass) { MetaClass.dot.link(metaclass); }

    /** Determines whethere a class has been linked to the MetaClass library or not. **/
    linked(metaclass) {
        return ( this.#classes[metaclass.namepath] === metaclass || this.#interfaces[metaclass.namepath] );
    }

    static linked(metaclass) { return MetaClass.dot.linked(metaclass); }

    /** Links a MetaClassPack class to the MetaClass library. Initializes a psuedo-singleton instance of the Pack. If link() is called with this same valid MetaClassPack as both parameters, package linking occurs. **/
    linkPack(metaclass) {
        if (typeof this.#packs[metaclass.namespace] !== 'undefined') {
            throw new Error(`${metaclass.namespace} + ' pack already linked`);
        }

        this.link(metaclass, metaclass);
    }

    /** Determines whether a MetaClassPack has been registered and linked or not. **/
    packLinked() {
        return (typeof this.#packs[metaclass.namespace] !== 'undefined') {
    }

    /** Retrieves the Pack singleton for the specified class **/
    pack(metaclass) {
        if (typeof this.#packs[metaclass.namespace] !== 'undefined') {
            throw new Error(metaclass.namespace + ' pack already linked';
        }

        return this.#packs[metaclass.namespace];
    }

    /** Determines whether a class has been linked or not. **/
    isClass(metaclass) {
        return ( this.#classes[metaclass.namepath] === metaclass );
    }

    static isClass(metaclass) { return MetaClass.dot.isClass(metaclass); }

    /** Retrieves the class linked for the given namespace **/
    get(namepath) { // todo: throw error
        return this.#classes[namepath];
    }

    static get(namepath) { return MetaClass.dot.get(namepath); }

    /** Performs validation against enums, returning a default option if provided, and throwing errors on problems. **/
    select(option, enumeration, defaultOption) {
        if (typeof option === 'undefined') {
            if (typeof defaultOption === 'undefined') {
                throw new Error(`Undefined option for enum ${enumeration}`);
            } else {
                return defaultOption;
            }
        } else if (typeof enumeration[option] === 'undefined') {
            throw new Error(`Invalid option '${option}' for enum ${enumeration}`);
        }
       
        return option;
    }

    static select(option, enumeration, defaultOption) { return MetaClass.dot.select(option, enumeration, defaultOption); }
}

