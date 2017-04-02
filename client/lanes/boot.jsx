import React        from 'react'; // eslint-disable-line no-unused-vars
import ReactDOM     from 'react-dom';
import whenDomReady from 'when-dom-ready';
import { delay } from 'lodash';
import { AppContainer } from 'react-hot-loader';
import { withAsyncComponents } from 'react-async-component';

import Config from './config';

const Workspace = require('lanes/workspace').default;

let Root;
let App;

function renderer(Body) {
    withAsyncComponents(<AppContainer><Body /></AppContainer>)
        .then((result) => {
            App = result.appWithAsyncComponents;
            ReactDOM.render(App, Root);
        });
}

if (module.hot) {
    module.hot.accept('lanes/workspace', () => {
        const WSNext = require('lanes/workspace').default; // eslint-disable-line global-require
        renderer(WSNext);
    });
}

whenDomReady().then(() => {
    if (Root) return;
    /* global document: true  */
    Root = document.getElementById('lanes-root');
    Config.bootstrap(JSON.parse(document.getElementById('bootstrap-data').innerHTML));
    /* global document: false */
    renderer(Workspace);
    const loading = document.querySelector('.loading');
    if (loading) {
        loading.classList.add('complete');
        delay(() => loading.parentNode.removeChild(loading), 400);
    }
});
