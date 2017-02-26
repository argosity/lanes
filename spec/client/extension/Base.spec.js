import Base from 'lanes/extensions/base';
import { observable } from 'mobx';

class TestExtension extends Base {

    @observable identifier = 'foo-bar-baz';

}

describe('Base Extension', () => {
    it('computes the title', () => {
        const ext = new TestExtension();
        expect(ext.title).toEqual('Foo Bar Baz');
    });
});
