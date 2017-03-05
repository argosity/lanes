import { observable, autorun } from 'mobx';
import { map, uniq, compact } from 'lodash';
import Group from './group';
import Config from '../config';
import Sync from '../models/sync';

import user from '../user';

const Screens = observable({

    all: observable.map(),

    active: observable.array(),

    groups: observable.map(),

    get activeGroups() {
        if (Group.enabled_group_ids) {
            return map(Group.enabled_group_ids, gid => Group.forId(gid));
        }
        return uniq(compact(map(this.active, s => Group.forId(s.group_id))));
    },

    refresh() {
        Sync.perform(`${Config.api_path}/lanes/screens`).then(({ data: { screens: screenIds } }) => {
            this.active.replace(map(screenIds, id => this.all.get(id)));
        });
    },

});
export default Screens;

let previousLoggedIn = null;
autorun(() => {
    if (user.isLoggedIn !== previousLoggedIn) {
        previousLoggedIn = user.isLoggedIn;
        Screens.refresh();
    }
});
