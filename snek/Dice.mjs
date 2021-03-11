'use strict';


export default class Dice {
    constructor() {
    }

    async roll() {
        const result = random_number_csprng(2,12); 
        return result;
    }
}

const dice = new Dice();
console.log('Roll ', await dice.roll());

