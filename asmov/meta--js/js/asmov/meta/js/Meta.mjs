'use strict';

export default class Meta {
    static namepath = 'asmov/Meta';

    /* singleton */
    static dot = new Meta();

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
        if (typeof Meta.dot !== 'undefined') {
            throw new Error('Meta already initialized.');
        }
    }

    /** Registers a class with the Meta library. Validates basic interace. Linked against a namespace defining MetaPack. **/
    link(packClass, _class) {
        if (typeof _class.namepath !== 'string') {
            throw new Error(_class, 'missing namepath');
        } else if (this.linked(_class)) {
            throw new Error(_class, 'already linked');
        }

        if (typeof _class.namespace === 'string' && packClass === _class) {
            this.#packs[packClass.namespace] = new packClass();
        }

        this.#classes[_class.namepath] = _class;
        this.#packNamepaths[packClass.namespace].push(_class.namepath);
    }

    static link(_class) { Meta.dot.link(_class); }

    /** Determines whethere a class has been linked to the Meta library or not. **/
    linked(_class) {
        return ( this.#classes[_class.namepath] === _class || this.#interfaces[_class.namepath] );
    }

    static linked(_class) { return Meta.dot.linked(_class); }

    /** Links a MetaPack class to the Meta library. Initializes a psuedo-singleton instance of the Pack. If link() is called with this same valid MetaPack as both parameters, package linking occurs. **/
    linkPack(packClass) {
        if (typeof this.#packs[_class.namespace] !== 'undefined') {
            throw new Error(_class.namespace + ' pack already linked';
        }

        this.link(packClass, packClass);
    }

    /** Determines whether a MetaPack has been registered and linked or not. **/
    packLinked(_class) {
        return (typeof this.#packs[_class.namespace] !== 'undefined') {
    }

    /** Retrieves the Pack singleton for the specified class **/
    pack(_class) {
        if (typeof this.#packs[_class.namespace] !== 'undefined') {
            throw new Error(_class.namespace + ' pack already linked';
        }

        return this.#packs[_class.namespace];
    }

    /** Determines whether a class has been linked or not. **/
    isClass(_class) {
        return ( this.#classes[_class.namepath] === _class );
    }

    static isClass(_class) { return Meta.dot.isClass(_class); }

    /** Retrieves the class linked for the given namespace **/
    get(namepath) { // todo: throw error
        return this.#classes[namepath];
    }

    static get(namepath) { return Meta.dot.get(namepath); }
}
