import React from 'react';
import PropTypes from 'prop-types';
import invariant from 'invariant';
import { action } from 'mobx';
import { inject, observer } from 'mobx-react';
import classnames from 'classnames';
import { Col, getColumnProps } from 'react-flexbox-grid';
import FieldWrapper     from './field-wrapper';
import { titleize } from '../../lib/util';
import DateWrapper     from './fields/date-wrapper';
import SelectWrapper   from './fields/select-wrapper';
import TextWrapper     from './fields/text-wrapper';
import EmailWrapper    from './fields/email-wrapper';
import CheckBoxWrapper from './fields/checkbox-wrapper';
import TagsWrapper     from './fields/tags-wrapper';
import TextAreaWrapper from './fields/textarea-wrapper';
import Label           from './fields/label';
import TimeZoneSelect  from '../../components/time-zone-select';

import './fields/form-field.scss';

const TypesMapping = {
    email:    EmailWrapper,
    text:     TextWrapper,
    date:     DateWrapper,
    tags:     TagsWrapper,
    label:    Label,
    select:   SelectWrapper,
    number:   TextWrapper,
    timezone: TimeZoneSelect,
    checkbox: CheckBoxWrapper,
    textarea: TextAreaWrapper,
};

@inject('formState')
@observer
export default class FormField extends React.Component {

    static propTypes = Object.assign({
        label: PropTypes.string,
        name:  PropTypes.string.isRequired,
        className: PropTypes.string,
        type: PropTypes.string,
        tabIndex: PropTypes.number,
    }, Col.PropTypes)

    static defaultProps = {
        label:     '',
        className: '',
        type:      'text',
        tabIndex: 0,
    }

    focus() {
        if (this.inputRef) { this.inputRef.focus(); }
    }

    componentWillMount() {
        this.field = this.props.formState.setField(this.props.name, this.props);
    }

    componentWillReceiveProps(nextProps) {
        invariant(nextProps.name === this.props.name,
            `cannot update 'name' prop from ${this.props.name} to ${nextProps.name}`);
        this.field.update(this.props);
    }

    @action.bound
    setRef(input) {
        this.inputRef = input;
    }

    render() {
        const {
            name, className, autoFocus, type, children, label, tabIndex,
            validate: _, formState: __, help: ___, ...otherProps
        } = getColumnProps(this.props);

        const InputTag = TypesMapping[type] || TypesMapping.text;

        return (
            <div className={classnames('form-field', type, className)}>
                <FieldWrapper
                    label={label || titleize(name)}
                    error={this.field.invalidMessage}
                    help={this.field.help}
                >
                    <InputTag
                        name={name}
                        tabIndex={tabIndex}
                        autoFocus={autoFocus}
                        ref={this.setRef}
                        value={this.field.value || ''}
                        type={InputTag === TypesMapping.text ? this.props.type : undefined}
                        {...this.field.events}
                        {...otherProps}
                    />
                    {children}
                </FieldWrapper>
            </div>
        );
    }

}
