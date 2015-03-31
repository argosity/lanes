var Lanes = ( global.Lanes || (global.Lanes = {}) );

Lanes.Vendor = ( Lanes.Vendor || {} );

Lanes.Vendor.Ampersand                = ( Lanes.Ampersand || {} );
Lanes.Vendor.Ampersand.Bindings       = require("ampersand-dom-bindings");
Lanes.Vendor.Ampersand.State          = require("ampersand-state");
Lanes.Vendor.Ampersand.CollectionView = require("ampersand-collection-view");
Lanes.Vendor.Ampersand.SubCollection  = require("ampersand-subcollection");
Lanes.Vendor.Ampersand.RestCollection = require("ampersand-rest-collection");
Lanes.Vendor.Ampersand.USCollection   = require('ampersand-collection-underscore-mixin');
Lanes.Vendor.Ampersand.Collection     = require("ampersand-collection");
Lanes.Vendor.Ampersand.Model          = require("ampersand-model");
Lanes.Vendor.Ampersand.Router         = require("ampersand-router");
Lanes.Vendor.KeyMaster                = require("keymaster");
Lanes.Vendor.Moment                   = require("moment");
Lanes.Vendor.RSVP                     = require('rsvp');
Lanes.Vendor.domify                   = require('domify');
Lanes.Vendor.interact                 = require('interact.js');
Lanes.Vendor.BBEvents                 = require('backbone-events-standalone');
Lanes.dom    = require('ampersand-dom');
var u        = require('underscore');
var spf      = require('sprintf-js');

u.mixin(require('underscore.inflections'));
u.mixin({
    Promise         : Lanes.Vendor.RSVP.Promise,
    DeferredPromise : Lanes.Vendor.RSVP.defer,
    getPath         : require('get-object-path'),
    bigDecimal      : require('big.js'),
    sprintf         : spf.sprintf,
    vsprintf        : spf.vsprintf
});
global._ = u;
