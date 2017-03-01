import {
    BaseModel, modelDecorator, identifier, belongsTo, field, computed,
} from './base';

import { merge } from 'lodash';
import Sync from './sync';
import Asset from './asset';

@modelDecorator('lanes/system-settings')
export default class SystemSettings extends BaseModel {

    @identifier id;
    @field({ type: 'object' }) settings;

    @belongsTo({ model: 'lanes/asset', inverseOf: 'owner' }) logo;
    @belongsTo({ model: 'lanes/asset', inverseOf: 'owner' }) print_logo;

    fetch(options = {}) {
        return Sync.forModel(this, merge(options, { limit: 1, method: 'GET' }));
    }

    @computed get syncUrl() {
        return this.constructor.syncUrl;
    }

}