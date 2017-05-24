import React from 'react';

import { action, observable } from 'mobx';
import { observer } from 'mobx-react';
import { bindAll } from 'lodash';
import { Router, Route, browserHistory } from 'react-router';

import App   from 'grommet/components/App';
import Sidebar from 'react-sidebar';

import 'hippo/config-data';
import 'hippo/screen-definitions';

import Menu        from './menu';
import Screen      from './screen';
import LoginDialog from '../access/login-dialog';

import './styles.scss';

const DOCKED_WIDTH_BREAKPOINT = 950;

@observer
class Workspace extends React.Component {

    @observable sidebarOpen   = true;
    @observable sidebarDocked = false;

    constructor() {
        super();
        bindAll(this, 'onMediaQueryChanged', 'onSetSidebarOpen');
        this.mql = window.matchMedia(`(min-width: ${DOCKED_WIDTH_BREAKPOINT}px)`);
        this.mql.addListener(this.onMediaQueryChanged);
        this.onMediaQueryChanged();
    }

    componentWillUnmount() {
        this.mql.removeListener(this.onMediaQueryChanged);
    }

    @action
    onMediaQueryChanged() {
        this.sidebarDocked = this.mql.matches;
    }

    @action
    onSetSidebarOpen(open) {
        this.sidebarOpen = open;
    }
    render() {
        return (
            <App
                centered={false}
            >
                <LoginDialog />
                <Sidebar
                    styles={{ sidebar: { zIndex: 5 } }}
                    sidebar={<Menu />}
                    open={this.sidebarOpen}
                    docked={this.sidebarDocked}
                    onSetOpen={this.onSetSidebarOpen}
                >
                    {this.props.children || "Welcome"}
                </Sidebar>
            </App>
        );
    }
}


function NoMatch() {
    return (
        <h1>Not Found</h1>
    );
}

export default function WorkspaceRoot() {
    return (
        <Router history={browserHistory}>
            <Route path="/" component={Workspace}>
                <Route name='screen' path="/:screenId(/:identifier)" component={Screen} />
                <Route path="*" component={NoMatch} />
            </Route>
        </Router>
    );
}