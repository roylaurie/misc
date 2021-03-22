'use strict';

import Meta from '../Meta.mjs';
import MetaJSCodebase from '../MetaCodebase.mjs';
import TestTrait from '../traits/Test.mjs';

export default class MetaUnitTest {
    static namepath = 'asmov/meta/js/types/UnitTest';

    static EventEnum = MetaEvent.enumerate(
        { namepath: 'namepath', method: 'method', error: 'error' }, {
        testingUnit: 'testingUnit',
        unitTestPassed: 'unitTestPassed',
        unitTestFailed: 'unitTestFailed',
        testingMethod: 'testingMethod',
        methodTestPassed: 'methodTestPassed',
        methodTestFailed: 'methodTestFailed',
    });

    static fixtures = {};

    static async testAll(test) {
        test.#emit(MetaUnitTest.EventEnum.testingUnit, test.namepath);

        // for each test function
            test.#emit(MetaUnitTest.EventEnum.testingMethod, test.namepath, methodName);
            //   call test function
            test.#emit(MetaUnitTest.EventEnum.methodTestPassed, test.namepath, methodName);

        test.#emit(MetaUnitTest.EventEnum.unitTestPassed, test.namepath);
    }

    namepath = MetaUnitTest.namepath;
    #emitter = null;

    constructor() {
        this.#emitter = new Emitter(this);
    }

    listener() {
        return this.#emitter.listener();
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

    #emit(event, namepath, method) {
        this.#emitter.emit(new MetaUnitTest.EventEnum(event, namepath, method));
    }
}

Meta.link(MetaUnitTest, [
    [ Meta.meta.namespace, MetaJSCodebase ],
    [ Meta.meta.conforms, TestTrait ]
]);

// demo

const unit = new MetaUnitTest();
const subscription = unit.listener().listen(MetaUnitTest.EventEnum, event => {
    switch(event.type()) {
    case MetaUnitTest.EventEnum.testingUnit:
        break;
    }
    console.log(event);
});

await unit.test();
subscription.unsubscribe();

