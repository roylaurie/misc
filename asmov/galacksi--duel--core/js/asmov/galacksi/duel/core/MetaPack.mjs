'use strict';

import Meta from '../../asmov/meta/Meta.mjs';
import MetaPack from '../../asmov/meta/Pack.mjs';
import GalacksiDuelCoreProduct from '../../asmov/galacksi/duel/core/MetaProduct.mjs';

export default class GalacksiDuelCorePack extends MetaPack {
    static namepath = 'asmov/galacksi/duel/core/MetaPack';
    static namespace = 'asmov/galacksi/duel/core/';

    constructor() {
        super({
            MetaPackage.dataKeys.namespace:     'asmov/galacksi/duel/core/',
            MetaPackage.dataKeys.product:       GalacksiDuelCoreProduct,
            MetaPackage.dataKeys.version:       '2021.1.0',
            MetaPackage.dataKeys.organisation:  'Asmov LLC',
            MetaPackage.dataKeys.copyright:     '2021',
            MetaPackage.dataKeys.license:       MetaPack.license.GPLv3,

            MetaPackage.dataKeys.pubkey:        0x5F1DF16B2B704C8A578D0BBAF74D385CDE12C11EE50455F3C438EF4C3FBCF649B6DE611FEAE06279A60939E028A8D65C10B73071A6F16719274855FEB0FD8A6704  
        });
    }
}

Meta.linkPack(GalacksiDuelPack);
