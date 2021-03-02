'use strict';

export default class Meta {
    static namepath = 'asmov/Meta';

    static dot = new Meta();

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
        if (typeof Meta.dot !== 'undefined') {
            throw new Error('Meta already initialized.');
        }
    }

    link(packageClass, _class) {
        if (typeof _class.namepath !== 'string') {
            throw new Error(_class, 'missing namepath');
        } else if (this.linked(_class)) {
            throw new Error(_class, 'already linked');
        }

        if (typeof _class.protocol !== 'undefined') {
            if (typeof _class.protocol !== 'object') {
                throw new Error(_class.namepath, 'has an invalid protocol object');
            }
            // format protocol object
        }

        if (typeof _class.namespace === 'string' && packClass === _class) {
            this.#packs[packClass.namespace] = new packClass();
        }

        this.#classes[_class.namepath] = _class;
        this.#packNamepaths[packClass.namespace].push(_class.namepath);
    }

    static link(_class) { Meta.dot.link(_class); }

    linked(_class) {
        return ( this.#classes[_class.namepath] === _class || this.#interfaces[_class.namepath] );
    }

    static linked(_class) { return Meta.dot.linked(_class); }

    linkPack(packClass) {
        if (typeof this.#packs[_class.namespace] !== 'undefined') {
            throw new Error(_class.namespace + ' pack already linked';
        }

        this.link(packClass, packClass);
    }

    packLinked(_class) {
        return (typeof this.#packs[_class.namespace] !== 'undefined') {
    }

    pack(_class) {
        if (typeof this.#packs[_class.namespace] !== 'undefined') {
            throw new Error(_class.namespace + ' pack already linked';
        }

        return this.#packs[_class.namespace];
    }

    isClass(_class) {
        return ( this.#classes[_class.namepath] === _class );
    }

    static isClass(_class) { return Meta.dot.isClass(_class); }

    isInterface(_class) {
        return ( this.#classes[_class.namepath] === _class && typeof _class.protocol === 'object');
    }

    static isInterface(_class) { return Meta.dot.isInterface(_class); }

    get(namepath) {
        return ( this.#interfaces[namepath] || this.#classes[namepath] );
    }

    static get(namepath) { return Meta.dot.get(namepath); }
}
