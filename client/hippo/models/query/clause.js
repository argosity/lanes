import { get, compact, first, filter, uniqueId, isNil, isEmpty } from 'lodash';
import { action, observe } from 'mobx';
import {
    BaseModel, identifiedBy, belongsTo, computed, observable, session,
} from '../base';

@identifiedBy('hippo/query/clause')
export default class Clause extends BaseModel {

    @observable id = uniqueId('clause');

    @session visible = true;

    @session value;

    @belongsTo({ type: 'hippo/query' }) query;

    @belongsTo({ type: 'hippo/query/field' }) field;

    @belongsTo({ type: 'hippo/query/operator' }) operator;

    constructor(attrs) {
        super(attrs);
        if (!this.field) {
            this.field = first(this.query.info.queryableFields);
        }
        if (!this.operator) {
            this.operator = this.field.preferredOperator;
        }
        observe(this, 'field', this.updateOperatorOnFieldChange);
    }

    @computed get description() {
        return compact([get(this, 'field.title'), get(this, 'operator.id')]).join(' ');
    }

    @computed get validOperators() {
        return filter(this.query.operators, o => o.isValidForField(this.field));
    }

    @computed get fingerprint() {
        return [this.field.id, this.operator.id, this.value].join('-');
    }

    @computed get isValid() {
        if ('like' === this.operator.id) { return !isEmpty(this.value); }
        return Boolean(!isNil(this.value) && this.operator.isValidForField(this.field));
    }

    toParam() {
        const param = {};
        let op = this.operator.id;
        let { value } = this;
        if ('like' === op) { value += '%'; }
        if ('contains' === op) {
            op = 'like';
            value = `%${value}%`;
        }
        if ('n' === this.field.type) { value = parseFloat(value); }
        param[this.field.id] = 'eq' === op ? value : { op, value };
        return param;
    }

    @action.bound
    updateOperatorOnFieldChange() {
        this.value = this.field.defaultValue;
        this.operator = this.field.preferredOperator;
    }

}
