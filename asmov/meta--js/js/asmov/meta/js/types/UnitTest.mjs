'use strict';

import Meta from '../Meta.mjs';
import MetaJSCodebase from '../MetaCodebase.mjs';
import TestTrait from '../traits/Test.mjs';

export default class MetaUnitTest {
    static namepath = 'asmov/meta/js/types/UnitTest';

    static fixtures = {};

    constructor() {

    }

    setup() {

    }

    test() {
        // for each test function: call test function
    }

    test_myFunction() {

    }

    teardown() {

    }
}

Meta.link(MetaUnitTest, [
    [ Meta.meta.namespace, MetaJSCodebase ],
    [ Meta.meta.conforms, TestTrait ]
]);