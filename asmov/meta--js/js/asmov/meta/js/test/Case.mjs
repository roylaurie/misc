'use strict';

import Meta from '../Meta.mjs';
import MetaJSCodebase from '../MetaCodebase.mjs';
import TestTrait from '../traits/Test.mjs';

export default class MetaTest {
    static namepath = 'test/asmov/meta/js/test/Test';

    static EventEnum = MetaEvent.enumerate(
        { namepath: 'namepath', testMethod: 'testMethod', error: 'error' }, {
        );

    static fixtures = {};

    static async testAll(test) {
        test.#emit(MetaUnitTestEvent.types.testingUnit);

        // for each test function
            test.#emit(MetaUnitTestEvent.testingMethod, testMethod);
            //   call test function
            test.#emit(MetaUnitTestEvent.types.methodTestPass, testMethod);

        test.#emit(MetaUnitTestEvent.types.unitTestPass);
    }

    namepath = MetaUnitTest.namepath;
    #emitter = null;
    #emitterChannel = Symbol();
    #unit = MetaUnitTest;

    constructor() {
        this.#emitter = new Emitter(this.#emitterChannel, [ MetaUnitTestEvent ]);
    }

    listener() {
        return this.#emitter.listener(this.#emitterChannel);
    }

    setup() {}

    async test() {
        this.setup();
        const result = await MetaUnitTest.testAll(this);
        this.teardown();
        return result;
    }

    async asyncTest() {
        const self = this;
        return new Promise(() => { self.setup(); }).then(()=> {
            MetaUnitTest.testAll(this).finally(()=> {
                this.teardown();
            });
        });
    }

    async test_myFunction() {

    }

    teardown() {
        this.#emitter.shutdown();
    }

    unit() {
        return this.#unit;
    }

    #emit(eventType, namepath, testMethod = null) {
        this.#emitter.emit(new MetaUnitTestEvent(eventType, this.#unit.namepath, testMethod));
    }
}

export class MetaUnitTestEvent extends EmitterEventEnum {
    static namepath = 'asmov/meta/js/types/UnitTest//MetaUnitTestEvent';

    static types = {
        testingUnit: 'testingUnit',
        testingMethod: 'testingMethod',
        methodTestPass: 'methodTestPass',
        methodTestFail: 'methodTestFail',
        unitTestPass: 'unitTestPass',
        unitTestFail: 'unitTestFail'
    };

    static dataKeys = {
        ...EmitterEventEnum.dataKeys,
        namepath: 'namepath',
        testMethod: 'testMethod',
        error: 'error'
    };

    static from(data, source = null) { return EmitterEventFrom.from(data, source); }

    namepath = MetaUnitTestEvent.namepath;

    constructor(type, namepath, testMethod = null, error = null) {
        super(type, { namepath: namepath, testMethod: testMethod, error: error});
    }
}

Meta.link(MetaUnitTest, [
    [ Meta.meta.namespace, MetaJSCodebase ],
    [ Meta.meta.conforms, TestTrait ]
]);

// demo

const eventhandler = (subscription, event) => {
    const data = event.data();
    switch(event.type()) {
    case MetaUnitTestEvent.types.testingUnit:
        console.log(`[${data.timestamp}]  Testing unit ${data.namepath} ...`);
        break;
    case MetaUnitTest.EventEnum.testingMethod:
        console.log(`[${data.timestamp}]  Testing method ${data.testMethod}() for unit ${data.namepath} ...`);
        break;
    case MetaUnitTest.EventEnum.methodTestPass:
        console.log(`[${data.timestamp}]  Test PASS in method ${data.testMethod}() for unit ${data.namepath}`);
        break;
    case MetaUnitTest.EventEnum.methodTestFail:
        console.log(`[${data.timestamp}]  Test FAIL in method ${data.testMethod}() for unit ${data.namepath}`);
        break;
    case MetaUnitTest.EventEnum.unitTestPass:
        console.log(`[${data.timestamp}]  Tests PASS for unit ${data.namepath}`);
        break;
    case MetaUnitTest.EventEnum.unitTestFail:
        console.log(`[${data.timestamp}]  Tests FAIL for unit ${data.namepath}`);
        break;
    }
};

const closehandler = (subscription) => { return; };

const unit = new MetaUnitTest();
const subscription = unit.listener().subscribe(Symbol(), [ MetaUnitTestEvent ], eventhandler, closehandler);
await unit.test();
unit.listener().unsubscribe(subscription);

