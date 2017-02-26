import qs from 'qs';
import 'whatwg-fetch'; // fetch polyfill
import { autorun } from 'mobx';
import { includes, isEmpty, merge, extend } from 'lodash';

import { logger } from '../lib/util'

import Config from 'lanes/config';

const methodMap = {
    create  : 'POST',
    update  : 'PUT',
    patch   : 'PATCH',
    destroy : 'DELETE',
    read    : 'GET',
};

const paramsMap = {
    fields  : 'f',
    with    : 'w',
    query   : 'q',
    include : 'i',
    order   : 'o',
    limit   : 'l',
    start   : 's',
    format  : 'df',
};

function perform(urlPrefix, defaultOptions = {}) {
    const query   = {};
    const options = {};

    Object.keys(defaultOptions).forEach((key) => {
        const value = defaultOptions[key];
        if (paramsMap[key]) {
            query[paramsMap[key]] = value;
        } else {
            options[key] = value;
        }
    });

    let url = `${Config.api_host}${urlPrefix}.json`;
    if (Config.access_token) {
        query.jwt = Config.access_token;
    }
    if (!isEmpty(query)) {
        url += `?${qs.stringify(query, { arrayFormat: 'brackets' })}`;
    }
    if (!options.headers) { options.headers = {}; }

    options.headers['Content-Type'] = 'application/json';

    return fetch(url, options)
        .then(resp => resp.json())
        .then((json) => {
            if (json.token) { Config.access_token = json.token; }
            return json;
        });
}

function peformMobxyRequest(mobx, options) {
    mobx.syncInProgress = options;  // eslint-disable-line no-param-reassign
    return perform(mobx.syncUrl, options)
        .then((json) => {
            extend(mobx, {
                errors            : json.errors,
                syncInProgress    : undefined,
                lastServerMessage : json.message,
            });

            // sometimes the polyfill seems to set a `:success` property?
            if (false === json[':success']) { merge(mobx, { errors: json[':message'] }); }

            return json;
        }).catch((e) => {
            logger.warn(e);
            extend(mobx, {
                errors            : { network: e },
                syncInProgress    : undefined,
                lastServerMessage : e.toString(),
            });
            return mobx;
        });
}

function forCollection(collection, options = {}) {
    return peformMobxyRequest(collection, options)
}

function forModel(model, options = {}) {
    const action = options.action || (model.isNew ? 'create' : 'update');
    const requestOptions = merge({
        method: methodMap[action],
    }, options);
    if (includes(['POST', 'PUT', 'PATCH'], requestOptions.method)) {
        requestOptions.body = JSON.stringify(options.json || model.dataForSync(options));
    }
    return peformMobxyRequest(model, requestOptions)
        .then(json => (json.data && model.setFromSync(json.data)));
}

export default {
    forModel,
    forCollection,
    perform,
};
