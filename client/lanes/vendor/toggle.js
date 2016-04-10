webpackJsonp([3],{

/***/ 0:
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(global) {var Lanes = ( global.Lanes || (global.Lanes = {}) );
	Lanes.Vendor = ( Lanes.Vendor || {} );

	Lanes.Vendor.ReactToggle = __webpack_require__(1421)
	__webpack_require__(1427);

	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ },

/***/ 66:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	module.exports = __webpack_require__(67);


/***/ },

/***/ 841:
/***/ function(module, exports, __webpack_require__) {

	var __WEBPACK_AMD_DEFINE_ARRAY__, __WEBPACK_AMD_DEFINE_RESULT__;/*!
	  Copyright (c) 2016 Jed Watson.
	  Licensed under the MIT License (MIT), see
	  http://jedwatson.github.io/classnames
	*/
	/* global define */

	(function () {
		'use strict';

		var hasOwn = {}.hasOwnProperty;

		function classNames () {
			var classes = [];

			for (var i = 0; i < arguments.length; i++) {
				var arg = arguments[i];
				if (!arg) continue;

				var argType = typeof arg;

				if (argType === 'string' || argType === 'number') {
					classes.push(arg);
				} else if (Array.isArray(arg)) {
					classes.push(classNames.apply(null, arg));
				} else if (argType === 'object') {
					for (var key in arg) {
						if (hasOwn.call(arg, key) && arg[key]) {
							classes.push(key);
						}
					}
				}
			}

			return classes.join(' ');
		}

		if (typeof module !== 'undefined' && module.exports) {
			module.exports = classNames;
		} else if (true) {
			// register as 'classnames', consistent with npm package name
			!(__WEBPACK_AMD_DEFINE_ARRAY__ = [], __WEBPACK_AMD_DEFINE_RESULT__ = function () {
				return classNames;
			}.apply(exports, __WEBPACK_AMD_DEFINE_ARRAY__), __WEBPACK_AMD_DEFINE_RESULT__ !== undefined && (module.exports = __WEBPACK_AMD_DEFINE_RESULT__));
		} else {
			window.classNames = classNames;
		}
	}());


/***/ },

/***/ 1421:
/***/ function(module, exports, __webpack_require__) {

	"use strict";

	var _interopRequire = function (obj) { return obj && obj.__esModule ? obj["default"] : obj; };

	var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; };

	var React = _interopRequire(__webpack_require__(66));

	var classNames = _interopRequire(__webpack_require__(841));

	var Check = _interopRequire(__webpack_require__(1422));

	var X = _interopRequire(__webpack_require__(1423));

	var PureRenderMixin = _interopRequire(__webpack_require__(1424));

	module.exports = React.createClass({
	  mixins: [PureRenderMixin],

	  displayName: "Toggle",

	  propTypes: {
	    checked: React.PropTypes.bool,
	    defaultChecked: React.PropTypes.bool,
	    onChange: React.PropTypes.func,
	    name: React.PropTypes.string,
	    value: React.PropTypes.string,
	    id: React.PropTypes.string,
	    "aria-labelledby": React.PropTypes.string,
	    "aria-label": React.PropTypes.string
	  },

	  getInitialState: function getInitialState() {
	    var checked = false;
	    if ("checked" in this.props) {
	      checked = this.props.checked;
	    } else if ("defaultChecked" in this.props) {
	      checked = this.props.defaultChecked;
	    }
	    return {
	      checked: !!checked,
	      hasFocus: false
	    };
	  },

	  componentWillReceiveProps: function componentWillReceiveProps(nextProps) {
	    if ("checked" in nextProps) {
	      this.setState({ checked: !!nextProps.checked });
	    }
	  },

	  handleClick: function handleClick(event) {
	    var checkbox = this.refs.input;
	    if (event.target !== checkbox) {
	      event.preventDefault();
	      checkbox.focus();
	      checkbox.click();
	      return;
	    }

	    if (!("checked" in this.props)) {
	      this.setState({ checked: checkbox.checked });
	    }
	  },

	  handleFocus: function handleFocus() {
	    this.setState({ hasFocus: true });
	  },

	  handleBlur: function handleBlur() {
	    this.setState({ hasFocus: false });
	  },

	  render: function render() {
	    var classes = classNames("react-toggle", {
	      "react-toggle--checked": this.state.checked,
	      "react-toggle--focus": this.state.hasFocus,
	      "react-toggle--disabled": this.props.disabled
	    });

	    return React.createElement(
	      "div",
	      { className: classes, onClick: this.handleClick },
	      React.createElement(
	        "div",
	        { className: "react-toggle-track" },
	        React.createElement(
	          "div",
	          { className: "react-toggle-track-check" },
	          React.createElement(Check, null)
	        ),
	        React.createElement(
	          "div",
	          { className: "react-toggle-track-x" },
	          React.createElement(X, null)
	        )
	      ),
	      React.createElement("div", { className: "react-toggle-thumb" }),
	      React.createElement("input", _extends({
	        ref: "input",
	        onFocus: this.handleFocus,
	        onBlur: this.handleBlur,
	        className: "react-toggle-screenreader-only",
	        type: "checkbox"
	      }, this.props))
	    );
	  }
	});


/***/ },

/***/ 1422:
/***/ function(module, exports, __webpack_require__) {

	"use strict";

	var _interopRequire = function (obj) { return obj && obj.__esModule ? obj["default"] : obj; };

	var React = _interopRequire(__webpack_require__(66));

	module.exports = React.createClass({
	  displayName: "check.es6",

	  render: function render() {
	    return React.createElement(
	      "svg",
	      { width: "14", height: "11", viewBox: "0 0 14 11", xmlns: "http://www.w3.org/2000/svg" },
	      React.createElement(
	        "title",
	        null,
	        "switch-check"
	      ),
	      React.createElement("path", { d: "M11.264 0L5.26 6.004 2.103 2.847 0 4.95l5.26 5.26 8.108-8.107L11.264 0", fill: "#fff", "fill-rule": "evenodd" })
	    );
	  }
	});


/***/ },

/***/ 1423:
/***/ function(module, exports, __webpack_require__) {

	"use strict";

	var _interopRequire = function (obj) { return obj && obj.__esModule ? obj["default"] : obj; };

	var React = _interopRequire(__webpack_require__(66));

	module.exports = React.createClass({
	  displayName: "x.es6",

	  render: function render() {
	    return React.createElement(
	      "svg",
	      { width: "10", height: "10", viewBox: "0 0 10 10", xmlns: "http://www.w3.org/2000/svg" },
	      React.createElement(
	        "title",
	        null,
	        "switch-x"
	      ),
	      React.createElement("path", { d: "M9.9 2.12L7.78 0 4.95 2.828 2.12 0 0 2.12l2.83 2.83L0 7.776 2.123 9.9 4.95 7.07 7.78 9.9 9.9 7.776 7.072 4.95 9.9 2.12", fill: "#fff", "fill-rule": "evenodd" })
	    );
	  }
	});


/***/ },

/***/ 1424:
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__(1425);

/***/ },

/***/ 1425:
/***/ function(module, exports, __webpack_require__) {

	/**
	 * Copyright 2013-present, Facebook, Inc.
	 * All rights reserved.
	 *
	 * This source code is licensed under the BSD-style license found in the
	 * LICENSE file in the root directory of this source tree. An additional grant
	 * of patent rights can be found in the PATENTS file in the same directory.
	 *
	 * @providesModule ReactComponentWithPureRenderMixin
	 */

	'use strict';

	var shallowCompare = __webpack_require__(1426);

	/**
	 * If your React component's render function is "pure", e.g. it will render the
	 * same result given the same props and state, provide this mixin for a
	 * considerable performance boost.
	 *
	 * Most React components have pure render functions.
	 *
	 * Example:
	 *
	 *   var ReactComponentWithPureRenderMixin =
	 *     require('ReactComponentWithPureRenderMixin');
	 *   React.createClass({
	 *     mixins: [ReactComponentWithPureRenderMixin],
	 *
	 *     render: function() {
	 *       return <div className={this.props.className}>foo</div>;
	 *     }
	 *   });
	 *
	 * Note: This only checks shallow equality for props and state. If these contain
	 * complex data structures this mixin may have false-negatives for deeper
	 * differences. Only mixin to components which have simple props and state, or
	 * use `forceUpdate()` when you know deep data structures have changed.
	 */
	var ReactComponentWithPureRenderMixin = {
	  shouldComponentUpdate: function (nextProps, nextState) {
	    return shallowCompare(this, nextProps, nextState);
	  }
	};

	module.exports = ReactComponentWithPureRenderMixin;

/***/ },

/***/ 1426:
/***/ function(module, exports, __webpack_require__) {

	/**
	 * Copyright 2013-present, Facebook, Inc.
	 * All rights reserved.
	 *
	 * This source code is licensed under the BSD-style license found in the
	 * LICENSE file in the root directory of this source tree. An additional grant
	 * of patent rights can be found in the PATENTS file in the same directory.
	 *
	* @providesModule shallowCompare
	*/

	'use strict';

	var shallowEqual = __webpack_require__(188);

	/**
	 * Does a shallow comparison for props and state.
	 * See ReactComponentWithPureRenderMixin
	 */
	function shallowCompare(instance, nextProps, nextState) {
	  return !shallowEqual(instance.props, nextProps) || !shallowEqual(instance.state, nextState);
	}

	module.exports = shallowCompare;

/***/ },

/***/ 1427:
/***/ function(module, exports) {

	// removed by extract-text-webpack-plugin

/***/ }

});