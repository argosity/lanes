jest.mock('hippo/models/sync');
jest.mock('hippo/config');

import React  from 'react';

import User        from 'hippo/user';
import Config      from 'hippo/config';
import LoginDialog from 'hippo/access/login-dialog';

describe('Login Dialog', () => {
    beforeEach(() => (Config.access_token = '0123456789'));
    afterEach(() => (Config.access_token = ''));

    it('does not render when user isnt logged in', () => {
        expect(User.isLoggedIn).toBe(true);
        const dialog = shallow(<LoginDialog />);
        expect(dialog).not.toHaveRendered('LoginForm');
    });

    it('is hidden when user logins successfully', () => {
        const dialog = shallow(<LoginDialog />);
        expect(User.isLoggedIn).toEqual(true);
        expect(dialog).not.toHaveRendered('LoginForm');
        return User.logout().then(() => {
            expect(dialog).not.toHaveRendered('LoginForm');
        });
    });
});
