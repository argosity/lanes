import React from 'react';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react';
import { action, observable } from 'mobx';
import moment from 'moment';
import DateTime  from 'grommet/components/DateTime';

@observer
export default class DateWrapper extends React.PureComponent {
    static defaultProps = { format: 'M/D/YYYY h:mm a' }
    static childContextTypes = { onDropChange: PropTypes.func }
    @observable isSelecting;
    @observable dateValue;
    @observable isFocused;

    getChildContext() {
        return { onDropChange: this.onDropChange };
    }

    @action.bound onDropChange(active) {
        const ev = { target: { value: moment(this.dateValue, this.props.format, true).toDate() } };
        if (this.isSelecting && !active) {
            this.props.onBlur(ev);
        } else if (active) {
            this.props.onFocus(ev);
        }
        this.isSelecting = active;
    }

    @action.bound onDateChange(date) {
        this.dateValue = date;
        this.props.onChange({ target: { value: this.dateValue } });
    }

    @action.bound onFocus() {
        this.isFocused = true;
    }

    @action.bound onBlur(ev) {
        this.isFocused = false;
        this.dateValue = moment(ev.target.value, this.props.format).toDate();
        const event = { target: { value: this.dateValue } };
        this.props.onChange(event);
        this.props.onBlur(event);
    }

    render() {
        return (
            <DateTime
                {...this.props}
                onFocus={this.onFocus}
                onChange={this.onDateChange}
                onBlur={this.onBlur}
            />
        );
    }
}