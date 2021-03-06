/* eslint no-param-reassign: ["error", {
  "props": true, "ignorePropertyModificationsFor": ["field", "model"]
}] */
import { observable, computed, when, action } from 'mobx';
import {
    pick, isFunction, mapValues, every, get, set, filter, isNil, each, extend,
} from 'lodash';

export class FormField {

    name = '';

    @observable isTouched = false

    @observable isChanged = false;

    @observable value = '';

    @observable message = '';

    @observable help;

    @observable validate;

    @observable default;

    constructor(name, attrs) {
        this.name = name;
        this.update(attrs);
        if (this.default) {
            this.value = this.default;
        }
    }

    update(attrs) {
        each(pick(attrs, [
            'name', 'default', 'help', 'validate', 'value',
        ]), (v, k) => {
            this[k] = isFunction(v) ? v.call(this) : v;
        });
    }

    @action.bound
    onChange({ target: { value: updatedValue } }) {
        this.isChanged = (this.value !== updatedValue);
        this.value = updatedValue;
    }

    @action.bound
    exposeError() {
        if (!this.isValid) {
            this.isTouched = true;
        }
    }

    @action.bound
    onBlur() {
        this.isTouched = true;
    }

    @computed get isValid() {
        if (!this.validate) { return true; }
        return !!this.validate.test(this.value);
    }

    @computed get invalidMessage() {
        return (!this.isValid && this.isTouched) ? this.validate.message : null;
    }

    get events() {
        return {
            onBlur: this.onBlur,
            onChange: this.onChange,

        };
    }

    reset() {
        this.value = '';
        this.isTouched = false;
        this.isChanged = false;
    }

}


export class FormState {

    fields = observable.map();

    @action
    setFields(fields) {
        this.fields.replace(
            mapValues(fields, (field, name) => new FormField(name, field)),
        );
    }

    @action
    setField(name, attrs) {
        let field = this.fields.get(name);
        if (field) {
            field.update(attrs);
        } else {
            field = new FormField(name, extend({}, attrs,
                { value: isNil(attrs.value) ? get(this.values, name) : attrs.value }));
            this.fields.set(name, field);
        }
        return field;
    }

    @computed get invalidFields() {
        return filter(Array.from(this.fields.values()), { isValid: false });
    }

    @computed get isValid() {
        return 0 === this.invalidFields.length;
    }

    @computed get isTouched() {
        return !every(Array.from(this.fields.values()), { isTouched: false });
    }

    @action
    exposeErrors() {
        this.fields.forEach(field => field.exposeError());
    }

    @action
    reset() {
        this.fields.forEach(field => field.reset());
    }

    @action
    get(path, defaultValue) {
        const [name, ...rest] = path.split('.');
        const field = this.fields.get(name);
        if (!field) { return defaultValue; }
        if (rest.length) {
            return get(field, rest.join('.'), defaultValue);
        }
        return field;
    }

    @action
    set(values) {
        this.values = values;
        this.fields.forEach((field, name) => {
            const value = get(values, name);
            field.value = isNil(value) ? '' : value;
        });
    }

    @action
    update(values) {
        each(values, (v, k) => {
            const field = this.fields.get(k);
            if (field) { field.value = v; }
        });
    }

    @action
    setFromModel(model) {
        if (get(model.sync, 'isFetching')) {
            when(
                () => !get(model.sync, 'isFetching'),
                () => this.set(model),
            );
        } else {
            this.set(model);
        }
        return model;
    }

    persistTo(model) {
        this.fields.forEach((field, name) => (set(model, name, field.value)));
        return Promise.resolve(model);
    }

    serialize() {
        return mapValues(this.fields.toJS(), 'value');
    }


}
