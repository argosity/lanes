import {
    isEmpty, isArray, isNumber, isObject, isString, partial, defaults, isNil,
} from 'lodash';
import invariant from 'invariant';

import { intercept } from 'mobx';

import {
    field as mobxField,
    session as mobxSession,
    identifier as mobxIdentifier,
} from 'mobx-decorated-models';

const VALIDATORS = {
    number: isNumber,
    string: isString,
    array:  isArray,
    object: isObject,
};

function addLazyInitializer(target, fn) {
    target.__mobxLazyInitializers.push(fn);
}

function validateChangeType(validator, propertyName, change) {
    if (isNil(change.newValue)) { return change; }
    invariant(VALIDATORS[validator], `Unknown TypeCheck: ${validator} does not exist`);
    invariant(VALIDATORS[validator](change.newValue),
              `Bad Type: Attempted to set ${propertyName} to '${change.newValue}' which is not ${validator}`);
    return change;
}

function addTypeSafeInterceptor(target, property, type) {
    if (isEmpty(type)) { return; }
    addLazyInitializer(target, (partial(intercept, partial.placeholder, property,
                                        partial(validateChangeType, type, property))));
}

function decoratorWrapper(decorator, defaultOptions = {}) {
    return (targetOrOptions, ...args) => {
        const options = isEmpty(args) ?
              defaults(targetOrOptions, defaultOptions) : defaultOptions;

        const wrap = (target, property, descriptor) => {
            const decorationFn = decorator(options);
            const description = decorationFn(target, property, descriptor);
            addTypeSafeInterceptor(target, property, options.type);
            return description;
        };

        if (isEmpty(args)) { // we were given options
            return (target, property, descriptor) => wrap(target, property, descriptor);
        }
        return wrap(targetOrOptions, args[0], args[1]);
    };
}

const field = decoratorWrapper(mobxField);
const session = decoratorWrapper(mobxSession);
const identifier = decoratorWrapper(mobxIdentifier, { type: 'number' });

export { field, session, identifier };
