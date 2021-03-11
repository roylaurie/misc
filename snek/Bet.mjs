'use strict';

export default class Bet {
    static numbers = [0,0,2,3,4,5,6,7,8,9,10,11,12];

    static types = {
        establish_pass: 'establish_pass',
        establish_nopass: 'establish_nopass',
        establish_come: 'establish_come',
        establish_nocome: 'establish_nocome',
        pass: 'pass',
        nopass: 'nopass',
        come: 'come',
        nocome: 'nocome',
        buy: 'buy',
        lay: 'lay',
        field: 'field',
        place: 'place'
    };

    static wagers = {
        establish_pass_come: 'establish_pass_come',
        establish_nopass_nocome: 'establish_nopass_nocome',
        pass_come_buy: 'pass_come_buy',
        nopass_nocome_lay: 'nopass_nocome_lay',
        field: 'field',
        place: 'place'
    };

    static typeWager = {
        establish_pass: Bet.wagers.establish_pass_come,
        establish_come: Bet.wagers.establish_pass_come,
        establish_nopass: Bet.wagers.establish_nopass_nocome,
        establish_nocome: Bet.wagers.establish_nopass_nocome,
        pass: Bet.wagers.pass_come_buy,
        come: Bet.wagers.pass_come_buy,
        buy: Bet.wagers.pass_come_buy,
        nopass: Bet.wagers.nopass_nocome_lay,
        nocome: Bet.wagers.nopass_nocome_lay,
        lay: Bet.wagers.nopass_nocome_lay,
        field: Bet.wagers.field,
        place: Bet.wagers.place
    };

    static odds = {
        establish_pass: [
            0, // 0
            0,
            [-1,1],
            0,
            0,
            0,
            [], // 7
            0,
            0,
            0,
            [], // 11
            0
        ],
        pass_come_buy: [
            4: [2,1],
            10: [2,1],
            5: [3,2],
            9: [3,2],
            6: [5,6],
            7: [-1,1]
            8: [5,6]
        ],
        nopass_nocome_lay: {
        },
        field: {
        },
        place: {
        },
    };

    #type = null;
    #wager = null;
    #odds = null;
    #number = null;
    #amount = null;
    #working = true;

    constructor(type, number, amount) {
        this.#type = type;
        this.#wager = Bet.wagers[this.#type];
        this.#odds = Bet.odds[this.#wager];
        this.#number = number;
        this.#amount = amount;
    }

    payout(number) {
        return this.#amount * (this.#odds[number][0] / this.#odds[number][1]);
    }

    next(number) {
    }
}
