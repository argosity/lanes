import { onBoot, observePubSub } from 'hippo/models/pub_sub';
import PubSubChannel from 'hippo/models/pub_sub/channel';

import { Ship, Container } from '../test-models';

jest.mock('hippo/user', () => ({
    isLoggedIn: true,
}));
jest.mock('hippo/models/pub_sub/channel');

describe('PubSub', () => {
    it('watches and checks in and out', () => {
        const ship = new Ship();
        const container = new Container({ id: '2' });
        onBoot();
        expect(PubSubChannel.prototype.subscribe)
            .not.toHaveBeenCalledWith('test/boat/test');
        expect(PubSubChannel.prototype.subscribe)
            .not.toHaveBeenCalledWith('test/container/2');
        observePubSub(ship, container);
        ship.name = 'test';
        expect(ship.identifierFieldValue).toEqual('test');
        observePubSub(ship);
        expect(PubSubChannel.prototype.subscribe)
            .toHaveBeenCalledWith('test/boat/test');
    });
});
